module Alias

# Type alias
export VOID, HANDLE, SHORT, INT, LONG, WORD, DWORD, BYTE, bool, BOOL

const VOID = Cvoid
const HANDLE = Ptr{VOID}
const SHORT = Cshort
const INT = Cint
const LONG = Clong
const WORD = Cushort
const DWORD = Culong
const BYTE = Cuchar
const bool = Cuchar
const BOOL = Cint

# Map of values
using EnumX
import Base: UInt8, UInt16, UInt32
export Interface, TriggerMode, FileRecorder, MemoryRecorder, CamramRecorder,
    RecorderMode

@enumx Interface::WORD begin
    FireWire = 1
    Matrox = 2
    Genicam = 3
    National_Instruments = 4
    GigE = 5
    USB_2_0 = 6
    Silicon_Software_mEIV = 7
    USB_3_0 = 8
    Serial_Port = 10
    CLHS = 11
    Any = 0xFFFF
end

@enumx TriggerMode::WORD begin
    automatic = 0
    software_trigger = 1
    hardware_trigger = 2
    hardware_control = 3
    hardware_synchronized = 4
    fast_hardware_control = 5
    CDS_control = 6
    slow_hardware_control = 7
    HDSDI = 0x0102
end

@enumx FileRecorder::WORD begin
    tif = 1
    multi_tif = 2
    pco_raw = 3
    b16 = 4
    dicom = 5
    multi_dicom = 6
end
UInt8(::Type{FileRecorder.T}) = UInt8(1)
UInt16(::Type{FileRecorder.T}) = UInt16(1)
UInt32(::Type{FileRecorder.T}) = UInt32(1)

@enumx MemoryRecorder::WORD begin
    sequence = 1
    ring_buffer = 2
    fifo = 3
end
UInt8(::Type{MemoryRecorder.T}) = UInt8(2)
UInt16(::Type{MemoryRecorder.T}) = UInt16(2)
UInt32(::Type{MemoryRecorder.T}) = UInt32(2)

@enumx CamramRecorder::WORD begin
    sequential = 1
    single_image = 2
end
UInt8(::Type{CamramRecorder.T}) = UInt8(3)
UInt16(::Type{CamramRecorder.T}) = UInt16(3)
UInt32(::Type{CamramRecorder.T}) = UInt32(3)

const RecorderMode = Union{FileRecorder.T, MemoryRecorder.T, CamramRecorder.T}

end # module Alias