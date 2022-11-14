module SDK

using ..PcoStruct
using ..TypeAlias
import Libdl: dlopen, dlsym

dir_path = "C:/Program Files/PCO Digital Camera Toolbox/pco.recorder/bin64"

const SDK_DLL = Ref{Ptr{Cvoid}}(0)
function __init__()
    SDK_DLL[] = dlopen(joinpath(dir_path,"SC2_Cam.dll"))
end

# ----------------------------------------------------------------------
#    CAMERA ACCESS
# ----------------------------------------------------------------------

function OpenCamera(ph, CamNum)
    F = dlsym(SDK_DLL[], :PCO_OpenCamera)
    ccall(F, Cuint, (Ptr{HANDLE}, WORD), ph, CamNum)
end


function OpenCameraEx(ph, OpenStruct)
    F = dlsym(SDK_DLL[], :PCO_OpenCameraEx)
    ccall(F, Cuint, (Ptr{HANDLE}, Ptr{Openstruct}), ph, OpenStruct)
end


function CloseCamera(ph)
    F = dlsym(SDK_DLL[], :PCO_CloseCamera)
    ccall(F, Cuint, (HANDLE,), ph)
end


function ResetLib()
    F = dlsym(SDK_DLL[], :PCO_ResetLib)
    ccall(F, Cuint, ())
end


function CheckDeviceAvailability(ph, NumIf)
    F = dlsym(SDK_DLL[], :PCO_CheckDeviceAvailability)
    ccall(F, Cuint, (HANDLE, WORD), ph, NumIf)
end


# ----------------------------------------------------------------------
#    CAMERA DESCRIPTION
# ----------------------------------------------------------------------

function GetCameraDescription(ph, description)
    F = dlsym(SDK_DLL[], :PCO_GetCameraDescription)
    ccall(F, Cuint, (HANDLE, Ptr{Description}), ph, description)
end


function GetCameraDescriptionEx(ph, description, Type)
    F = dlsym(SDK_DLL[], :PCO_GetCameraDescriptionEx)
    ccall(F, Cuint, (HANDLE, Ptr{Description}, WORD), ph, description, Type)
end


# ----------------------------------------------------------------------
#    GENERAL CAMERA STATUS
# ----------------------------------------------------------------------

function GetGeneral(ph, General)
    F = dlsym(SDK_DLL[], :PCO_GetGeneral)
    ccall(F, Cuint, (HANDLE, Ptr{Description}), ph, General)
end


function GetCameraType(ph, CamType)
    F = dlsym(SDK_DLL[], :PCO_GetCameraType)
    ccall(F, Cuint, (HANDLE, Ptr{CameraType}), ph, CamType)
end


function GetCameraHealthStatus(ph, Warn, Err, Status)
    F = dlsym(SDK_DLL[], :PCO_GetCameraHealthStatus)
    ccall(F, Cuint, (HANDLE, Ptr{DWORD}, Ptr{DWORD}, Ptr{DWORD}),
          ph, Warn, Err, Status)
end


function GetTemperature(ph, CCDTemp, CamTemp, PowTemp)
    F = dlsym(SDK_DLL[], :PCO_GetTemperature)
    ccall(F, Cuint, (HANDLE, Ptr{SHORT}, Ptr{SHORT}, Ptr{SHORT}),
          ph, CCDTemp, CamTemp, PowTemp)
end


function GetInfoString(ph, infotype, buf, size_in)
    F = dlsym(SDK_DLL[], :PCO_GetInfoString)
    ccall(F, Cuint, (HANDLE, DWORD, Ptr{Cchar}, WORD),
          ph, infotype, buf, size_in)
end


function GetCameraName(ph, CameraName, CameraNameLen)
    F = dlsym(SDK_DLL[], :PCO_GetCameraName)
    ccall(F, Cuint, (HANDLE, Ptr{Cchar}, WORD),
          ph, CameraName, CameraNameLen)
end


function GetFirmwareInfo(ph, DeviceBlock, FirmWareVersion)
    F = dlsym(SDK_DLL[], :PCO_GetFirmwareInfo)
    ccall(F, Cuint, (HANDLE, WORD, Ptr{FW_Vers}),
          ph, DeviceBlock, FirmWareVersion)
end


function GetColorCorrectionMatrix(ph, Matrix)
    F = dlsym(SDK_DLL[], :PCO_GetColorCorrectionMatrix)
    ccall(F, Cuint, (HANDLE, Ptr{Cdouble}), ph, Matrix)
end


