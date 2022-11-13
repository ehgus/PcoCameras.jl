module PcoStruct

using ..TypeAlias

export Openstruct, Description, Description2, SC2_Hardware_DESC, 
 SC2_Firmware_DESC, HW_Vers, FW_Vers, CameraType, General, Buflist,
  Metadata, CompressionParams, Timestamp

struct Openstruct
    Size::WORD
    InterfaceType::WORD
    CameraNumber::WORD
    CameraNumAtInterface::WORD
    wOpenFlags::NTuple{10,WORD}
    dwOpenFlags::NTuple{5,DWORD}
    OpenPtr::NTuple{6,Ptr{Cvoid}}
    Dummy::NTuple{8,WORD}

    function Openstruct(;InterfaceType=0, CameraNumber=0,
                        wOpenFlags=Tuple(zeros(WORD, 10)),
                        dwOpenFlags=Tuple(zeros(DWORD, 5)),
                        OpenPtr=Tuple([Ptr{Cvoid}(0) for x in 1:6]))
        type_size = sizeof(Openstruct)
        new(type_size, InterfaceType, CameraNumber, 0, wOpenFlags, dwOpenFlags, OpenPtr, Tuple(zeros(WORD, 8)))
    end
end


struct Description
    Size::WORD
    SensorTypeDESC::WORD
    SensorSubTypeDESC::WORD
    MaxHorzResStdDESC::WORD
    MaxVertResStdDESC::WORD
    MaxHorzResExtDESC::WORD
    MaxVertResExtDESC::WORD
    DynResDESC::WORD
    MaxBinHorzDESC::WORD
    BinHorzSteppingDESC::WORD
    MaxBinVertDESC::WORD
    BinVertSteppingDESC::WORD
    RoiHorStepsDESC::WORD
    RoiVertStepsDESC::WORD
    NumADCsDESC::WORD
    MinSizeHorzDESC::WORD
    PixelRateDESC::NTuple{4,DWORD}
    Dummypr::NTuple{20,DWORD}
    ConvFactDESC::NTuple{4,WORD}
    CoolingSetpoints::NTuple{10,SHORT}
    Dummycv::NTuple{8,WORD}
    SoftRoiHorStepsDESC::WORD
    SoftRoiVertStepsDESC::WORD
    IRDESC::WORD
    MinSizeVertDESC::WORD
    MinDelayDESC::DWORD
    MaxDelayDESC::DWORD
    MinDelayStepDESC::DWORD
    MinExposureDESC::DWORD
    MaxExposureDESC::DWORD
    MinExposureStepDESC::DWORD
    MinDelayIRDESC::DWORD
    MaxDelayIRDESC::DWORD
    MinExposureIRDESC::DWORD
    MaxExposureIRDESC::DWORD
    TimeTableDESC::WORD
    DoubleImageDESC::WORD
    MinCoolSetDESC::SHORT
    MaxCoolSetDESC::SHORT
    DefaultCoolSetDESC::SHORT
    PowerDownModeDESC::WORD
    OffsetRegulationDESC::WORD
    ColorPatternDESC::WORD
    PatternTypeDESC::WORD
    Dummy1::WORD
    Dummy2::WORD
    NumCoolingSetpoints::WORD
    GeneralCapsDESC1::DWORD
    GeneralCapsDESC2::DWORD
    ExtSyncFrequency::NTuple{4,DWORD}
    GeneralCapsDESC3::DWORD
    GeneralCapsDESC4::DWORD
    Dummy::NTuple{40,DWORD}

    function Description()
        type_size = sizeof(Description)
        z = zeros(Cuchar,type_size)
        reinterpret(WORD,@view(z[1:sizeof(WORD)]))[1] = type_size
        h = reinterpret(Description, z)[1]
        return h
    end
end


struct Description2
    Size::WORD
    AlignDummy1::WORD
    MinPeriodicalTimeDESC2::DWORD
    MaxPeriodicalTimeDESC2::DWORD
    MinPeriodicalConditionDESC2::DWORD
    MaxNumberOfExposuresDESC2::DWORD
    MinMonitorSignalOffsetDESC2::LONG
    MaxMonitorSignalOffsetDESC2::DWORD
    MinPeriodicalStepDESC2::DWORD
    StartTimeDelayDESC2::DWORD
    MinMonitorStepDESC2::DWORD
    MinDelayModDESC2::DWORD
    MaxDelayModDESC2::DWORD
    MinDelayStepModDESC2::DWORD
    MinExposureModDESC2::DWORD
    MaxExposureModDESC2::DWORD
    MinExposureStepModDESC2::DWORD
    ModulateCapsDESC2::DWORD
    Reserved::NTuple{16,DWORD}
    Dummy::NTuple{41,DWORD}

    function Description2()
        type_size = sizeof(Description2)
        z = zeros(Cuchar,type_size)
        reinterpret(WORD,@view(z[1:sizeof(WORD)]))[1] = type_size
        h = reinterpret(Description2, z)[1]
        return h
    end
end


struct SC2_Hardware_DESC
    Name::NTuple{16,Cchar}
    BatchNo::WORD
    Revision::WORD
    Variant::WORD
    Dummy::NTuple{20,WORD}

    function SC2_Hardware_DESC()
        type_size = sizeof(SC2_Hardware_DESC)
        z = zeros(Cuchar,type_size)
        reinterpret(WORD,@view(z[1:sizeof(WORD)]))[1] = type_size
        h = reinterpret(SC2_Hardware_DESC, z)[1]
        return h
    end
