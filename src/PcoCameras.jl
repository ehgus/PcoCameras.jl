module PcoCameras

using Reexport
using VariableIOs
using VariableIOs.VariableArrayIOs
using StaticArrays
using Dates

@reexport import VariableIOs:
    activate,
    deactivate,
    isactivated,
    trigger_mode,
    trigger_mode!,
    buffer_mode,
    buffer_mode!,
    buffer_size,
    buffer_size!,
    trigger

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
