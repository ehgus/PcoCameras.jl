module Recorder

using ..PcoStruct
using ..TypeAlias
import Libdl: dlopen, dlsym

dir_path = "C:/Program Files/PCO Digital Camera Toolbox/pco.recorder/bin64"

const Recorder_DLL = Ref{Ptr{Cvoid}}(0)
function __init__()
    Recorder_DLL[] = dlopen(joinpath(dir_path,"PCO_Recorder.dll"))
end

# ----------------------------------------------------------------------
#    RECORDER API
# ----------------------------------------------------------------------

function GetVersion(Major, Minor, Patch, Build)
    F = dlsym(Recorder_DLL[], :PCO_RecorderGetVersion)
    ccall(F, Cvoid, (Ref{Cint}, Ref{Cint}, Ref{Cint}, Ref{Cint}),
     Major, Minor, Patch, Build)
end


function SaveImage(pImgBuf, Width, Height, FileType, IsBitmap, FilePth, Overwrite, metadata)
    F = dlsym(Recorder_DLL[], :PCO_RecorderSaveImage)
    ccall(F, Cuint, (Ref{Cvoid}, WORD, WORD, Ref{Cchar}, bool, Ref{Cchar}, bool,  Ref{Metadata}),
     pImgBuf, Width, Height, FileType, IsBitmap, FilePth, Overwrite, metadata)
end


function SaveOverlay(pImgBufR, pImgBufG, pImgBufB, Width, Height, FileType, FilePth, Overwrite, metadata)
    F = dlsym(Recorder_DLL[], :PCO_RecorderSaveOverlay)
    ccall(F, Cuint, (Ref{Cvoid}, Ref{Cvoid}, Ref{Cvoid}, WORD, WORD, Ref{Cchar}, Ref{Cchar}, bool, Ref{Metadata}),
     pImgBufR, pImgBufG, pImgBufB, Width, Height, FileType, FilePth, Overwrite, metadata)
end


function ResetLib(Silent)
    F = dlsym(Recorder_DLL[], :PCO_RecorderResetLib)
    ccall(F, Cuint, (bool,), Silent)
end


function Create(phRec, phCamArr, ImgDistributionArr, ArrLength, RecMode, DriveLetter, MaxImgCountArr)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCreate)
    ccall(F, Cuint, (Ref{HANDLE}, Ref{HANDLE}, Ref{DWORD}, WORD, WORD, Cchar, Ref{DWORD}),
     phRec, phCamArr, ImgDistributionArr, ArrLength, RecMode, DriveLetter, MaxImgCountArr)
end


function Delete(phRec)
    F = dlsym(Recorder_DLL[], :PCO_RecorderDelete)
    ccall(F, Cuint, (HANDLE,), phRec)
end


function Init(phRec, ImgCountArr, ArrLength, Type, NoOverwrite, FilePath, RamSegmentArr)
    F = dlsym(Recorder_DLL[], :PCO_RecorderInit)
    ccall(F, Cuint, (HANDLE, Ref{DWORD}, WORD, WORD, WORD, Ref{Cchar}, Ref{WORD}),
     phRec, ImgCountArr, ArrLength, Type, NoOverwrite, FilePath, RamSegmentArr)
end


function Cleanup(phRec, phCam)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCleanup)
    ccall(F, Cuint, (HANDLE, HANDLE), phRec, phCam)
end


function GetSettings(phRec, phCam, Recmode, MaxImgCount, ReqImgCount, Width, Height, MetadataLines)
    F = dlsym(Recorder_DLL[], :PCO_RecorderGetSettings)
    ccall(F, Cuint, (HANDLE, HANDLE, Ref{DWORD}, Ref{DWORD}, Ref{DWORD}, Ref{WORD}, Ref{WORD}, Ref{WORD}),
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
    ccall(F, Cuint, (HANDLE, HANDLE, WORD, Ref{WORD}, Ref{WORD}, WORD),
     phRec, phCam, RegionType, RoiX0Arr, RoiY0Arr, ArrLength)
end


function SetCompressionParams(phRec, phCam, compressionParams)
    F = dlsym(Recorder_DLL[], :PCO_RecorderSetCompressionParams)
    ccall(F, Cuint, (HANDLE, HANDLE, Ref{CompressionParams}),
     phRec, phCam, compressionParams)
end


function GetStatus(phRec, phCam, IsRunning, AutoExpState, LastError, ProcImgCount, ReqImgCount, BuffersFull, FIFOOverflow, StartTime, StopTime)
    F = dlsym(Recorder_DLL[], :PCO_RecorderGetStatus)
    ccall(F, Cuint, (HANDLE, HANDLE, Ref{bool}, Ref{bool}, Ref{DWORD}, Ref{DWORD}, Ref{DWORD}, Ref{bool}, Ref{bool}, Ref{DWORD}, Ref{DWORD}),
     phRec, phCam, IsRunning, AutoExpState, LastError, ProcImgCount, ReqImgCount, BuffersFull, FIFOOverflow, StartTime, StopTime)
end


function GetImageAddress(phRec, phCam, ImgIdx, ImgBuf, Width, Height, ImgNumber)
    F = dlsym(Recorder_DLL[], :PCO_RecorderGetImageAddress)
    ccall(F, Cuint, (HANDLE, HANDLE, DWORD, Ref{Ptr{WORD}}, Ref{WORD}, Ref{WORD}, Ref{DWORD}),
     phRec, phCam, ImgIdx, ImgBuf, Width, Height, ImgNumber)
end


function CopyImage(phRec, phCam, ImgIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf, ImgNumber, metadata, timestamp)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCopyImage)
    ccall(F, Cuint, (HANDLE, HANDLE, DWORD, WORD, WORD, WORD, WORD, Ref{WORD}, Ref{DWORD}, Ref{Metadata}, Ref{Timestamp}),
     phRec, phCam, ImgIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf, ImgNumber, metadata, timestamp)
end


function CopyAverageImage(phRec, phCam, StartIdx, StopIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCopyAverageImage)
    ccall(F, Cuint, (HANDLE, HANDLE, DWORD, DWORD, WORD, WORD, WORD, WORD, Ref{WORD}),
     phRec, phCam, StartIdx, StopIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf)
end


function CopyImageCompressed(phRec, phCam, ImgIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf, ImgNumber, metadata, timestamp)
    F = dlsym(Recorder_DLL[], :PCO_RecorderCopyImageCompressed)
    ccall(F, Cuint, (HANDLE, HANDLE, DWORD, WORD, WORD, WORD, WORD, Ref{BYTE}, Ref{DWORD}, Ref{Metadata}, Ref{Timestamp}),
     phRec, phCam, ImgIdx, RoixX0, RoixY0, RoixX1, RoixY1, ImgBuf, ImgNumber, metadata, timestamp)
end


end