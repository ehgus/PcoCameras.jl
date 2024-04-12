
"""
Reset driver that close all opened cameras
"""
function reset()
    SDK.ResetLib()
end

@kwdef struct PcoCamera <: ExternalDeviceName
    interface::Interface.T = Interface.Any
end

@kwdef mutable struct PcoCameraIOStream <: ExternalDeviceIOStream
    name::String = ""
    cam_handle::HANDLE = C_NULL
    rec_handle::HANDLE = C_NULL
    # camera configuration
    roi::NTuple{2,NTuple{2,<:Integer}}
    recorder_mode::RecorderMode = MemoryRecorder.ring_buffer
    number_of_images::Unsigned = 1
end

function show(io::IO, ::MIME"text/plain", cam::PcoCamera)
    print(io, "Pco camera\nInterface: $(cam.interface)")
end

function open(cam::PcoCamera)
    cam_handle = try
        # connect camera
        ref_cam_handle = Ref(C_NULL)
        ref_openstruct = Ref(PcoStruct.Openstruct(Interface=WORD(cam.interface)))
        SDK.OpenCameraEx(ref_cam_handle, ref_openstruct)
        ref_cam_handle[]
    catch e
        if ~isa(e, SDK.CameraError)
            throw(e)
        end
        error("No camera found."*
        " Please check the connection and close other process which use the camera")
    end

    try
        # set to default mode
        SDK.SetRecordingState(cam_handle, 0)
        default!(cam_handle)
        SDK.ArmCamera(cam_handle)
        # get default ROI
        roi_dev = zeros(WORD,(4,))
        SDK.GetROI(cam_handle, [view(roi_dev, i) for i = 1:4]...)
        roi = (roi_dev[1],roi_dev[3]),(roi_dev[2],roi_dev[4])
        # get name

        name = get_name(cam_handle)
        # return IO
        io = PcoCameraIOStream(name = name, cam_handle = cam_handle, roi = roi)
        finalizer(close, io)
        io
    catch e
        SDK.CloseCamera(cam_handle)
        if !isa(e,SDK.CameraError)
            throw(e)
        end
        error("The camera initialization has been failed\n--> $(e.msg)")
    end
end

function get_name(cam_handle::HANDLE)
    CAMERA_NAME_LEN = 40
    name = zeros(Cchar, CAMERA_NAME_LEN)
    SDK.GetCameraName(cam_handle, name, CAMERA_NAME_LEN)
    name[end] = 0
    unsafe_string(pointer(name))
end

function default!(cam_handle::HANDLE)
    metasize = Ref(WORD(0))
    metaversion = Ref(WORD(0))
    SDK.ResetSettingsToDefault(cam_handle)
    SDK.SetTimestampMode(cam_handle, false)
    SDK.SetMetaDataMode(cam_handle, true, metasize, metaversion)
    SDK.SetBitAlignment(cam_handle,1)
end

function close(cam_io::PcoCameraIOStream)
    if !isopen(cam_io)
        return
    end
    deactivate(cam_io)
    delete(cam_io.rec_handle)
    cam_io.rec_handle = C_NULL
    SDK.CloseCamera(cam_io.cam_handle)
    cam_io.cam_handle = C_NULL
    return
end

function delete(rec_handle)
    if rec_handle != C_NULL
        Recorder.Delete(rec_handle)
    end
end

function isopen(cam_io::PcoCameraIOStream) 
    cam_io.cam_handle == C_NULL ? false : true
end

function region_of_interest(cam_io::PcoCameraIOStream)
    return getfield(cam_io, :roi)
end

function region_of_interest!(cam_io::PcoCameraIOStream,roi::NTuple{2,NTuple{2,<:Integer}})
    return setfield!(cam_io, :roi, roi)
end

function trigger_mode(cam_io::PcoCameraIOStream)
    mode = Ref(WORD(0))
    SDK.GetTriggerMode(cam_io.cam_handle, mode)
    return TriggerMode.T(mode[])
end

function trigger_mode!(cam_io::PcoCameraIOStream,trigger_mode::TriggerMode.T)
    SDK.SetTriggerMode(cam_io.cam_handle, WORD(trigger_mode))
    SDK.ArmCamera(cam_io.cam_handle)
end

function timing_mode(cam_io::PcoCameraIOStream)
    ref_timing_structure = Ref(PcoStruct.Timing())
    SDK.GetTimingStruct(cam_io.cam_handle, ref_timing_structure)
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

