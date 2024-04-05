module SDK

using ..PcoStruct
using ..TypeAlias
import Libdl: dlopen, dlclose, dlsym

dir_path = "C:/Program Files/PCO Digital Camera Toolbox/pco.recorder/bin/sc2_cam.dll"

const SDK_DLL = Ref{Ptr{Cvoid}}(0)
function __init__()
    SDK_DLL[] = dlopen(dir_path)
    finalizer((x->dlclose(x[])),SDK_DLL)
end

struct CameraError <: Exception
    msg::String
end

function errortext(rc)
    len = DWORD(200)
    txt = Vector{Cchar}(undef, len)
    GetErrorTextSDK(rc, txt, len)
    txt[end] = 0
    unsafe_string(pointer(txt))
end

macro rccheck(expr)
    (Meta.isexpr(expr,:ccall) && expr.args[1] === :ccall && expr.args[3] === :Cuint) || "invalid use of @rccheck"
    return quote
        rc = $(esc(expr))
        if rc != 0
            txt = errortext(rc)
            throw(CameraError(txt))
        end
    end
end

# ----------------------------------------------------------------------
#    CAMERA ACCESS
# ----------------------------------------------------------------------

function OpenCamera(ph)
    F = dlsym(SDK_DLL[], :PCO_OpenCamera)
    @rccheck ccall(F, Cuint, (Ptr{HANDLE}, WORD), ph, WORD(0))
end

function OpenCameraEx(ph, open_struct)
    F = dlsym(SDK_DLL[], :PCO_OpenCameraEx)
    @rccheck ccall(F, Cuint, (Ptr{HANDLE}, Ptr{Openstruct}), ph, open_struct)
end

function CloseCamera(ph)
    F = dlsym(SDK_DLL[], :PCO_CloseCamera)
    @rccheck ccall(F, Cuint, (HANDLE,), ph)
end

function ResetLib()
    F = dlsym(SDK_DLL[], :PCO_ResetLib)
    @rccheck ccall(F, Cuint, ())
end

"""
    Note) This function only works for specific cameras or ports.
"""
function CheckDeviceAvailability(ph, num_if)
    F = dlsym(SDK_DLL[], :PCO_CheckDeviceAvailability)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, num_if)
end

# ----------------------------------------------------------------------
#    CAMERA DESCRIPTION
# ----------------------------------------------------------------------

function GetCameraDescription(ph, description)
    F = dlsym(SDK_DLL[], :PCO_GetCameraDescription)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Description}), ph, description)
end

function GetCameraDescriptionEx(ph, description, type)
    F = dlsym(SDK_DLL[], :PCO_GetCameraDescriptionEx)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Description}, WORD), ph, description, type)
end

# ----------------------------------------------------------------------
#    GENERAL CAMERA STATUS
# ----------------------------------------------------------------------

function GetGeneral(ph, general)
    F = dlsym(SDK_DLL[], :PCO_GetGeneral)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{General}), ph, general)
end

function GetCameraType(ph, camtype)
    F = dlsym(SDK_DLL[], :PCO_GetCameraType)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{CameraType}), ph, camtype)
end

function GetCameraHealthStatus(ph, warn, err, status)
    F = dlsym(SDK_DLL[], :PCO_GetCameraHealthStatus)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{DWORD}, Ptr{DWORD}, Ptr{DWORD}),
          ph, warn, err, status)
end

function GetTemperature(ph, CCD_temp, cam_temp, pow_temp)
    F = dlsym(SDK_DLL[], :PCO_GetTemperature)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{SHORT}, Ptr{SHORT}, Ptr{SHORT}),
          ph, CCD_temp, cam_temp, pow_temp)
end

function GetInfoString(ph, infotype, buf, size_in)
    F = dlsym(SDK_DLL[], :PCO_GetInfoString)
    @rccheck ccall(F, Cuint, (HANDLE, DWORD, Ptr{Cchar}, WORD),
          ph, infotype, buf, size_in)
end

function GetCameraName(ph, camera_name, camera_name_length)
    F = dlsym(SDK_DLL[], :PCO_GetCameraName)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Cchar}, WORD),
          ph, camera_name, camera_name_length)
end

