module PcoStruct

using ..Alias

export
    # SDK-Access
    Openstruct,
    # SDK-Description
    Description, Description2,
    # SDK-Status
    SC2_Hardware_DESC, SC2_Firmware_DESC, HW_Vers, FW_Vers, CameraType, General,
    # SDK-Sensor
    Sensor,
    # SDK-Signal
    Signal,
    # SDK-Timing
    Timing,
    # SDK-Recording
    Recording,
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
            zero_val = Expr(:call, :ntuple, Expr(:->,:_,:(UInt8(0))),Expr(:call,:sizeof,defexpr))
            init_val = Expr(:call, :reinterpret, defexpr, zero_val)
            blk.args[i] = Expr(:(=),ei, init_val)
        end
    end
    expr.args[3] = blk
    return esc(expr)
end

@kwdef @zeros struct Openstruct
    Size::WORD = sizeof(Openstruct)
    Interface::WORD = 0xFFFF
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
    Interface::WORD
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

@kwdef @zeros struct Signal_Description
    Size::WORD = sizeof(Signal_Description)
    NumOfSignals::WORD
    SingleSignalDesc::NTuple{20,Cchar}
    Dummy::NTuple{524,DWORD}
end

@kwdef @zeros struct Sensor
    Size::WORD = sizeof(Sensor)
    AlignDummy1::WORD
    Desc::Description = Description()
    Desc2::Description2 = Description2()
    Dummy2::NTuple{168,DWORD}
    Sensorformat::WORD
    RoiX0::WORD
    RoiY0::WORD
    RoiX1::WORD
    RoiY1::WORD
    BinHorz::WORD
    BinVert::WORD
    AlignDummy2::WORD
    PixelRate::DWORD
    ConvFact::WORD
    DoubleImage::WORD
    ADCOperation::WORD
    IR::WORD
    CoolSet::SHORT
    OffsetRegulation::SHORT
    NoiseFilterMODE::WORD
    FastReadoutMODE::WORD
    DSNUAdjustMODE::WORD
    CDIMODE::WORD
    Dummy3::NTuple{32,WORD}
    SignalDesc::Signal_Description = Signal_Description()
    Dummy::NTuple{7,DWORD}
end

@kwdef @zeros struct Signal
    Size::WORD = sizeof(Signal)
    SignalNum::WORD
    Enabled::WORD
    Type::WORD
    Polarity::WORD
    Filter::WORD
    Selected::WORD
    Reserved1::WORD
    Parameter::NTuple{4,DWORD}
    SignalFunctionality::NTuple{4,DWORD}
    Reserved2::NTuple{3,DWORD}
end

@kwdef @zeros struct Timing
    Size::WORD = sizeof(Timing)
    TimeBaseDelay::WORD
    TimeBaseExposure::WORD
    AlignDummy1::WORD
    Dummy0::NTuple{2,DWORD}
    DelayTable::NTuple{16,DWORD}
    Dummy1::NTuple{114,DWORD}
    ExposureTable::NTuple{16,DWORD}
    Dummy2::NTuple{112,DWORD}
    TriggerMode::WORD
    ForceTrigger::WORD
    CameraBusyStatus::WORD
    PowerDownMode::WORD
    PowerDownTime::DWORD
    ExpTrgSignal::WORD
    FPSExposureMode::WORD
    FPSExposureTime::DWORD
    ModulationMode::WORD
    CameraSynchMode::WORD
    PeriodicalTime::DWORD
    TimeBasePeriodical::WORD
    AlignDummy3::WORD
    NumberOfExposures::DWORD
    MonitorOffset::LONG
    Signal::NTuple{20,Signal} = ntuple(_->Signal(),20)
    StatusFrameRate::WORD
    FrameRateMode::WORD
    FrameRate::DWORD
    FrameRateExposure::DWORD
    TimingControlMode::WORD
    FastTimingMode::WORD
    Dummy::NTuple{24,WORD}
end

@kwdef @zeros struct Recording
    Size::WORD = Size(Recording)
    StorageMode::WORD
    RecSubmode::WORD
    RecState::WORD
    AcquMode::WORD
    AcquEnableStatus::WORD
    Day::BYTE
    Month::BYTE
    Year::WORD
    Hour::WORD
    Min::BYTE
    Sec::BYTE
    TimeStampMode::WORD
    RecordStopEventMode::WORD
    RecordStopDelayImages::DWORD
    MetaDataMose::WORD
    MetaDataSize::WORD
    MetaDataVersion::WORD
    Dummy1::WORD
    AcquModeExNumberImages::DWORD
    AcquModeExReserved::NTuple{4,DWORD}
    Dummy::NTuple{22,WORD}
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