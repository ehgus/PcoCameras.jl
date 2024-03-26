module Recorder

using ..PcoStruct
using ..TypeAlias
import Libdl: dlopen, dlsym

dir_path = "C:/Program Files/PCO Digital Camera Toolbox/pco.recorder/bin64"

const Recorder_DLL = Ref{Ptr{Cvoid}}(0)
function __init__()
    Recorder_DLL[] = dlopen(joinpath(dir_path,"PCO_Recorder.dll"))
    if ResetLib(false) != 0
        error("Recorder initializaiton is failed")
    end
end

# ----------------------------------------------------------------------
#    RECORDER API
# ----------------------------------------------------------------------

function GetVersion(Major, Minor, Patch, Build)
    F = dlsym(Recorder_DLL[], :PCO_RecorderGetVersion)
    ccall(F, Cvoid, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
     Major, Minor, Patch, Build)
end

function SaveImage(pImgBuf, Width, Height, FileType, IsBitmap, FilePth, Overwrite, metadata)
    F = dlsym(Recorder_DLL[], :PCO_RecorderSaveImage)
    ccall(F, Cuint, (Ptr{Cvoid}, WORD, WORD, Ptr{Cchar}, bool, Ptr{Cchar}, bool,  Ptr{Metadata}),
     pImgBuf, Width, Height, FileType, IsBitmap, FilePth, Overwrite, metadata)
end

function SaveOverlay(pImgBufR, pImgBufG, pImgBufB, Width, Height, FileType, FilePth, Overwrite, metadata)
    F = dlsym(Recorder_DLL[], :PCO_RecorderSaveOverlay)
    ccall(F, Cuint, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, WORD, WORD, Ptr{Cchar}, Ptr{Cchar}, bool, Ptr{Metadata}),
     pImgBufR, pImgBufG, pImgBufB, Width, Height, FileType, FilePth, Overwrite, metadata)
end

function ResetLib(Silent)
    F = dlsym(Recorder_DLL[], :PCO_RecorderResetLib)
    ccall(F, Cuint, (bool,), Silent)
end

function Create(phRec, phCamArr, ImgDistributionArr, ArrLength, RecMode, DriveLetter, MaxImgCountArr)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCreate)
    ccall(F, Cuint, (Ptr{HANDLE}, Ptr{HANDLE}, Ptr{DWORD}, WORD, WORD, Cchar, Ptr{DWORD}),
     phRec, phCamArr, ImgDistributionArr, ArrLength, RecMode, DriveLetter, MaxImgCountArr)
end

function Delete(phRec)
    F = dlsym(Recorder_DLL[], :PCO_RecorderDelete)
    ccall(F, Cuint, (HANDLE,), phRec)
end

function Init(phRec, ImgCountArr, ArrLength, Type, NoOverwrite, FilePath, RamSegmentArr)
    F = dlsym(Recorder_DLL[], :PCO_RecorderInit)
    ccall(F, Cuint, (HANDLE, Ptr{DWORD}, WORD, WORD, WORD, Ptr{Cchar}, Ptr{WORD}),
     phRec, ImgCountArr, ArrLength, Type, NoOverwrite, FilePath, RamSegmentArr)
end

function Cleanup(phRec, phCam)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCleanup)
    ccall(F, Cuint, (HANDLE, HANDLE), phRec, phCam)
end

function GetSettings(phRec, phCam, Recmode, MaxImgCount, ReqImgCount, Width, Height, MetadataLines)
    F = dlsym(Recorder_DLL[], :PCO_RecorderGetSettings)
    ccall(F, Cuint, (HANDLE, HANDLE, Ptr{DWORD}, Ptr{DWORD}, Ptr{DWORD}, Ptr{WORD}, Ptr{WORD}, Ptr{WORD}),
     phRec, phCam, Recmode, MaxImgCount, ReqImgCount, Width, Height, MetadataLines)
end

function StartRecord(phRec, phCam)
    F = dlsym(Recorder_DLL[], :PCO_RecorderStartRecord)
    ccall(F, Cuint, (HANDLE, HANDLE), phRec, phCam)
