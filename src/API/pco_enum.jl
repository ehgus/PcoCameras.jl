module PcoEnum

using ..TypeAlias
using EnumX
export InterfaceType, TriggerMode,
    RecorderModeFile,
    RecorderModeMemory,
    RecorderModeCamram,
    RecorderModeType

@enumx InterfaceType::WORD begin
    FireWire = 1
    GigE = 5
    USB_2_0 = 6
    Camera_Link_Silicon_Software = 7
    USB_3_0 = 8
    CLHS = 11
    Any = 0xFFFF
end

end