# ----------------------------------------------------------------------
#    GENERAL CAMERA CONTROL
# ----------------------------------------------------------------------

function ArmCamera(ph)
    F = dlsym(SDK_DLL[], :PCO_ArmCamera)
    ccall(F, Cuint, (HANDLE,), ph)
end


function SetImageParameters(ph, xres, yres, Flags, param, ilen)
    F = dlsym(SDK_DLL[], :PCO_SetImageParameters)
    ccall(F, Cuint, (HANDLE, WORD, WORD, DWORD, Ptr{Cvoid}, Cint),
          ph, xres, yres, Flags, param, ilen)
end


function ResetSettingsToDefault(ph)
    F = dlsym(SDK_DLL[], :PCO_ResetSettingsToDefault)
    ccall(F, Cuint, (HANDLE,), ph)
end


function SetTimeouts(ph, buf_in, size_in)
    F = dlsym(SDK_DLL[], :PCO_SetTimeouts)
    ccall(F, Cuint, (HANDLE, Ptr{Cvoid}, Cuint), ph, buf_in, size_in)
end


function RebootCamera(ph)
    F = dlsym(SDK_DLL[], :PCO_RebootCamera)
    ccall(F, Cuint, (HANDLE,), ph)
end


function GetCameraSetup(ph, Type, Setup, Len)
    F = dlsym(SDK_DLL[], :PCO_GetCameraSetup)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{DWORD}, Ptr{WORD}),
          ph, Type, Setup, Len)
end


function SetCameraSetup(ph, Type, Setup, Len)
    F = dlsym(SDK_DLL[], :PCO_SetCameraSetup)
    ccall(F, Cuint, (HANDLE, WORD, Ptr{DWORD}, WORD),
          ph, Type, Setup, Len)
end


# ----------------------------------------------------------------------
#    IMAGE SENSOR
# ----------------------------------------------------------------------

function GetSizes(ph, XResAct, YResAct, XResMax, YResMax)
    F = dlsym(SDK_DLL[], :PCO_GetSizes)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}),
          ph, XResAct, YResAct, XResMax, YResMax)
end


function GetSensorFormat(ph, Sensor)
    F = dlsym(SDK_DLL[], :PCO_GetSensorFormat)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, Sensor)
end


function SetSensorFormat(ph, Sensor)
    F = dlsym(SDK_DLL[], :PCO_SetSensorFormat)
    ccall(F, Cuint, (HANDLE, WORD), ph, Sensor)
end


function GetROI(ph, RoiX0, RoiY0, RoiX1, RoiY1)
    F = dlsym(SDK_DLL[], :PCO_GetROI)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}),
          ph, RoiX0, RoiY0, RoiX1, RoiY1)
end


function SetROI(ph, RoiX0, RoiY0, RoiX1,
                wRoiY1)
    F = dlsym(SDK_DLL[], :PCO_SetROI)
    ccall(F, Cuint, (HANDLE, WORD, WORD, WORD, WORD),
          ph, RoiX0, RoiY0, RoiX1, RoiY1)
end


function GetBinning(ph, BinHorz, BinVert)
    F = dlsym(SDK_DLL[], :PCO_GetBinning)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{WORD}), ph, BinHorz, BinVert)
end


function SetBinning(ph, BinHorz, BinVert)
    F = dlsym(SDK_DLL[], :PCO_SetBinning)
    ccall(F, Cuint, (HANDLE, WORD, WORD), ph, BinHorz, BinVert)
end


function GetPixelRate(ph, PixelRate)
    F = dlsym(SDK_DLL[], :PCO_GetPixelRate)
    ccall(F, Cuint, (HANDLE, Ptr{DWORD}), ph, PixelRate)
end


function SetPixelRate(ph, PixelRate)
    F = dlsym(SDK_DLL[], :PCO_SetPixelRate)
    ccall(F, Cuint, (HANDLE, DWORD), ph, PixelRate)
end


function GetConversionFactor(ph, ConvFact)
    F = dlsym(SDK_DLL[], :PCO_GetConversionFactor)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, ConvFact)
end


function SetConversionFactor(ph, ConvFact)
    F = dlsym(SDK_DLL[], :PCO_SetConversionFactor)
    ccall(F, Cuint, (HANDLE, WORD), ph, ConvFact)
end


function GetIRSensitivity(ph, IR)
    F = dlsym(SDK_DLL[], :PCO_GetIRSensitivity)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, IR)
end


