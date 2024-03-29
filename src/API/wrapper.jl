module Wrapper
include("alias.jl")
include("pco_enum.jl")
include("pco_struct.jl")
include("pco_sc2_cam_lib.jl")
include("pco_recorder_lib.jl")

using .PcoStruct
using .TypeAlias
using ..Unitful
export reset
# ----------------------------------------------------------------------
#    SDK wrapper
# ----------------------------------------------------------------------

"""
Reset driver that close all opened cameras
"""
function reset()
    SDK.ResetLib()
end

# I/O configuration

const TRIGGER_MODE = ["auto", "SW", "HW&SW", "HW", "HW sync", "fast HW", "CDS", "slow HW"]

function trigger_mode(cam_handle::HANDLE)
    mode = Ref(WORD(0))
    SDK.GetTriggerMode(cam_handle, mode)
    return TRIGGER_MODE[mode[]+1]
end

function trigger_mode!(cam_handle::HANDLE, mode_name)
    mode = findfirst(x-> x==mode_name, TRIGGER_MODE)
    SDK.SetTriggerMode(cam_handle, mode-1)
end

function trigger(cam_handle::HANDLE)
    trigger_success = Ref(WORD(0))
    SDK.ForceTrigger(cam_handle, trigger_success)
    if trigger_success == 0
        @warn "camera is already active"
    end
end

function region_of_interest(cam_handle::HANDLE)
    roi = zeros(WORD,(4,))
    SDK.GetROI(cam_handle, [view(roi, i) for i = 1:4]...)
    return NamedTuple{(:x_min,:y_min,:x_max,:y_max)}(ntuple(i->roi[i],4))
end

function recording_state!(cam_handle::HANDLE,state)
    SDK.SetRecordingState(cam_handle,state)
end

function default!(cam_handle::HANDLE)
    metasize = Ref(WORD(0))
    metaversion = Ref(WORD(0))
    SDK.ResetSettingsToDefault(cam_handle)
    SDK.SetTimestampMode(cam_handle, false)
    SDK.SetMetaDataMode(cam_handle, true, metasize, metaversion)
    SDK.SetBitAlignment(cam_handle,1)
end

function timing_mode(cam_handle::HANDLE)
    ref_timing_structure = Ref(Timing())
    SDK.GetTimingStruct(cam_handle, ref_timing_structure)
    timing_structure = ref_timing_structure[]
    if timing_structure.TimingControlMode == WORD(0)
        # exposure / delay
        if timing_structure.TimeBaseDelay == WORD(0)
            delay_unit = u"ns"
        elseif timing_structure.TimeBaseDelay == WORD(1)
            delay_unit = u"μs"
        else
            delay_unit = u"ms"
        end
        if timing_structure.TimeBaseExposure == WORD(0)
            exposure_unit = u"ns"
        elseif timing_structure.TimeBaseExposure == WORD(1)
            exposure_unit = u"μs"
        else
            exposure_unit = u"ms"
        end
        exposure_table = Int.(timing_structure.ExposureTable)
        delay_table = Int.(timing_structure.DelayTable)
        is_valid_index = .!(exposure_table .== delay_table .== 0)
        idx = findlast(is_valid_index)
        if idx == 1
            (
                exposure = exposure_table[1].*exposure_unit,
                delay = delay_table[1].*delay_unit
            )
        else
            (
                exposure = exposure_table[1:idx].*delay_unit,
                delay = delay_table[1:idx].*delay_unit
            )
        end
    else
        # fps
        (
            exposure = timing_structure.FrameRateExposure.*u"ns",
            fps = timing_structure.FrameRate.*u"mHz"
        )
    end
end

function arm(cam_handle::HANDLE)
    SDK.ArmCamera(cam_handle)
end

# activation & I/O operation

const REC_MODE_DICT = Dict("file"=>1, "memory"=>2, "camram"=>3)