function GetFirmwareInfo(ph, device_block, firmware_version)
    F = dlsym(SDK_DLL[], :PCO_GetFirmwareInfo)
    @rccheck ccall(F, Cuint, (HANDLE, WORD, Ptr{FW_Vers}),
          ph, device_block, firmware_version)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function GetColorCorrectionMatrix(ph, matrix)
    F = dlsym(SDK_DLL[], :PCO_GetColorCorrectionMatrix)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Cdouble}), ph, matrix)
end

# ----------------------------------------------------------------------
#    GENERAL CAMERA CONTROL
# ----------------------------------------------------------------------

function ArmCamera(ph)
    F = dlsym(SDK_DLL[], :PCO_ArmCamera)
    @rccheck ccall(F, Cuint, (HANDLE,), ph)
end

function SetImageParameters(ph, xres, yres, flags, param, ilen)
    F = dlsym(SDK_DLL[], :PCO_SetImageParameters)
    @rccheck ccall(F, Cuint, (HANDLE, WORD, WORD, DWORD, Ptr{Cvoid}, Cint),
          ph, xres, yres, flags, param, ilen)
end

function ResetSettingsToDefault(ph)
    F = dlsym(SDK_DLL[], :PCO_ResetSettingsToDefault)
    @rccheck ccall(F, Cuint, (HANDLE,), ph)
end

function SetTimeouts(ph, buf_in, size_in)
    F = dlsym(SDK_DLL[], :PCO_SetTimeouts)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Cvoid}, Cuint), ph, buf_in, size_in)
end

function RebootCamera(ph)
    F = dlsym(SDK_DLL[], :PCO_RebootCamera)
    @rccheck ccall(F, Cuint, (HANDLE,), ph)
end

function GetCameraSetup(ph, type, setup, len)
    F = dlsym(SDK_DLL[], :PCO_GetCameraSetup)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{DWORD}, Ptr{WORD}),
          ph, type, setup, len)
end

function ControlCommandCAll(ph, buf_in, size_in, buf_out, size_out)
    F = dlsym(SDK_DLL[], :PCO_ControlCommandCAll)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{VOID}, Cuint, Ptr{VOID}, Cuint),
          ph, buf_in, size_in, buf_out, size_out)
end

# ----------------------------------------------------------------------
#    IMAGE SENSOR
# ----------------------------------------------------------------------

function GetSensorStruct(ph, sensor)
    F = dlsym(SDK_DLL[], :PCO_GetSensorStruct)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Sensor}), ph, sensor)
end

function SetSensorStruct(ph, sensor)
    F = dlsym(SDK_DLL[], :PCO_SetSensorStruct)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Sensor}), ph, sensor)
end

function GetSizes(ph, x_res_act, y_res_act, x_res_max, y_res_max)
    F = dlsym(SDK_DLL[], :PCO_GetSizes)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}),
          ph, x_res_act, y_res_act, x_res_max, y_res_max)
end

function GetSensorFormat(ph, sensor)
    F = dlsym(SDK_DLL[], :PCO_GetSensorFormat)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, sensor)
end

function SetSensorFormat(ph, sensor)
    F = dlsym(SDK_DLL[], :PCO_SetSensorFormat)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, sensor)
end

function GetROI(ph, roi_x0, roi_y0, roi_x1, roi_y1)
    F = dlsym(SDK_DLL[], :PCO_GetROI)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}),
          ph, roi_x0, roi_y0, roi_x1, roi_y1)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function SetROI(ph, roi_x0, roi_y0, roi_x1, roi_y1)
    F = dlsym(SDK_DLL[], :PCO_SetROI)
    @rccheck ccall(F, Cuint, (HANDLE, WORD, WORD, WORD, WORD),
          ph, roi_x0, roi_y0, roi_x1, roi_y1)
end

function GetBinning(ph, bin_horz, bin_vert)
    F = dlsym(SDK_DLL[], :PCO_GetBinning)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{WORD}), ph, bin_horz, bin_vert)
end

function SetBinning(ph, bin_horz, bin_vert)
    F = dlsym(SDK_DLL[], :PCO_SetBinning)
    @rccheck ccall(F, Cuint, (HANDLE, WORD, WORD), ph, bin_horz, bin_vert)
