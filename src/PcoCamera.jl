using .Wrapper.TypeAlias

mutable struct PcoCamera <: Camera
    cam_handle::HANDLE
    rec_handle::HANDLE
    # camera type
    cam_name::String
    # camera configuration
    roi::NTuple{4,Integer}
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

function start!(cam::PcoCamera,number_of_images::Integer = 1,mode="sequence")
    # cam.record()
    if Wrapper.health(cam.cam_handle)["status"] & 2 == 0
        Wrapper.arm!(cam.cam_handle)
    end
    stop!(cam)
    Wrapper.delete(cam.rec_handle)
    cam.rec_handle, max_img_count = Wrapper.create(cam.cam_handle)
    @assert number_of_images <= max_img_count "Maximum available images: $(max_img_count)"
    Wrapper.init(cam.rec_handle,number_of_images,mode)
    Wrapper.start_record(cam.rec_handle)
end

function stop!(cam::PcoCamera)
    Wrapper.stop_record(cam.rec_handle, cam.cam_handle)
end

function take!(cam::PcoCamera)
    # cam.image()
    # copy image from the data
    Wrapper.wait_running(cam.rec_handle, cam.cam_handle)
    image = Wrapper.copy_image(cam.rec_handle, cam.cam_handle, cam.roi)
    return image
end

function trigger!(cam::PcoCamera)
    erorr("TODO level 2")
end