function SetIRSensitivity(ph, IR)
    F = dlsym(SDK_DLL[], :PCO_SetIRSensitivity)
    ccall(F, Cuint, (HANDLE, WORD), ph, IR)
end


# ----------------------------------------------------------------------
#    TIMING CONTROL
# ----------------------------------------------------------------------

function GetDelayExposureTime(ph, Delay, Exposure, TimeBaseDelay, TimeBaseExposure)
    F = dlsym(SDK_DLL[], :PCO_GetDelayExposureTime)
    ccall(F, Cuint, (HANDLE, Ptr{DWORD}, Ptr{DWORD}, Ptr{WORD}, Ptr{WORD}),
          ph, Delay, Exposure, TimeBaseDelay, TimeBaseExposure)
end


function SetDelayExposureTime(ph, Delay, Exposure, TimeBaseDelay, TimeBaseExposure)
    F = dlsym(SDK_DLL[], :PCO_SetDelayExposureTime)
    ccall(F, Cuint, (HANDLE, DWORD, DWORD, WORD, WORD),
          ph, Delay, Exposure, TimeBaseDelay, TimeBaseExposure)
end

function GetFrameRate(ph, FrameRateStatus, FrameRate, FrameRateExposure)
    F = dlsym(SDK_DLL[], :PCO_GetFrameRate)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{DWORD}, Ptr{DWORD}),
          ph, FrameRateStatus, FrameRate, FrameRateExposure)
end


function SetFrameRate(ph, FrameRateStatus, FrameRateMode, FrameRate, FrameRateExposure)
    F = dlsym(SDK_DLL[], :PCO_SetFrameRate)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}, WORD, Ptr{DWORD}, Ptr{DWORD}),
          ph, FrameRateStatus, FrameRateMode, FrameRate, FrameRateExposure)
end


function GetTriggerMode(ph, TriggerMode)
    F = dlsym(SDK_DLL[], :PCO_GetTriggerMode)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, TriggerMode)
end


function SetTriggerMode(ph, TriggerMode)
    F = dlsym(SDK_DLL[], :PCO_SetTriggerMode)
    ccall(F, Cuint, (HANDLE, WORD), ph, TriggerMode)
end


function ForceTrigger(ph, Triggered)
    F = dlsym(SDK_DLL[], :PCO_ForceTrigger)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, Triggered)
end


function GetExpTrigSignalStatus(ph, ExpTrgSignal)
    F = dlsym(SDK_DLL[], :PCO_GetExpTrigSignalStatus)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, ExpTrgSignal)
end

function GetFastTimingMode(ph, FastTimingMode)
    F = dlsym(SDK_DLL[], :PCO_GetFastTimingMode)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, FastTimingMode)
end

function SetFastTimingMode(ph, FastTimingMode)
    F = dlsym(SDK_DLL[], :PCO_SetFastTimingMode)
    ccall(F, Cuint, (HANDLE, WORD), ph, FastTimingMode)
end


# ----------------------------------------------------------------------
#    RECORDING CONTROL
# ----------------------------------------------------------------------

function GetRecordingState(ph, RecState)
    F = dlsym(SDK_DLL[], :PCO_GetRecordingState)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, RecState)
end


function SetRecordingState(ph, RecState)
    F = dlsym(SDK_DLL[], :PCO_SetRecordingState)
    ccall(F, Cuint, (HANDLE, WORD), ph, RecState)
end


function GetAcquireMode(ph, AcquMode)
    F = dlsym(SDK_DLL[], :PCO_GetAcquireMode)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, AcquMode)
end


function SetAcquireMode(ph, AcquMode)
    F = dlsym(SDK_DLL[], :PCO_SetAcquireMode)
    ccall(F, Cuint, (HANDLE, WORD), ph, AcquMode)
end


function GetMetaDataMode(ph, MetaDataMode, MetaDataSize, MetaDataVersion)
    F = dlsym(SDK_DLL[], :PCO_GetMetaDataMode)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}),
     ph, MetaDataMode, MetaDataSize, MetaDataVersion)
end


function SetMetaDataMode(ph, MetaDataMode, MetaDataSize, MetaDataVersion)
    F = dlsym(SDK_DLL[], :PCO_SetMetaDataMode)
    ccall(F, Cuint, (HANDLE, WORD, Ptr{WORD}, Ptr{WORD}),
     ph, MetaDataMode, MetaDataSize, MetaDataVersion)
end




function GetTimestampMode(ph, TimeStampMode)
    F = dlsym(SDK_DLL[], :PCO_GetTimestampMode)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, TimeStampMode)
