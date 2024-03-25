module PcoCameras

using Reexport
using VariableIOs
using VariableIOs.VariableArrayIOs
using Dates

@reexport import VariableIOs:
    activate,
    deactivate,
    isactivated,
    trigger_mode,
    trigger_mode!,
    timing_mode,
    timing_mode!,
    buffer_mode,
    buffer_mode!,
    trigger

@reexport import VariableIOs.VariableArrayIOs:
    region_of_interest,
    region_of_interest!

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
