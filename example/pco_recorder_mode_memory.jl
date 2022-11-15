"""
Example for PCO_RECORDER_MODE_MEMORY

This is the reimplementation code of c/c++ a example 
in the Recorder document
"""

# include all APIs
using PcoCameras.Wrapper.SDK
using PcoCameras.Wrapper.Recorder
using PcoCameras.Wrapper.PcoStruct
import PcoCameras.Wrapper.TypeAlias: VOID,
 HANDLE,
 SHORT,
 INT,
 LONG, 
 WORD, 
 DWORD,
 BYTE,
 bool,
 BOOL
import PcoCameras.Wrapper: @rccheck

CAMCOUNT = 1

####################
##Main
####################
hRec = Ref(HANDLE(0))

hCamArr = [HANDLE(0) for _ in 1:CAMCOUNT]
imgDistributionArr = zeros(DWORD, CAMCOUNT);
maxImgCountArr = zeros(DWORD, CAMCOUNT);
reqImgCountArr = zeros(DWORD, CAMCOUNT);

# Some frequently used parameters for the camera
num_of_images = 10
exptime = 10
expbase = 2
metasize = Ref(WORD(0))
metaVersion = Ref(WORD(0))
    
# Open camera and set to default state
camstruct = Ref(PcoStruct.Openstruct())
if SDK.OpenCameraEx(@view(hCamArr[1]), camstruct) != 0
    error("No camera found.\nPress <Enter> to end\n")
end
# Make sure recording is off
@rccheck SDK.SetRecordingState(hCamArr[1], 0)
# Do some settings
@rccheck SDK.SetTimestampMode(hCamArr[1],0)
@rccheck SDK.SetMetaDataMode(hCamArr[1],1,metasize,metaVersion)
@rccheck SDK.SetBitAlignment(hCamArr[1],1)
# Set Exposure time
@rccheck SDK.SetDelayExposureTime(hCamArr[1],0,exptime, 2, expbase)
# Arm camera
@rccheck SDK.ArmCamera(hCamArr[1])

# Set image distribution to 1 since only one camera is used
imgDistributionArr[1] = 1;

# Reset Recorder to make sure a no previous instance is running
@rccheck Recorder.ResetLib(false);

# Create Recorder (mode: memory sequence)
@rccheck Recorder.Create(hRec, hCamArr, imgDistributionArr, CAMCOUNT, 2, 'C', maxImgCountArr)

# Set required images
reqImgCountArr[1] = min(num_of_images, maxImgCountArr[1])

# Init Recorder
@rccheck Recorder.Init(hRec[], reqImgCountArr, CAMCOUNT, 1, 0, C_NULL, C_NULL)

# Get image size
imgWidth = Ref(WORD(0))
imgHeight = Ref(WORD(0))
@rccheck Recorder.GetSettings(hRec[], hCamArr[1], C_NULL, C_NULL, C_NULL, imgWidth, imgHeight,  C_NULL)

# Start camera
@rccheck Recorder.StartRecord(hRec[], C_NULL)

# Wait until acquisition is finished
# (all other parameters are ignored)
acquisitionRunning = Ref(UInt8(true))
warn = Ref(DWORD(0))
err = Ref(DWORD(0))
status = Ref(DWORD(0))
while Bool(acquisitionRunning[])
    @rccheck Recorder.GetStatus(hRec[], hCamArr[1], acquisitionRunning, ntuple(_->C_NULL,8)...)
    @rccheck SDK.GetCameraHealthStatus(hCamArr[1],warn,err,status)
    if err != 0
        Recorder.StopRecord(hRec[], hCamArr[1])
    end
    sleep(0.1)
end

# Allocate memory for one image
imgBuffer = zeros(WORD, imgWidth[], imgHeight[])

# Get number of finally recorded images
procImgCount = Ref(DWORD(0))
@rccheck Recorder.GetStatus(hRec[], hCamArr[1],ntuple(_->C_NULL,3)..., procImgCount, ntuple(_->C_NULL,5)...)

##############################################
##TODO: Process, Save or analyze the image(s)
##Here we just read, print image counter and save one tif file
##############################################

# Get the images and print image counter
metadata = Ref(PcoStruct.Metadata())
imgNumber = Ref(DWORD(0))
imgeSaved = true
for i = 0:procImgCount[]-1
    @rccheck Recorder.CopyImage(hRec[], hCamArr[1], i, 1, 1, imgWidth[], imgHeight[], 
                                imgBuffer, imgNumber, metadata, C_NULL)
    println("Image Number: $(imgNumber[])")

    # Save first image as tiff in the binary folder
    # just to have some output
    if !imgeSaved
        @rccheck Recorder.SaveImage(imgBuffer, imgWidth[], imgHeight[], collect.(Cchar,"M16\0"),false,collect.(Cchar,"test.tif\0"),true,metadata)
        imgeSaved = true
    end
end

# Delete Recorder
@rccheck Recorder.Delete(hRec[])

# Close camera
@rccheck SDK.CloseCamera(hCamArr[])