end

function StopRecord(phRec, phCam)
    F = dlsym(Recorder_DLL[], :PCO_RecorderStopRecord)
    ccall(F, Cuint, (HANDLE, HANDLE), phRec, phCam)
end

function SetAutoExposure(phRec, phCam, AutoExpState, Smoothness, MinExposure, MaxExposure, ExpBase)
    F = dlsym(Recorder_DLL[], :PCO_RecorderSetAutoExposure)
    ccall(F, Cuint, (HANDLE, HANDLE, bool, WORD, DWORD, DWORD, WORD),
     phRec, phCam, AutoExpState, Smoothness, MinExposure, MaxExposure, ExpBase)
end

function SetAutoExpRegions(phRec, phCam, RegionType, RoiX0Arr, RoiY0Arr, ArrLength)
    F = dlsym(Recorder_DLL[], :PCO_RecorderSetAutoExpRegions)
    ccall(F, Cuint, (HANDLE, HANDLE, WORD, Ptr{WORD}, Ptr{WORD}, WORD),
     phRec, phCam, RegionType, RoiX0Arr, RoiY0Arr, ArrLength)
end

function SetCompressionParams(phRec, phCam, compressionParams)
    F = dlsym(Recorder_DLL[], :PCO_RecorderSetCompressionParams)
    ccall(F, Cuint, (HANDLE, HANDLE, Ptr{CompressionParams}),
     phRec, phCam, compressionParams)
end

function GetStatus(phRec, phCam, isactivated, AutoExpState, LastError, ProcImgCount, ReqImgCount, BuffersFull, FIFOOverflow, StartTime, StopTime)
    F = dlsym(Recorder_DLL[], :PCO_RecorderGetStatus)
    ccall(F, Cuint, (HANDLE, HANDLE, Ptr{bool}, Ptr{bool}, Ptr{DWORD}, Ptr{DWORD}, Ptr{DWORD}, Ptr{bool}, Ptr{bool}, Ptr{DWORD}, Ptr{DWORD}),
     phRec, phCam, isactivated, AutoExpState, LastError, ProcImgCount, ReqImgCount, BuffersFull, FIFOOverflow, StartTime, StopTime)
end

function GetImageAddress(phRec, phCam, ImgIdx, ImgBuf, Width, Height, ImgNumber)
    F = dlsym(Recorder_DLL[], :PCO_RecorderGetImageAddress)
    ccall(F, Cuint, (HANDLE, HANDLE, DWORD, Ptr{Ptr{WORD}}, Ptr{WORD}, Ptr{WORD}, Ptr{DWORD}),
     phRec, phCam, ImgIdx, ImgBuf, Width, Height, ImgNumber)
end

function CopyImage(phRec, phCam, ImgIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf, ImgNumber, metadata, timestamp)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCopyImage)
    ccall(F, Cuint, (HANDLE, HANDLE, DWORD, WORD, WORD, WORD, WORD, Ptr{WORD}, Ptr{DWORD}, Ptr{Metadata}, Ptr{Timestamp}),
     phRec, phCam, ImgIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf, ImgNumber, metadata, timestamp)
end

function CopyAverageImage(phRec, phCam, StartIdx, StopIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCopyAverageImage)
    ccall(F, Cuint, (HANDLE, HANDLE, DWORD, DWORD, WORD, WORD, WORD, WORD, Ptr{WORD}),
     phRec, phCam, StartIdx, StopIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf)
end

function CopyImageCompressed(phRec, phCam, ImgIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf, ImgNumber, metadata, timestamp)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCopyImageCompressed)
    ccall(F, Cuint, (HANDLE, HANDLE, DWORD, WORD, WORD, WORD, WORD, Ptr{BYTE}, Ptr{DWORD}, Ptr{Metadata}, Ptr{Timestamp}),
     phRec, phCam, ImgIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf, ImgNumber, metadata, timestamp)
end

end # module Recorder