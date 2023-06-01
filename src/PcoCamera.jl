using .Wrapper.TypeAlias
using .Wrapper: INTERFACE_DICT, reset

mutable struct PcoCamera <: Camera
    cam_handle::HANDLE
    rec_handle::HANDLE
    # camera type
    interface::String
    cam_name::String
    # camera configuration
    roi::MVector{4, UInt16}
    # logging
    timestamp::Bool

    function PcoCamera(interface::String,timestamp=false)
        # check interface
        if !haskey(INTERFACE_DICT, interface)
            @error("Available interfaces are $(join(keys(INTERFACE_DICT), ", "))")
        end
        if timestamp
            @warn("Timestamping is not yet implemented yet")
        end
        cam_name = ""
        roi = @MVector zeros(WORD,4)
        new(HANDLE(0), HANDLE(0), interface, cam_name, roi, timestamp)
    end
end

function info(cam::PcoCamera)
    @info("Camera name: $(cam.cam_name)\n"*
        "Interface: $(cam.interface)\n"*
        "ROI: X = [$(cam.roi[1]), $(cam.roi[3])], Y = [$(cam.roi[2]), $(cam.roi[4])]")
end

function isopen(cam::PcoCamera) 
    cam.cam_handle == HANDLE(0) ? false : true
end

function open!(cam::PcoCamera)
    if isopen(cam)
        return cam
    end

    cam_handle = try
        Wrapper.open(cam.interface)
    catch e
        if ~isa(e, Wrapper.CameraError)
            throw(e)
        end
        @error("No camera found."*
        " Please check the connection and close other process which use the camera")
    end
    # set camera to default state
    try
        Wrapper.recording_state!(cam_handle,0)
        Wrapper.default!(cam_handle)
        Wrapper.delay_exposure(cam_handle, 0, 10)
        Wrapper.arm!(cam_handle)
    catch e
        if ~isa(e,Wrapper.CameraError)
            throw(e)
        end
        Wrapper.close(cam_handle)
        @error("The camera initialization has been failed\n--> $(e.msg)")
    end
    # return PcoCamera 
    cam.cam_handle = cam_handle
    cam.cam_name = Wrapper.name(cam_handle)
    cam.roi = Wrapper.roi(cam_handle)
    return cam
end

function close!(cam::PcoCamera)
    if !isopen(cam)
        return
    end
    stop!(cam)
    Wrapper.delete(cam.rec_handle)
    cam.rec_handle = HANDLE(0)
    Wrapper.close!(cam.cam_handle)
    cam.cam_handle = HANDLE(0)
    return
end

"""
Start Recording
"""
function start!(cam::PcoCamera,number_of_images::Integer = 1,mode="sequence")
    # Reset previous recorder handler
    if Wrapper.health(cam.cam_handle)["status"] & 2 == 0
        Wrapper.arm!(cam.cam_handle)
    end
    stop!(cam)
    Wrapper.delete(cam.rec_handle)
    # create handler
    cam.rec_handle, max_img_count = Wrapper.create(cam.cam_handle)
    @assert number_of_images <= max_img_count "Maximum available images: $(max_img_count)"
    Wrapper.init(cam.rec_handle,number_of_images,mode)
    Wrapper.start_record(cam.rec_handle)
end

function stop!(cam::PcoCamera)
    Wrapper.stop_record(cam.rec_handle, cam.cam_handle)
end

function wait(cam::PcoCamera, timeout = 10)
    start_time = now()
    while isrunning(cam)
        sleep(1e-3)
        if now() - start_time > Second(timeout)
            @error("Timeout")
            break
        end
    end
end

isrunning(cam::PcoCamera) = Wrapper.isrunning(cam.rec_handle, cam.cam_handle) == 1

function take!(cam::PcoCamera)
    # copy image from the stack
    image = Wrapper.copy_image(cam.rec_handle, cam.cam_handle, cam.roi)
    return AcquiredImage(image, 0, 0)
end

function trigger_mode(cam::PcoCamera)
    Wrapper.trigger_mode(cam.cam_handle)
end

function trigger_mode!(cam::PcoCamera,mode_name)
    Wrapper.trigger_mode!(cam.cam_handle,mode_name)
end

function trigger!(cam::PcoCamera)
    Wrapper.trigger!(cam.cam_handle)
end
