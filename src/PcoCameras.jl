module PcoCameras

using Cameras
using StaticArrays
using Dates

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

include("API/wrapper.jl")
include("camera.jl")

end # module PcoCameras
