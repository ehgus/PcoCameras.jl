# PcoCameras.jl

PcoCameras is a julia interface for PCO cameras.
This package is based on a generic camera framework [Cameras.jl](https://github.com/IHPSystems/Cameras.jl) and also offers direct access to low-level APIs of PCO cameras (PCO_SDK and PCO_Recorder).

There are packages offering similar features:
- [Ionimaging.jl](https://gitlab.com/mnkmr/Ionimaging.jl) is the first julia package for controlling PCO cameras. Two reasons decide me to make this new package.
    - It does not work with GigE PCO cameras.
    - It searches cameras available when loading the package. It is time-consuming and unnecessary for some purpose.
    - I suggest Julia community provides camera APIs following some standard.
- [pco](https://pypi.org/project/pco/) is a offical API wrapper. This package's internal structure is similar to this python package.

## Installation

You need to pre-install pco.sdk and pco.recorder to use the package. The developments kits are available in the [PCO website](https://www.pco-imaging.com/).
When installing the development kits, they should be installed in system-wide for now.

## Example (High-level API)

```julia
using PcoCameras

# If you want to reset connection,execute the following command
# PcoCameras.reset()

# start camera
cam = PcoCamera("GigE")
open!(cam)

# configure options
trigger_mode!(cam, "auto")
@show trigger_mode(cam)

# start acquisition
number_of_images = 4
mode="fifo"
start!(cam, number_of_images, mode)

# take acquisition
acquired_image = take!(cam)

# stop acquisition
stop!(cam)

# close camera
close!(cam)
```

## Example (Low-level API)

Examples are on `example/` directory.


## Contribution

This package was tested only with GigE PCO cameras. If you face problems with your cameras, please report the issues.