end

function GetPixelRate(ph, pixel_rate)
    F = dlsym(SDK_DLL[], :PCO_GetPixelRate)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{DWORD}), ph, pixel_rate)
end

function SetPixelRate(ph, pixel_rate)
    F = dlsym(SDK_DLL[], :PCO_SetPixelRate)
    @rccheck ccall(F, Cuint, (HANDLE, DWORD), ph, pixel_rate)
end

function GetConversionFactor(ph, conv_fact)
    F = dlsym(SDK_DLL[], :PCO_GetConversionFactor)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, conv_fact)
end

function SetConversionFactor(ph, conv_fact)
    F = dlsym(SDK_DLL[], :PCO_SetConversionFactor)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, conv_fact)
end

function GetDoubleImageMode(ph, double_image)
    F = dlsym(SDK_DLL[], :PCO_GetDoubleImageMode)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, double_image)
end

function SetDoubleImageMode(ph, double_image)
    F = dlsym(SDK_DLL[], :PCO_SetDoubleImageMode)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, double_image)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function GetIRSensitivity(ph, ir)
    F = dlsym(SDK_DLL[], :PCO_GetIRSensitivity)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, ir)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function SetIRSensitivity(ph, ir)
    F = dlsym(SDK_DLL[], :PCO_SetIRSensitivity)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, ir)
end

function GetNoiseFilterMode(ph, noise_filter_mode)
    F = dlsym(SDK_DLL[], :PCO_GetNoiseFilterMode)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, noise_filter_mode)
end

function SetNoiseFilterMode(ph, noise_filter_mode)
    F = dlsym(SDK_DLL[], :PCO_SetNoiseFilterMode)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, noise_filter_mode)
end

function SetSensorDarkOffset(ph, dark_offset)
    F = dlsym(SDK_DLL[], :PCO_SetSensorDarkOffset)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, dark_offset)
end

# ----------------------------------------------------------------------
#    TIMING CONTROL
# ----------------------------------------------------------------------

function GetTimingStruct(ph, timing)
    F = dlsym(SDK_DLL[], :PCO_GetTimingStruct)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Timing}), ph, timing)
end

function SetTimingStruct(ph, timing)
    F = dlsym(SDK_DLL[], :PCO_SetTimingStruct)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Timing}), ph, timing)
end

function GetCOCRunTime(ph, time_s, time_ns)
    F = dlsym(SDK_DLL[], :PCO_GetCOCRunTime)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{DWORD}, Ptr{DWORD}), ph, time_s, time_ns)
end

function GetDelayExposureTime(ph, delay, exposure, time_base_delay, time_base_exposure)
    F = dlsym(SDK_DLL[], :PCO_GetDelayExposureTime)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{DWORD}, Ptr{DWORD}, Ptr{WORD}, Ptr{WORD}),
          ph, delay, exposure, time_base_delay, time_base_exposure)
end

function SetDelayExposureTime(ph, delay, exposure, time_base_delay, time_base_exposure)
    F = dlsym(SDK_DLL[], :PCO_SetDelayExposureTime)
    @rccheck ccall(F, Cuint, (HANDLE, DWORD, DWORD, WORD, WORD),
          ph, delay, exposure, time_base_delay, time_base_exposure)
end

function GetDelayExposureTimeTable(ph, delay, exposure, time_base_delay, time_base_exposure, count)
    F = dlsym(SDK_DLL[], :PCO_GetDelayExposureTime)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{DWORD}, Ptr{DWORD}, Ptr{WORD}, Ptr{WORD}, WORD),
          ph, delay, exposure, time_base_delay, time_base_exposure, count)
end

function SetDelayExposureTimeTable(ph, delay, exposure, time_base_delay, time_base_exposure, count)
    F = dlsym(SDK_DLL[], :PCO_SetDelayExposureTime)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{DWORD}, Ptr{DWORD}, WORD, WORD, WORD),
          ph, delay, exposure, time_base_delay, time_base_exposure, count)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function GetFrameRate(ph, frame_rate_status, frame_rate, frame_rate_exposure)
    F = dlsym(SDK_DLL[], :PCO_GetFrameRate)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{DWORD}, Ptr{DWORD}),
          ph, frame_rate_status, frame_rate, frame_rate_exposure)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function SetFrameRate(ph, frame_rate_status, frame_rate_mode, frame_rate, frame_rate_exposure)
    F = dlsym(SDK_DLL[], :PCO_SetFrameRate)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}, WORD, Ptr{DWORD}, Ptr{DWORD}),
          ph, frame_rate_status, frame_rate_mode, frame_rate, frame_rate_exposure)
