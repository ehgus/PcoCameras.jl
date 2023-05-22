module PcoCameras

using Cameras
using StaticArrays

import Cameras:
    isopen,
    open!,
    close!,
    isrunning,
    start!,
    wait,
    stop!,
    take!,
    trigger!,
    id,
    timestamp

export PcoCamera,
    isopen,
    open!,
    close!,
    isrunning,
    start!,
    stop!,
    take!,
    trigger_mode,
    trigger_mode!,
    trigger!

include("API/Wrapper.jl")
include("PcoCamera.jl")

end # module PcoCameras
