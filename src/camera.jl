using .Wrapper.TypeAlias
using .Wrapper: INTERFACE_DICT, reset

struct PcoCamera <: IODeviceName
    interface::String
    function PcoCamera(interface)
        # check interface
        if !haskey(INTERFACE_DICT, interface)
            error("Available interfaces are $(join(keys(INTERFACE_DICT), ", "))")
        end
        new(interface)
    end
end

@kwdef mutable struct PcoCameraIOStream <: VariableArrayIOStream
    name::String = ""
    # handler
    cam_handle::HANDLE = HANDLE(0)
    rec_handle::HANDLE = HANDLE(0)
    # camera configuration
    roi::MVector{4, UInt16} = @MVector zeros(WORD,4)
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
        Wrapper.open(cam.interface)
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
        Wrapper.arm!(cam_handle)
    catch e
        if ~isa(e,Wrapper.CameraError)
            throw(e)
        end
        Wrapper.close(cam_handle)
        error("The camera initialization has been failed\n--> $(e.msg)")
    end
    PcoCameraIOStream(name = Wrapper.name(cam_handle),
                      cam_handle = cam_handle,
                      roi = Wrapper.roi(cam_handle))
end

function close(cam::PcoCameraIOStream)
    if !isopen(cam)
        return
    end
    deactivate(cam)
    Wrapper.delete(cam.rec_handle)
    cam.rec_handle = HANDLE(0)
    Wrapper.close(cam.cam_handle)
    cam.cam_handle = HANDLE(0)
    return
end

function isopen(cam::PcoCameraIOStream) 
    cam.cam_handle == HANDLE(0) ? false : true
end

function trigger_mode(cam::PcoCameraIOStream)
    Wrapper.trigger_mode(cam.cam_handle)
end

function trigger_mode!(cam::PcoCameraIOStream,mode_name)
    Wrapper.trigger_mode!(cam.cam_handle,mode_name)
end

function buffer_mode(cam::PcoCameraIOStream)
    return cam.memory_type, cam.buffer_type
end

function buffer_mode!(cam::PcoCameraIOStream, memory_type, buffer_type)
    if memory_type == "file"
        available_buffer_type = Wrapper.RECORDER_MODE_FILE
    elseif memory_type == "memory"
        available_buffer_type = Wrapper.RECORDER_MODE_MEMORY
    elseif memory_type == "camram"
        available_buffer_type = Wrapper.RECORDER_MODE_CAMRAM
    else
        error("Available memory types are \"file\", \"memory\", and \"camram\".")
    end
    if !haskey(available_buffer_type, buffer_type)
        error("Available memroy types for $(memory_type) are $(keys(available_buffer_type))")
    end
    cam.memory_type = memory_type
    cam.buffer_type = buffer_type
    cam
end

function buffer_size(cam::PcoCameraIOStream)
    return cam.number_of_images
end

function buffer_size!(cam::PcoCameraIOStream; number_of_images)
    @assert number_of_images > 0 "Number of images is at least one"
    cam.number_of_images = number_of_images
    cam
end

"""
Start Recording
"""
function activate(cam::PcoCameraIOStream)
    # Reset previous recorder handler
    if Wrapper.health(cam.cam_handle)["status"] & 2 == 0
        Wrapper.arm!(cam.cam_handle)
    end
    deactivate(cam)
    Wrapper.delete(cam.rec_handle)
    # create handler
    cam.rec_handle, max_img_count = Wrapper.create(cam.cam_handle, cam.memory_type)
    @assert cam.number_of_images <= max_img_count "Maximum available images: $(max_img_count)"
    Wrapper.init(cam.rec_handle,cam.number_of_images,cam.buffer_type)
    Wrapper.start_record(cam.rec_handle)
end

function deactivate(cam::PcoCameraIOStream)
    Wrapper.stop_record(cam.rec_handle, cam.cam_handle)
end

isactivated(cam::PcoCameraIOStream) = Wrapper.isactivated(cam.rec_handle, cam.cam_handle) == 1

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