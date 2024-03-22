# PcoCameras.jl

PcoCameras is a Julia interface for PCO cameras.
This package is based on a experimental IO framework [VariableIOs.jl](https://github.com/ehgus/VariableIOs.jl) and also offers direct access to low-level APIs of PCO cameras (PCO_SDK and PCO_Recorder).

There are packages offering similar features:
- [Ionimaging.jl](https://gitlab.com/mnkmr/Ionimaging.jl) is the first Julia package for PCO cameras. The following reasons have decided me to make this new package.
    - It does not work with GigE PCO cameras.
    - It searches for cameras available when loading the package. It is time-consuming and unnecessary for some purposes.
    - Camera API should be implemented consistently.
- [pco](https://pypi.org/project/pco/) is a offical python package. `PcoCameras.jl`'s internal structure is similar to the Python package.

## Installation

You need to pre-install pco.sdk and pco.recorder to use the package. The development kits are available on the [PCO website](https://www.pco-imaging.com/).
When installing the development kits, they should be installed system-wide for now.

It additionally requires `VariableIOs`.Therefore, to install this package, you should type
```Julia REPL
julia> ]add https://github.com/ehgus/VariableIOs.jl https://github.com/ehgus/PcoCameras.jl
```

## Example (High-level API)

```Julia
using PcoCameras

# If you want to reset the connection, execute the following command
# PcoCameras.reset()

# start camera
cam = PcoCamera("GigE")
cam_io = open(cam)

# configure options
trigger_mode!(cam_io, "auto")
@show trigger_mode(cam_io)

# start acquisition
buffer_mode!(cam_io, "memory","fifo")
buffer_size!(cam_io, number_of_images = 4)
activate(cam_io)

# take acquisition
acquired_image = read(cam_io)

# stop acquisition
deactivate(cam_io)

# Close camera
close(cam_io)
```

## Example (Low-level API)

Examples are on the `example/` directory.


## Contribution

This package was tested only with GigE PCO cameras. If you face problems with your cameras, please report the issues.
