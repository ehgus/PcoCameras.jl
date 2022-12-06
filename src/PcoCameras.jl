module PcoCameras

using Cameras

import Cameras:
    isopen,
    open!,
    close!,
    isrunning,
    start!,
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
