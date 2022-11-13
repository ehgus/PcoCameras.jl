module Wrapper
include("TypeAlias.jl")
include("PcoStructs.jl")

using .PcoStruct
using .TypeAlias
# ----------------------------------------------------------------------
#    Initialization
# ----------------------------------------------------------------------

function __init__()
end


# ----------------------------------------------------------------------
#    SDK wrapper
# ----------------------------------------------------------------------

include("SDK.jl")


struct CameraError <: Exception
    msg::String
end

function errortext(rc)
    len = 200
    txt = Vector{Cchar}(undef, len)
    SDK.GetErrorTextSDK(rc, txt, len)
    txt[end] = 0
    unsafe_string(pointer(txt))
end


macro rccheck(apicall)
    str_apicall = "Pco." * sprint(Base.show_unquoted, apicall)
    return esc(quote
        rc = $apicall
        if rc != 0
            func = $str_apicall
            txt = errortext(rc)
            throw(CameraError("$(func) : $(txt)"))
        end
    end)
end


function recording_state!(cam_handle_ptr::HANDLE,state)
    recstate = Ref(WORD(0))
    @rccheck SDK.GetRecordingState(cam_handle_ptr,recstate)
    if recstate[] != state
        @rccheck SDK.SetRecordingState(cam_handle_ptr,state)
    end
end


function default!(cam_handle_ptr::HANDLE)
    @rccheck SDK.ResetSettingsToDefault(cam_handle_ptr)
    @rccheck SDK.SetBitAlignment(cam_handle_ptr,1)
end


function arm!(cam_handle_ptr::HANDLE)
    @rccheck SDK.ArmCamera(cam_handle_ptr)
end

const INTERFACE_DICT = Dict("FireWire" => 1,
"GigE"=> 5,
"USB 2.0"=> 6,
"Camera Link Silicon Software"=> 7,
"USB 3.0"=> 8,
"CLHS"=> 11)

function open(interface::String)
    cam_handle_ptr = Ref{HANDLE}(0)
    refoepnstruct = Openstruct(InterfaceType=INTERFACE_DICT[interface])
    @rccheck SDK.OpenCameraEx(cam_handle_ptr, refoepnstruct)
    return cam_handle_ptr[]
end


function close!(cam_handle::HANDLE)
    @rccheck SDK.CloseCamera(cam_handle)
end


function health(cam_handle::HANDLE)
    args = [Ref(DWORD(0)), Ref(DWORD(0)), Ref(DWORD(0))]
    SDK.GetCameraHealthStatus(cam_handle, args...)
    state = Dict("warn"=>args[1][],"err"=>args[2][],"status"=>args[3][])
    if state["err"] != 0
        throw(CameraError("Camera has error status"))
    end
    return state
end

const CAMNAME_DICT = Dict(
    0x0100=>"pco.1200HS",0x0200=>"pco.1200",0x0220=>"pco.1600",
    0x0240=>"pco.2000",0x0260=>"pco.4000",0x0830=>"pco.1400",
    0x1000=>"pco.dimax",0x1010=>"pco.dimax_TV",0x1020=>"pco.dimax CS",
    0x1400=>"pco.flim",0x1500=>"pco.pandas",0x0800=>"pco.pixelfly usb",
    0x1300=>"pco.edge 5.5 CL",0x1302=>"pco.edge 4.2 CL",0x1310=>"pco.edge GL",
    0x1320=>"pco.edge USB3",0x1340=>"pco.edge CLHS",0x1304=>"pco.edge MT")

function type(cam_handle::HANDLE)
    cam_type = CameraType()
    @rccheck SDK.GetCameraType(cam_handle, cam_type)
    cam_name = CAMNAME_DICT[cam_type.CamType]
    serial_num =cam_type.SerialNumber
    return cam_name,serial_num
end


const CAMERA_NAME_LEN = 40

