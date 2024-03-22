module PcoCameras

using Reexport
@reexport using VariableIOs
@reexport using VariableIOs.VariableArrayIOs
using StaticArrays
using Dates

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