end


function SetTimestampMode(ph, TimeStampMode)
    F = dlsym(SDK_DLL[], :PCO_SetTimestampMode)
    ccall(F, Cuint, (HANDLE, WORD), ph, TimeStampMode)
end


# ----------------------------------------------------------------------
#    IMAGE INFORMATION
# ----------------------------------------------------------------------

function GetBitAlignment(ph, BitAlignment)
    F = dlsym(SDK_DLL[], :PCO_GetBitAlignment)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, BitAlignment)
end


function SetBitAlignment(ph, BitAlignment)
    F = dlsym(SDK_DLL[], :PCO_SetBitAlignment)
    ccall(F, Cuint, (HANDLE, WORD), ph, BitAlignment)
end


function GetHotPixelCorrectionMode(ph, HotPixelCorrectionMode)
    F = dlsym(SDK_DLL[], :PCO_GetHotPixelCorrectionMode)
    ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, HotPixelCorrectionMode)
end


function SetHotPixelCorrectionMode(ph, HotPixelCorrectionMode)
    F = dlsym(SDK_DLL[], :PCO_SetHotPixelCorrectionMode)
    ccall(F, Cuint, (HANDLE, WORD), ph, HotPixelCorrectionMode)
end


# ----------------------------------------------------------------------
#    BUFFER MANAGEMENT
# ----------------------------------------------------------------------

function AllocateBuffer(ph, sBufNr, Size, Buf, hEvent)
    F = dlsym(SDK_DLL[], :PCO_AllocateBuffer)
    ccall(F, Cuint, (HANDLE, Ptr{SHORT}, DWORD, Ptr{Ptr{WORD}}, Ptr{HANDLE}),
          ph, sBufNr, Size, Buf, hEvent)
end


function FreeBuffer(ph, BufNr)
    F = dlsym(SDK_DLL[], :PCO_FreeBuffer)
    ccall(F, Cuint, (HANDLE, SHORT), ph, BufNr)
end


function GetBufferStatus(ph, BufNr, StatusDLL, StatusDrv)
    F = dlsym(SDK_DLL[], :PCO_GetBufferStatus)
    ccall(F, Cuint, (HANDLE, SHORT, Ptr{DWORD}, Ptr{DWORD}),
          ph, BufNr, StatusDLL, StatusDrv)
end


# ----------------------------------------------------------------------
#    IMAGE ACQUISITION
# ----------------------------------------------------------------------

function GetImageEx(ph, Segment, FirstImage,
                    LastImage, BufNr, XRes,
                    wYRes, BitPerPixel)
    F = dlsym(SDK_DLL[], :PCO_GetImageEx)
    ccall(F, Cuint, (HANDLE, WORD, DWORD, DWORD, SHORT, WORD, WORD, WORD),
          ph, Segment, FirstImage, LastImage, BufNr, XRes, YRes,
          wBitPerPixel)
end


function AddBufferEx(ph, FirstImage, LastImage,
                     sBufNr, XRes, YRes,
                     wBitPerPixel)
    F = dlsym(SDK_DLL[], :PCO_AddBufferEx)
    ccall(F, Cuint, (HANDLE, DWORD, DWORD, SHORT, WORD, WORD, WORD),
          ph, FirstImage, LastImage, BufNr, XRes, YRes, BitPerPixel)
end


function CancelImages(ph)
    F = dlsym(SDK_DLL[], :PCO_CancelImages)
    ccall(F, Cuint, (HANDLE,), ph)
end


function GetPendingBuffer(ph)
    n = Vector{Cint}(undef, 1)
    F = dlsym(SDK_DLL[], :PCO_GetPendingBuffer)
    ccall(F, Cuint, (HANDLE, Ptr{Cint}), ph, n)
end


function WaitforBuffer(ph, nr_of_buffer, bl, timeout)
    F = dlsym(SDK_DLL[], :PCO_WaitforBuffer)
    ccall(F, Cuint, (HANDLE, INT, Ptr{Buflist}, Cint),
          ph, nr_of_buffer, bl, timeout)
end


# ----------------------------------------------------------------------
#    DEBUG
# ----------------------------------------------------------------------

function GetErrorTextSDK(Error::DWORD, ErrorString, ErrorStringLength)
    F = dlsym(SDK_DLL[], :PCO_GetErrorTextSDK)
    ccall(F, Cvoid, (DWORD, Ptr{Cchar}, DWORD),
          Error, ErrorString, ErrorStringLength)
end

end