function create(cam_handle, mode = "memory",drive_letter='C')
    rec_handle_ptr = Ref(C_NULL)
    cam_handle_arr = [cam_handle]
    cam_count = length(cam_handle_arr)
    img_distribution_arr = ones(DWORD, cam_count)
    rec_mode = REC_MODE_DICT[mode]
    MaxImgCountArr = zeros(DWORD, cam_count)
    
    Recorder.Create(rec_handle_ptr, cam_handle_arr, img_distribution_arr, cam_count,
    rec_mode, drive_letter, MaxImgCountArr)
    return rec_handle_ptr[], MaxImgCountArr[]
end

function delete(rec_handle)
    if rec_handle != C_NULL
        Recorder.Delete(rec_handle)
    end
end

const RECORDER_MODE_FILE = ["tif", "multi_tif", "pco_raw","b16", "dicom", "multi_dicom"]
const RECORDER_MODE_MEMORY = ["sequence", "ring buffer", "fifo"]
const RECORDER_MODE_CAMRAM = ["sequential","single_image"]

function init(rec_handle,img_count,memory_type,buffer_type, overwrite = false)
    cam_count = 1
    if buffer_type == "ring buffer" || buffer_type == "fifo"
        @assert img_count >= 4 "Please use 4 or more image buffer on that buffer type"
    end
    if memory_type == "file"
        type = findfirst(isequal(buffer_type), RECORDER_MODE_FILE)
    elseif memory_type == "memory"
        type = findfirst(isequal(buffer_type), RECORDER_MODE_MEMORY)
    else
        type = findfirst(isequal(buffer_type), RECORDER_MODE_CAMRAM)
    end
    filepath = C_NULL
    ram_segment_arr = C_NULL
    Recorder.Init(rec_handle, Ref(DWORD(img_count)), cam_count, 
                           type, overwrite, filepath, ram_segment_arr)
end


function start_record(rec_handle)
    Recorder.StartRecord(rec_handle,C_NULL)
end


function stop_record(rec_handle, cam_handle)
    if rec_handle != C_NULL
        Recorder.StopRecord(rec_handle, cam_handle)
    end
end

function isactivated(rec_handle, cam_handle)
    is_running = Ref(bool(true))
    Recorder.GetStatus(rec_handle, cam_handle, is_running, ntuple(_->C_NULL, 8)...)
    return is_running[]
end

function copy_image(rec_handle, cam_handle, roi::NamedTuple)
    copy_image(rec_handle, cam_handle; roi...)
end

function copy_image(rec_handle, cam_handle; x_min, y_min, x_max, y_max)
    img_cnt_ptr = Ref(DWORD(0))
    while img_cnt_ptr[] == 0
        Recorder.GetStatus(rec_handle,cam_handle, C_NULL, C_NULL, C_NULL, img_cnt_ptr, 
                    C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    end
    img_cnt = img_cnt_ptr[]
    w = x_max - x_min + 1
    h = y_max - y_min + 1
    image = zeros(WORD,(w,h,img_cnt))
    metadata = Ref(Metadata())
    timestamp = C_NULL
    for img_idx = 0:img_cnt-1
        img_num = Ref(DWORD(0))
        Recorder.CopyImage(rec_handle, cam_handle, img_idx, x_min, y_min, x_max, y_max,
                                    @view(image[w*h*img_idx+1]), img_num, metadata, timestamp)
    end
    return image
end

# Description

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
    SDK.GetCameraType(cam_handle, cam_type)
    cam_name = CAMNAME_DICT[cam_type.CamType]
    serial_num =cam_type.SerialNumber
    return cam_name,serial_num
end


const CAMERA_NAME_LEN = 40

function name(cam_handle::HANDLE)
    name = zeros(Cchar, CAMERA_NAME_LEN)
    SDK.GetCameraName(cam_handle, name, CAMERA_NAME_LEN)
    name[end] = 0
    unsafe_string(pointer(name))
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

end