function name(cam_handle::HANDLE)
    name = zeros(Cchar, CAMERA_NAME_LEN)
    @rccheck SDK.GetCameraName(cam_handle, name, CAMERA_NAME_LEN)
    name[end] = 0
    unsafe_string(pointer(name))
end


function roi(cam_handle::HANDLE)
    roi = zeros(WORD,4)
    @rccheck SDK.GetROI(cam_handle, [@view(roi[i]) for i = 1:4]...)
    return roi[1],roi[2],roi[3],roi[4]
end

function configuration(cam_handle::HANDLE)
    pixel_rate = Ref(DWORD(0))
    trigger_mode = Ref(WORD(0))
    acquire_mode = Ref(WORD(0))
    binHorz = Ref(WORD(0))
    binVert = Ref(WORD(0))
    SDK.GetPixelRate(cam_handle,pixel_rate)
    SDK.GetTriggerMode(cam_handle,trigger_mode)
    SDK.GetAcquireMode(cam_handle,acquire_mode)
    SDK.GetBinning(cam_handle,binHorz,binVert)
    
    return pixel_rate[], trigger_mode[], acquire_mode[], (binHorz[], binVert[])
end

# ----------------------------------------------------------------------
#    Recorder wrapper
# ----------------------------------------------------------------------

include("Recorder.jl")


const REC_MODE_DICT = Dict("file"=>1, "memory"=>2, "camram"=>3)

function create(cam_handle, mode = "memory",drive_letter='C')
    rec_handle_ptr = Ref(HANDLE(0))
    cam_handle_arr = Ref(cam_handle)
    img_distribution_arr = ones(DWORD, 1)
    cam_count = 1
    rec_mode = REC_MODE_DICT[mode]
    MaxImgCountArr = Ref(DWORD(0))
    
    @rccheck Recorder.Create(rec_handle_ptr, cam_handle_arr, img_distribution_arr, cam_count,
    rec_mode, drive_letter, MaxImgCountArr)
    return rec_handle_ptr[], MaxImgCountArr[]
end


function delete(rec_handle)
    if rec_handle != HANDLE(0)
        @rccheck Recorder.Delete(rec_handle)
    end
end


const RECORDER_MODE_DICT = Dict("sequence"=>1, "ring buffer"=>2, "fifo"=>3)

function init(rec_handle,img_count,mode="sequence")
    type = RECORDER_MODE_DICT[mode]
    overwrite = false
    filepath = collect(Cchar,"C:/\0")
    ram_segment_arr = C_NULL
    @rccheck Recorder.Init(rec_handle,Ref(DWORD(img_count)),1,type,overwrite,filepath,ram_segment_arr)
end


function start_record(rec_handle)
    @rccheck Recorder.StartRecord(rec_handle,C_NULL)
end


function stop_record(rec_handle, cam_handle)
    if rec_handle != HANDLE(0)
        @rccheck Recorder.StopRecord(rec_handle, cam_handle)
    end
end

function wait_running(rec_handle, cam_handle)
    isrunning = Ref(bool(true))
    while Bool(isrunning[])
        @rccheck Recorder.GetStatus(rec_handle, cam_handle, isrunning, ntuple(_->C_NULL, 8)...)
        sleep(1e-3)
    end
end

function copy_image(rec_handle, cam_handle, roi)
    img_cnt_ptr = Ref(DWORD(0))
    @rccheck Recorder.GetStatus(rec_handle,cam_handle, C_NULL, C_NULL, C_NULL, img_cnt_ptr, 
                C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    img_cnt = img_cnt_ptr[]
    @assert img_cnt > 0
    w = roi[3]-roi[1]+1
    h = roi[4]-roi[2]+1
    image = zeros(WORD,(w,h,img_cnt))
    metadata = Metadata()
    timestamp = Timestamp()
    for img_idx = 0:img_cnt-1
        img_num = Ref(DWORD(0))
        @rccheck Recorder.CopyImage(rec_handle, cam_handle, img_idx, roi...,
                                    @view(image[w*h*img_idx+1]), img_num, metadata, timestamp)
    end
    return image
end


end