end

function GetTriggerMode(ph, trigger_mode)
    F = dlsym(SDK_DLL[], :PCO_GetTriggerMode)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, trigger_mode)
end

function SetTriggerMode(ph, trigger_mode)
    F = dlsym(SDK_DLL[], :PCO_SetTriggerMode)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, trigger_mode)
end

function ForceTrigger(ph, triggered)
    F = dlsym(SDK_DLL[], :PCO_ForceTrigger)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, triggered)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function GetExpTrigSignalStatus(ph, exp_trg_signal)
    F = dlsym(SDK_DLL[], :PCO_GetExpTrigSignalStatus)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, exp_trg_signal)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function GetFastTimingMode(ph, fast_timing_mode)
    F = dlsym(SDK_DLL[], :PCO_GetFastTimingMode)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, fast_timing_mode)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function SetFastTimingMode(ph, fast_timing_mode)
    F = dlsym(SDK_DLL[], :PCO_SetFastTimingMode)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, fast_timing_mode)
end

# ----------------------------------------------------------------------
#    RECORDING CONTROL
# ----------------------------------------------------------------------

function GetRecordingStruct(ph, recording)
    F = dlsym(SDK_DLL[], :PCO_GetRecordingStruct)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Recording}), ph, recording)
end

function SetRecordingStruct(ph, recording)
    F = dlsym(SDK_DLL[], :PCO_SetRecordingStruct)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Recording}), ph, recording)
end

function GetRecordingState(ph, rec_state)
    F = dlsym(SDK_DLL[], :PCO_GetRecordingState)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, rec_state)
end

function SetRecordingState(ph, rec_state)
    F = dlsym(SDK_DLL[], :PCO_SetRecordingState)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, rec_state)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function GetAcquireMode(ph,acqu_mode)
    F = dlsym(SDK_DLL[], :PCO_GetAcquireMode)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph,acqu_mode)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function SetAcquireMode(ph,acqu_mode)
    F = dlsym(SDK_DLL[], :PCO_SetAcquireMode)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph,acqu_mode)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function GetMetaDataMode(ph, meta_data_mode, meta_data_size, meta_data_version)
    F = dlsym(SDK_DLL[], :PCO_GetMetaDataMode)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}),
     ph, meta_data_mode, meta_data_size, meta_data_version)
end

"""
    Note) This function only works for specific cameras or ports.
"""
function SetMetaDataMode(ph, meta_data_mode, meta_data_size, meta_data_version)
    F = dlsym(SDK_DLL[], :PCO_SetMetaDataMode)
    @rccheck ccall(F, Cuint, (HANDLE, WORD, Ptr{WORD}, Ptr{WORD}),
     ph, meta_data_mode, meta_data_size, meta_data_version)
end

function SetDateTime(ph, day, month, year, hour, min, sec)
    F = dlsym(SDK_DLL[], :PCO_SetDateTime)
    @rccheck ccall(F, Cuint, (HANDLE, BYTE, BYTE, WORD, WORD, BYTE, BYTE), ph, day, month, year, hour, min, sec)
end

function GetTimestampMode(ph, time_stamp_mode)
    F = dlsym(SDK_DLL[], :PCO_GetTimestampMode)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, time_stamp_mode)
end

function SetTimestampMode(ph, time_stamp_mode)
    F = dlsym(SDK_DLL[], :PCO_SetTimestampMode)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, time_stamp_mode)
end

# ----------------------------------------------------------------------
#    IMAGE INFORMATION
# ----------------------------------------------------------------------

function GetBitAlignment(ph, bit_alignment)
    F = dlsym(SDK_DLL[], :PCO_GetBitAlignment)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, bit_alignment)
end

