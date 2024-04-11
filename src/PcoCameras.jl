module PcoCameras

using Reexport
using Preferences
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
export Interface, TriggerMode, FileRecorder, MemoryRecorder, CamramRecorder

# path manager using Preference.jl
include("shared_library_manager.jl")
# low-level API
include("API/alias.jl")
using .Alias
include("API/pco_struct.jl")
include("API/pco_sc2_cam_lib.jl")
include("API/pco_recorder_lib.jl")
# high-level API
include("camera.jl")

end # module PcoCameras
