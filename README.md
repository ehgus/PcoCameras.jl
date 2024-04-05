# PcoCameras.jl

PcoCameras is a Julia interface for PCO cameras.
This package is based on a experimental IO framework [ExternalDeviceIOs.jl](https://github.com/ehgus/ExternalDeviceIOs.jl) and also offers direct access to low-level APIs of PCO cameras (PCO_SDK and PCO_Recorder).

There are packages offering similar features:
- [Ionimaging.jl](https://gitlab.com/mnkmr/Ionimaging.jl) is the first Julia package for PCO cameras. The following reasons have decided me to make this new package.
    - It does not work with GigE PCO cameras.
    - It searches for cameras available when loading the package. It is time-consuming and unnecessary for some purposes.
    - Camera API should be implemented consistently.
- [pco](https://pypi.org/project/pco/) is a offical python package. `PcoCameras.jl`'s internal structure is similar to the Python package.

## Installation

You need to pre-install pco.sdk and pco.recorder to use the package. The development kits are available on the [PCO website](https://www.pco-imaging.com/).
When installing the development kits, they should be installed system-wide for now.

It additionally requires `ExternalDeviceIOs`.Therefore, to install this package, you should type
```Julia REPL
julia> ]add https://github.com/ehgus/ExternalDeviceIOs.jl https://github.com/ehgus/PcoCameras.jl
```

## Example

```Julia
using PcoCameras
using Unitful

# PcoCameras.reset() # to reset the camera connection

# start camera
cam = PcoCamera(:GigE)
acquired_image = open(cam) do io
    @show trigger_mode(io)
    @show timing_mode(io)
    @show buffer_mode(io)
    trigger_mode!(io, "auto")
    timing_mode!(io, exposure = 100u"μs", delay = 0u"μs")
    buffer_mode!(io, "memory","sequence", number_of_images = 4)
    @show trigger_mode(io)
    @show timing_mode(io)
    @show buffer_mode(io)
    activate(io) do activated_io
        sleep(1)
        read(activated_io)
    end
end
```

## Shared library configuration
The default library path is set supposing you install the recent Recorder library for all users.
You can check and change the path using `get_library_path` and `set_library_path!`.
The directory should contains 'sc2_cam.dll' and 'pco_recorder.dll'.

```Julia
old_path = PcoCameras.get_library_path()
new_path = "some/dir/of/shared/library/"
PcoCameras.set_library_path!(new_path)
```

## Contribution

This package was tested only with GigE PCO cameras. If you face problems with your cameras, please report the issues.
