using .Wrapper
using .Wrapper.TypeAlias
using .Wrapper.PcoEnum
using .Wrapper: PcoStruct, SDK, Recorder

@kwdef struct PcoCamera <: ExternalDeviceName
    interface::InterfaceType.T = InterfaceType.Any
end

function PcoCamera(interface::Symbol)
    PcoCamera(eval(:(InterfaceType.$interface)))
end

@kwdef mutable struct PcoCameraIOStream <: ExternalDeviceIOStream
    name::String = ""
    # handler
    cam_handle::HANDLE = C_NULL
    rec_handle::HANDLE = C_NULL
    # camera configuration
    roi::@NamedTuple{x_min::WORD,y_min::WORD,x_max::WORD,y_max::WORD}
    # logging
    timestamp::Bool = false
    memory_type::String = "memory"
    buffer_type::String = "sequence"
    number_of_images::Int = 1
end

function show(io::IO, ::MIME"text/plain", cam::PcoCamera)
    print(io, "Pco camera\nInterface: $(cam.interface)")
end

function open(cam::PcoCamera)
    cam_handle = try
        ref_cam_handle = Ref(C_NULL)
        ref_openstruct = Ref(PcoStruct.Openstruct(InterfaceType=WORD(cam.interface)))
        SDK.OpenCameraEx(ref_cam_handle, ref_openstruct)
        ref_cam_handle[]
    catch e
        if ~isa(e, Wrapper.CameraError)
            throw(e)
        end
        error("No camera found."*
        " Please check the connection and close other process which use the camera")
    end
    # set camera to default state
    try
        Wrapper.recording_state!(cam_handle,0)
        Wrapper.default!(cam_handle)
        Wrapper.arm(cam_handle)
    catch e
        if ~isa(e,Wrapper.CameraError)
            throw(e)
        end
        SDK.CloseCamera(can.cam_handle)
        error("The camera initialization has been failed\n--> $(e.msg)")
    end
    PcoCameraIOStream(name = Wrapper.name(cam_handle),
                      cam_handle = cam_handle,
                      roi = Wrapper.region_of_interest(cam_handle))
end

function close(cam::PcoCameraIOStream)
    if !isopen(cam)
        return
    end
    deactivate(cam)
    Wrapper.delete(cam.rec_handle)
    cam.rec_handle = C_NULL
    SDK.CloseCamera(cam.cam_handle)
    cam.cam_handle = C_NULL
    return
end

function isopen(cam::PcoCameraIOStream) 
    cam.cam_handle == C_NULL ? false : true
end

function region_of_interest(cam::PcoCameraIOStream)
    return getfield(cam, :roi)
end

function region_of_interest!(cam::PcoCameraIOStream,x_min,x_max,y_min,y_max)
    new_roi = NamedTuple{:x_min,:y_min,:x_max,:y_max}(x_min,x_max,y_min,y_max)
    setfield!(cam, :roi, new_roi)
    return cam
end

function trigger_mode(cam::PcoCameraIOStream)
    Wrapper.trigger_mode(cam.cam_handle)
end

function trigger_mode!(cam::PcoCameraIOStream,mode_name)
    Wrapper.trigger_mode!(cam.cam_handle,mode_name)
    Wrapper.arm(cam.cam_handle)
end

function timing_mode(cam::PcoCameraIOStream)
    Wrapper.timing_mode(cam.cam_handle)
end

const TIME_QUANTITY = Quantity{<:Number,Unitful.𝐓}
const FREQ_QUANTITY = Quantity{<:Number,Unitful.𝐓^-1}

function timing_mode!(cam::PcoCameraIOStream; exposure, delay=nothing, fps=nothing)
    @assert xor(isnothing(delay), isnothing(fps)) "Either `delay` or `fps` should be defined"
    timing_mode!(cam, something(delay, fps), exposure)
end

function timing_mode!(cam::PcoCameraIOStream, delay::TIME_QUANTITY, exposure::TIME_QUANTITY)
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
    SDK.SetDelayExposureTime(cam.cam_handle, delay_val, exposure_val, delay_unit, exposure_unit)
end

function timing_mode!(cam::PcoCameraIOStream, delay::Vector{<:TIME_QUANTITY}, exposure::Vector{<:TIME_QUANTITY})
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
    SDK.SetDelayExposureTimeTable(cam.cam_handle, delay_val, exposure_val, delay_unit, exposure_unit, count)
end

function timing_mode!(cam::PcoCameraIOStream, fps::FREQ_QUANTITY, exposure::TIME_QUANTITY)
    frame_rate_mode = WORD(3)
    ref_frame_rate_status = Ref(WORD(0))
    exposure_val = Ref(round(DWORD,uconvert(NoUnits, exposure/1u"ns")))
    fps_val = Ref(round(DWORD,uconvert(NoUnits, fps/1u"mHz")))
    SDK.SetFrameRate(cam.cam_handle, ref_frame_rate_status, frame_rate_mode, fps_val, exposure_val)
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

function buffer_mode(cam::PcoCameraIOStream)
    return cam.memory_type, cam.buffer_type, cam.number_of_images
end

function buffer_mode!(cam::PcoCameraIOStream, memory_type, buffer_type; number_of_images = cam.number_of_images)
    @assert number_of_images > 0 "Number of images is at least one"
    if memory_type == "file"
        available_buffer_type = Wrapper.RECORDER_MODE_FILE
    elseif memory_type == "memory"
        available_buffer_type = Wrapper.RECORDER_MODE_MEMORY
    elseif memory_type == "camram"
        available_buffer_type = Wrapper.RECORDER_MODE_CAMRAM
    else
        error("Available memory types are \"file\", \"memory\", and \"camram\".")
    end
    if buffer_type ∉ available_buffer_type
        error("Available memroy types for $(memory_type) are $(keys(available_buffer_type))")
    end
    cam.memory_type = memory_type
    cam.buffer_type = buffer_type
    cam.number_of_images = number_of_images
    cam
end

"""
Start Recording
"""
function activate(cam::PcoCameraIOStream)
    # Reset previous recorder handler
    if Wrapper.health(cam.cam_handle)["status"] & 2 == 0
        Wrapper.arm(cam.cam_handle)
    end
    deactivate(cam)
    Wrapper.delete(cam.rec_handle)
    # create handler
    cam.rec_handle, max_img_count = Wrapper.create(cam.cam_handle, cam.memory_type)
    @assert cam.number_of_images <= max_img_count "Maximum available images: $(max_img_count)"
    Wrapper.init(cam.rec_handle, cam.number_of_images, cam.memory_type, cam.buffer_type)
    Wrapper.start_record(cam.rec_handle)
end

function deactivate(cam::PcoCameraIOStream)
    Wrapper.stop_record(cam.rec_handle, cam.cam_handle)
end

isactivated(cam::PcoCameraIOStream) = cam.rec_handle != C_NULL && Wrapper.isactivated(cam.rec_handle, cam.cam_handle) == 1

function trigger(cam::PcoCameraIOStream)
    Wrapper.trigger(cam.cam_handle)
end

function wait(cam::PcoCameraIOStream, timeout = 10)
    start_time = now()
    while isactivated(cam)
        sleep(1e-3)
        if now() - start_time > Second(timeout)
            error("Timeout")
            break
        end
    end
end

function read(cam::PcoCameraIOStream)
    # copy image from the stack
    image = Wrapper.copy_image(cam.rec_handle, cam.cam_handle, cam.roi)
    return image
end