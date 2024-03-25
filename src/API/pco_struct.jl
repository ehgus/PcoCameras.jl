module PcoStruct

using ..TypeAlias

export
    # SDK-Access
    Openstruct,
    # SDK-Description
    Description, Description2,
    # SDK-Status
    SC2_Hardware_DESC, SC2_Firmware_DESC, HW_Vers, FW_Vers, CameraType, General,
    # SDK-Sensor
    # SDK-Timing
    Timing,
    # SDK-Recording
    # SDK-Storage
    # SDK-Image acquisition
    Buflist, Metadata,
    # SDK-Driver management
    # Recorder
    CompressionParams, Timestamp

macro zeros(expr)
    expr = macroexpand(__module__, expr)
    Meta.isexpr(expr, :struct) || error("Invalid usage of @zeros")
    blk = expr.args[3]
    for i in eachindex(blk.args)
        ei = blk.args[i]
        if ei isa Expr && ei.head === :(::)
            defexpr = ei.args[2]
            zero_val = :(ntuple(_->UInt8(0),sizeof($defexpr)))
            init_val = Expr(:call, :reinterpret, defexpr, zero_val)
            blk.args[i] = Expr(:(=),ei, init_val)
        end
    end
    expr.args[3] = blk
    return expr
end

@kwdef @zeros struct Openstruct
    Size::WORD = sizeof(Openstruct)
    InterfaceType::WORD = 0xFFFF
    CameraNumber::WORD
    CameraNumAtInterface::WORD
    wOpenFlags::NTuple{10,WORD}
    dwOpenFlags::NTuple{5,DWORD}
    OpenPtr::NTuple{6,Ptr{Cvoid}}
    Dummy::NTuple{8,WORD}
end

@kwdef @zeros struct Description
    Size::WORD = sizeof(Description)
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
end

@kwdef @zeros struct Description2
    Size::WORD = sizeof(Description2)
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
end

@kwdef @zeros struct SC2_Hardware_DESC
    Name::NTuple{16,Cchar}
    BatchNo::WORD
    Revision::WORD
    Variant::WORD
    Dummy::NTuple{20,WORD}
end

@kwdef @zeros struct SC2_Firmware_DESC
    Name::NTuple{16,Cchar}
    MinorRev::BYTE
    MajorRev::BYTE
    Variant::WORD
    Dummy::NTuple{22,WORD}
end

const MAXVERSIONHW = 10
@kwdef @zeros struct HW_Vers
    BoardNum::WORD
    Board::NTuple{MAXVERSIONHW,SC2_Hardware_DESC} = ntuple(_ -> SC2_Hardware_DESC(), MAXVERSIONHW)
end

const MAXVERSIONFW = 10
@kwdef @zeros struct FW_Vers
    DeviceNum::WORD
    Device::NTuple{MAXVERSIONFW,SC2_Firmware_DESC} = ntuple(_ -> SC2_Firmware_DESC(), MAXVERSIONFW)
end

@kwdef @zeros struct CameraType
    Size::WORD = sizeof(CameraType)
    CamType::WORD
    CamSubType::WORD
    AlignDummy1::WORD
    SerialNumber::DWORD
    HWVersion::DWORD
    FWVersion::DWORD
    InterfaceType::WORD
    HardwareVersion::HW_Vers = HW_Vers()
    FirmwareVersion::FW_Vers = FW_Vers()
    Dummy::NTuple{39,WORD}
end

@kwdef @zeros struct General
    Size::WORD = sizeof(General)
    AlignDummy1::WORD
    CamType::CameraType = CameraType()
    CamHealthWarnings::DWORD
    CamHealthErrors::DWORD
    CamHealthStatus::DWORD
    CCDTemperature::SHORT
    CamTemperature::SHORT
    PowerSupplyTemperature::SHORT
    Dummy::NTuple{37,WORD}
end

@kwdef @zeros struct Buflist
    BufNr::SHORT
    AlignDummy::WORD
    StatusDll::DWORD
    StatusDrv::DWORD
end

@kwdef @zeros struct Metadata
    Size::WORD = sizeof(Metadata)
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
end

@kwdef @zeros struct CompressionParams
    GainK::Cdouble
    DarkNoise_e::Cdouble
    DSNU_e::Cdouble
    PRNU_pct::Cdouble
    LightSourceNoise_pct::Cdouble
end

@kwdef @zeros struct Timestamp
    Size::WORD = sizeof(Timestamp)
    ImgCounter::DWORD
    Year::WORD
    Month::WORD
    Day::WORD
    Hour::WORD
    Minute::WORD
    Second::WORD
    MicroSeconds::WORD
end

end # module PcoStruct