function SetBitAlignment(ph, bit_alignment)
    F = dlsym(SDK_DLL[], :PCO_SetBitAlignment)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, bit_alignment)
end

function GetHotPixelCorrectionMode(ph, hotpixel_correction_mode)
    F = dlsym(SDK_DLL[], :PCO_GetHotPixelCorrectionMode)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{WORD}), ph, hotpixel_correction_mode)
end

function SetHotPixelCorrectionMode(ph, hotpixel_correction_mode)
    F = dlsym(SDK_DLL[], :PCO_SetHotPixelCorrectionMode)
    @rccheck ccall(F, Cuint, (HANDLE, WORD), ph, hotpixel_correction_mode)
end

# ----------------------------------------------------------------------
#    BUFFER MANAGEMENT
# ----------------------------------------------------------------------

function AllocateBuffer(ph, buf_nr, buffer_size, buf, event)
    F = dlsym(SDK_DLL[], :PCO_AllocateBuffer)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{SHORT}, DWORD, Ptr{Ptr{WORD}}, Ptr{HANDLE}),
          ph, buf_nr, buffer_size, buf, event)
end

function FreeBuffer(ph, buf_nr)
    F = dlsym(SDK_DLL[], :PCO_FreeBuffer)
    @rccheck ccall(F, Cuint, (HANDLE, SHORT), ph, buf_nr)
end

function GetBufferStatus(ph, buf_nr, status_DLL, status_drv)
    F = dlsym(SDK_DLL[], :PCO_GetBufferStatus)
    @rccheck ccall(F, Cuint, (HANDLE, SHORT, Ptr{DWORD}, Ptr{DWORD}),
          ph, buf_nr, status_DLL, status_drv)
end

function GetBuffer(ph, buf_nr, buf, event)
    F = dlsym(SDK_DLL[], :PCO_GetBuffer)
    @rccheck ccall(F, Cuint, (HANDLE, SHORT, Ptr{Ptr{WORD}}, Ptr{HANDLE}),
          ph, buf_nr, buf, event)
end

# ----------------------------------------------------------------------
#    IMAGE ACQUISITION
# ----------------------------------------------------------------------

function GetImageEx(ph, segment, first_image, last_image, buf_nr, x_res, y_res, bit_per_pixel)
    F = dlsym(SDK_DLL[], :PCO_GetImageEx)
    @rccheck ccall(F, Cuint, (HANDLE, WORD, DWORD, DWORD, SHORT, WORD, WORD, WORD),
          ph, segment, first_image, last_image, buf_nr, x_res, y_res, bit_per_pixel)
end

function AddBufferEx(ph, first_image, last_image, buf_nr, x_res, y_res, bit_per_pixel)
    F = dlsym(SDK_DLL[], :PCO_AddBufferEx)
    @rccheck ccall(F, Cuint, (HANDLE, DWORD, DWORD, SHORT, WORD, WORD, WORD),
          ph, first_image, last_image, buf_nr, x_res, y_res, bit_per_pixel)
end

function CancelImages(ph)
    F = dlsym(SDK_DLL[], :PCO_CancelImages)
    @rccheck ccall(F, Cuint, (HANDLE,), ph)
end

function GetPendingBuffer(ph)
    n = Vector{Cint}(undef, 1)
    F = dlsym(SDK_DLL[], :PCO_GetPendingBuffer)
    @rccheck ccall(F, Cuint, (HANDLE, Ptr{Cint}), ph, n)
end

function WaitforBuffer(ph, nr_of_buffer, bl, timeout)
    F = dlsym(SDK_DLL[], :PCO_WaitforBuffer)
    @rccheck ccall(F, Cuint, (HANDLE, INT, Ptr{Buflist}, Cint),
          ph, nr_of_buffer, bl, timeout)
end

# ----------------------------------------------------------------------
#    DEBUG
# ----------------------------------------------------------------------

function GetErrorTextSDK(Error::DWORD, error_string, error_string_length)
    F = dlsym(SDK_DLL[], :PCO_GetErrorTextSDK)
    ccall(F, Cvoid, (DWORD, Ptr{Cchar}, DWORD), Error, error_string, error_string_length)
end

end # module SDK