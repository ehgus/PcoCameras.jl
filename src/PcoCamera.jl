using .Wrapper.TypeAlias
using .Wrapper: reset!

mutable struct PcoCamera <: Camera
    cam_handle::HANDLE
    rec_handle::HANDLE
    # camera type
    cam_name::String
    # camera configuration
    roi::MVector{4, UInt16}
    # logging
    debugLv::String
    timestamp::Bool

    function PcoCamera(interface::String,debugLv="off",timestamp=false)
        # try connecting available camera
        cam_handle = try
            Wrapper.open(interface)
        catch e
            if ~isa(e,Wrapper.CameraError)
                throw(e)
            end
            error("No camera found."*
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
            error("The camera initialization has been failed\n--> $(e.msg)")
        end
        # return PcoCamera
        cam_name = Wrapper.name(cam_handle)
        roi = Wrapper.roi(cam_handle)
        new(cam_handle,HANDLE(0), cam_name,
            roi,#exposure_time, trigger, binning, 
            debugLv,timestamp)
    end
end


function info(cam::PcoCamera)
    erorr("TODO")
end

function isopen(cam::PcoCamera) 
    cam.cam_handle == HANDLE(0) ? false : true
end

function open!(cam::PcoCamera)
    if isopen(cam)
        return cam
    end

    erorr("TODO")
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
    while Wrapper.isrunning(cam.rec_handle, cam.cam_handle) == 1
        sleep(1e-3)
        if now() - start_time > Second(10)
            error("Timeout")
        end
    end
end

function take!(cam::PcoCamera)
    # copy image from the stack
    image = Wrapper.copy_image(cam.rec_handle, cam.cam_handle, cam.roi)
    return image
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