const TIME_QUANTITY = Quantity{<:Number,Unitful.𝐓}
const FREQ_QUANTITY = Quantity{<:Number,Unitful.𝐓^-1}

function timing_mode!(cam_io::PcoCameraIOStream; exposure, delay=nothing, fps=nothing)
    @assert xor(isnothing(delay), isnothing(fps)) "Either `delay` or `fps` should be defined"
    timing_mode!(cam_io, something(delay, fps), exposure)
end

function timing_mode!(cam_io::PcoCameraIOStream, delay::TIME_QUANTITY, exposure::TIME_QUANTITY)
    if unit(delay) == u"ns"
        delay_unit = WORD(0)
        delay_val = round(DWORD,uconvert(NoUnits, delay/1u"ns"))
    elseif unit(delay) == u"μs"
        delay_unit = WORD(1)
        delay_val = round(DWORD,uconvert(NoUnits, delay/1u"μs"))
    else
        delay_unit = WORD(2)
        delay_val = round(DWORD,uconvert(NoUnits, delay/1u"ms"))
    end
    if unit(exposure) == u"ns"
        exposure_unit = WORD(0)
        exposure_val = round(DWORD,uconvert(NoUnits, exposure/1u"ns"))
    elseif unit(exposure) == u"μs"
        exposure_unit = WORD(1)
        exposure_val = round(DWORD,uconvert(NoUnits, exposure/1u"μs"))
    else
        exposure_unit = WORD(2)
        exposure_val = round(DWORD,uconvert(NoUnits, exposure/1u"ms"))
    end
    SDK.SetDelayExposureTime(cam_io.cam_handle, delay_val, exposure_val, delay_unit, exposure_unit)
end

function timing_mode!(cam_io::PcoCameraIOStream, delay::Vector{<:TIME_QUANTITY}, exposure::Vector{<:TIME_QUANTITY})
    MAX_LENGTH = WORD(16)
    count = max(length(delay), length(exposure))
    @assert count ≤ MAX_LENGTH "Maximum length of time table should be less than $(MAX_LENGTH)"
    delay_val = zeros(WORD, MAX_LENGTH)
    exposure_val = zeros(WORD, MAX_LENGTH)
    if unit(eltype(delay)) == u"ns"
        delay_unit = WORD(0)
        delay_val[1:length(delay)] .= round.(DWORD,uconvert.(NoUnits, delay./1u"ns"))
    elseif unit(eltype(delay)) == u"μs"
        delay_unit = WORD(1)
        delay_val[1:length(delay)] .= round.(DWORD,uconvert.(NoUnits, delay./1u"μs"))
    else
        delay_unit = WORD(2)
        delay_val[1:length(delay)] .= round.(DWORD,uconvert.(NoUnits, delay./1u"ms"))
    end
    if unit(eltype(exposure)) == u"ns"
        exposure_unit = WORD(0)
        exposure_val[1:length(exposure)] .= round.(DWORD,uconvert.(NoUnits, exposure./1u"ns"))
    elseif unit(eltype(exposure)) == u"μs"
        exposure_unit = WORD(1)
        exposure_val[1:length(exposure)] .= round.(DWORD,uconvert.(NoUnits, exposure./1u"μs"))
    else
        exposure_unit = WORD(2)
        exposure_val[1:length(exposure)] .= round.(DWORD,uconvert.(NoUnits, exposure./1u"ms"))
    end
    SDK.SetDelayExposureTimeTable(cam_io.cam_handle, delay_val, exposure_val, delay_unit, exposure_unit, count)
end

function timing_mode!(cam_io::PcoCameraIOStream, fps::FREQ_QUANTITY, exposure::TIME_QUANTITY)
    frame_rate_mode = WORD(3)
    ref_frame_rate_status = Ref(WORD(0))
    exposure_val = Ref(round(DWORD,uconvert(NoUnits, exposure/1u"ns")))
    fps_val = Ref(round(DWORD,uconvert(NoUnits, fps/1u"mHz")))
    SDK.SetFrameRate(cam_io.cam_handle, ref_frame_rate_status, frame_rate_mode, fps_val, exposure_val)
    frame_rate_status = ref_frame_rate_status[]
    if frame_rate_mode == 0
    elseif frame_rate_status == 1
        @warn "Imaging will be limited by readout time"
    elseif frame_rate_status == 2
        @warn "Imaging will be limited by exposure time"
    elseif frame_rate_status == 4
        @warn "Exposure time is trimmed"
    elseif frame_rate_status == 0x8000
        @warn "Fail to set the fps timing"
    end
