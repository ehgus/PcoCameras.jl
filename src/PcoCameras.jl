module PcoCameras

using Reexport
using Unitful
using ExternalDeviceIOs
@reexport import ExternalDeviceIOs: activate, deactivate, isactivated
@reexport import ExternalDeviceIOs.Timing: timing_mode, timing_mode!
@reexport import ExternalDeviceIOs.Trigger: trigger_mode, trigger_mode!, trigger
@reexport import ExternalDeviceIOs.Buffer: buffer_mode, buffer_mode!
@reexport import ExternalDeviceIOs.ArrayedDevice: region_of_interest, region_of_interest!

import Base:
    show,
    open,
    close,    
    isopen,
    # while execution
    wait,
    read
export PcoCamera

include("API/wrapper.jl")
include("camera.jl")

end # module PcoCameras