end


struct SC2_Firmware_DESC
    Name::NTuple{16,Cchar}
    MinorRev::BYTE
    MajorRev::BYTE
    Variant::WORD
    Dummy::NTuple{22,WORD}
    function SC2_Firmware_DESC()
        type_size = sizeof(SC2_Firmware_DESC)
        z = zeros(Cuchar,type_size)
        reinterpret(WORD,@view(z[1:sizeof(WORD)]))[1] = type_size
        h = reinterpret(SC2_Firmware_DESC, z)[1]
        return h
    end
end


const MAXVERSIONHW = 10
struct HW_Vers
    BoardNum::WORD
    Board::NTuple{MAXVERSIONHW,SC2_Hardware_DESC}

    function HW_Vers()
        new(0, ntuple(i -> SC2_Hardware_DESC(), MAXVERSIONHW))
    end
end


const MAXVERSIONFW = 10
struct FW_Vers
    DeviceNum::WORD
    Device::NTuple{MAXVERSIONFW,SC2_Firmware_DESC}

    function FW_Vers()
        new(0, ntuple(i -> SC2_Firmware_DESC(), MAXVERSIONFW))
    end
end


struct CameraType
    Size::WORD
    CamType::WORD
    CamSubType::WORD
    AlignDummy1::WORD
    SerialNumber::DWORD
    HWVersion::DWORD
    FWVersion::DWORD
    InterfaceType::WORD
    HardwareVersion::HW_Vers
    FirmwareVersion::FW_Vers
    Dummy::NTuple{39,WORD}
    function CameraType()
        type_size = sizeof(CameraType)
        new(type_size, 0, 0, 0, 0, 0, 0, 0, HW_Vers(), FW_Vers(),
            Tuple(zeros(WORD,39)))
    end
end


struct General
    Size::WORD
    AlignDummy1::WORD
    CamType::CameraType
    CamHealthWarnings::DWORD
    CamHealthErrors::DWORD
    CamHealthStatus::DWORD
    CCDTemperature::SHORT
    CamTemperature::SHORT
    PowerSupplyTemperature::SHORT
    Dummy::NTuple{37,WORD}
    function General()
        type_size = sizeof(General)
        new(type_size, 0, CameraType(), 0, 0, 0, 0, 0, 0,
            Tuple(zeros(WORD,37)))
    end
end


struct Buflist
    BufNr::SHORT
    AlignDummy::WORD
    StatusDll::DWORD
    StatusDrv::DWORD

    function Buflist(bufnr)
        new(bufnr, 0, 0, 0)
    end
end

struct Metadata
    Size::WORD
    Version::WORD
    IMAGE_COUNTER_BCD::NTuple{4,BYTE}
    IMAGE_TIME_US_BCD::NTuple{3,BYTE}
    IMAGE_TIME_SEC_BCD::BYTE
    IMAGE_TIME_MIN_BCD::BYTE
    IMAGE_TIME_HOUR_BCD::BYTE
    IMAGE_TIME_DAY_BCD::BYTE
    IMAGE_TIME_MON_BCD::BYTE
    IMAGE_TIME_YEAR_BCD::BYTE
    IMAGE_TIME_STATUS::BYTE
    EXPOSURE_TIME_BASE::WORD
    EXPOSURE_TIME::DWORD
    FRAMERATE_MILLIHZ::DWORD
    SENSOR_TEMPERATURE::SHORT
    IMAGE_SIZE_X::WORD
    IMAGE_SIZE_Y::WORD
    BINNING_X::BYTE
    BINNING_Y::BYTE
    SENSOR_READOUT_FREQUENCY::DWORD
    SENSOR_CONV_FACTOR::WORD
    CAMERA_SERIAL_NO::DWORD
    CAMERA_TYPE::WORD
    BIT_RESOLUTION::BYTE
    SYNC_STATUS::BYTE
    DARK_OFFSET::WORD
    TRIGGER_MODE::BYTE
    DOUBLE_IMAGE_MODE::BYTE
    CAMERA_SYNC_MODE::BYTE
    IMAGE_TYPE::BYTE
    COLOR_PATTERN::WORD

    function Metadata()
        type_size = sizeof(Metadata)
        z = zeros(Cuchar,type_size)
        reinterpret(WORD,@view(z[1:sizeof(WORD)]))[1] = type_size
        h = reinterpret(Metadata, z)[1]
        return h
    end
end

struct CompressionParams
    GainK::Cdouble
    DarkNoise_e::Cdouble
    DSNU_e::Cdouble
    PRNU_pct::Cdouble
    LightSourceNoise_pct::Cdouble

    function CompressionParams()
        type_size = sizeof(CompressionParams)
        h = reinterpret(CompressionParams, zeros(Cuchar,type_size))[1]
        return h
    end
end

struct Timestamp
    Size::WORD
    ImgCounter::DWORD
    Year::WORD
    Month::WORD
    Day::WORD
    Hour::WORD
    Minute::WORD
    Second::WORD
    MicroSeconds::WORD
    function Timestamp()
        type_size = sizeof(Timestamp)
        z = zeros(Cuchar,type_size)
        reinterpret(WORD,@view(z[1:sizeof(WORD)]))[1] = type_size
        h = reinterpret(Timestamp, z)[1]
        return h
    end
end


end