end

function buffer_mode(cam_io::PcoCameraIOStream)
    return cam_io.recorder_mode, cam_io.number_of_images
end

function buffer_mode!(cam_io::PcoCameraIOStream, recorder_mode::RecorderMode, number_of_images)
    @assert number_of_images > 0 "Number of images is at least one"
    cam_io.recorder_mode = recorder_mode
    cam_io.number_of_images = number_of_images
    cam_io
end

"""
Start Recording
"""
function activate(cam_io::PcoCameraIOStream)
    # Reset previous recorder handler
    if health(cam_io.cam_handle)["status"] & 2 == 0
        SDK.ArmCamera(cam_io.cam_handle)
    end
    deactivate(cam_io)
    delete(cam_io.rec_handle)
    # create handler
    cam_io.rec_handle, max_img_count = create(cam_io.cam_handle, cam_io.recorder_mode)
    @assert cam_io.number_of_images <= max_img_count "Maximum available images: $(max_img_count)"
    init(cam_io.rec_handle, cam_io.recorder_mode, cam_io.number_of_images)
    Recorder.StartRecord(cam_io.rec_handle,C_NULL)
end

function create(cam_handle::HANDLE, recorder_mode::RecorderMode; drive_letter='C', img_distribution = C_NULL)
    cam_count = 1
    ref_rec_handle = Ref(C_NULL)
    ref_max_img_count = Ref(DWORD(0))
    
    Recorder.Create(ref_rec_handle, Ref(cam_handle), img_distribution, cam_count,
                    WORD(typeof(recorder_mode)), drive_letter, ref_max_img_count)
    return ref_rec_handle[], ref_max_img_count[]
end

function init(rec_handle::HANDLE, recorder_mode::RecorderMode, img_count; overwrite = false, filepath = C_NULL, ram_segment = C_NULL)
    cam_count = 1
    if recorder_mode ∈ (MemoryRecorder.ring_buffer, MemoryRecorder.fifo)
        @assert img_count >= 4 "Please use 4 or more image buffer on that recorder mode"
    end
    Recorder.Init(rec_handle, Ref(DWORD(img_count)), cam_count,
                  WORD(recorder_mode), overwrite, filepath, ram_segment)
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

function deactivate(cam_io::PcoCameraIOStream)
    if isactivated(cam_io)
        Recorder.StopRecord(cam_io.rec_handle, cam_io.cam_handle)
    end
end

function isactivated(cam_io::PcoCameraIOStream)
    if cam_io.rec_handle == C_NULL
        return false
    end
    is_running = Ref(bool(true))
    Recorder.GetStatus(cam_io.rec_handle, cam_io.cam_handle, is_running, ntuple(_->C_NULL, 8)...)
    return is_running[] == 1
end

function trigger(cam_io::PcoCameraIOStream)
    ref_trigger_success = Ref(WORD(0))
    SDK.ForceTrigger(cam_io.cam_handle, ref_trigger_success)
    if ref_trigger_success[] == 0
        @warn "Software trigger does not work"
    end
end

function wait(cam_io::PcoCameraIOStream, timeout = 10)
    start_time = now()
    while isactivated(cam_io)
        sleep(1e-3)
        if now() - start_time > Second(timeout)
            error("Timeout")
            break
        end
    end
end

function read(cam_io::PcoCameraIOStream)
    # copy image from the stack
    (x_min,x_max), (y_min, y_max) = cam_io.roi
    img_cnt_ptr = Ref(DWORD(0))
    while img_cnt_ptr[] == 0
        Recorder.GetStatus(cam_io.rec_handle,cam_io.cam_handle, C_NULL, C_NULL, C_NULL, img_cnt_ptr, 
                    C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    end
    img_cnt = img_cnt_ptr[]
    w = x_max - x_min + 1
    h = y_max - y_min + 1
    image = zeros(WORD,(w,h,img_cnt))
    metadata = Ref(SDK.Metadata())
    timestamp = C_NULL
    for img_idx = 0:img_cnt-1
        img_num = Ref(DWORD(0))
        Recorder.CopyImage(cam_io.rec_handle, cam_io.cam_handle, img_idx, x_min, y_min, x_max, y_max,
                                    @view(image[w*h*img_idx+1]), img_num, metadata, timestamp)
    end
    return image
end