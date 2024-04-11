function get_library_path()
    default_dir = "C:/Program Files/PCO Digital Camera Toolbox/pco.recorder/bin"
    lib_path = @load_preference("shared library path", default_dir)

    if !isdir(lib_path)
        @error("the library does not exists")
        lib_path = default_dir
    else
        SDK_dll_path = joinpath(lib_path, "sc2_cam.dll")
        recorder_dll_path = joinpath(lib_path, "pco_recorder.dll")
        if !isfile(recorder_dll_path) || !isfile(SDK_dll_path)
            @error("Both 'pco_recorder.dll' and 'sc2_cam.dll' should exist at the library path")
            lib_path = default_dir
        end
    end

    return lib_path
end

const shared_lib_path = get_library_path()

function set_library_path!(lib_path; export_prefs::Bool = false)
    if isnothing(lib_path) || ismissing(lib_path)
        # supports `Preferences` sentinel values `nothing` and `missing`
    elseif !isa(lib_path,String)
        throw(ArgumentError("Invalid provider"))
    elseif !isdir(lib_path)
        throw(ArgumentError("the library does not exists"))
    else
        lib_path = abspath(lib_path)
        SDK_dll_path = joinpath(lib_path, "sc2_cam.dll")
        recorder_dll_path = joinpath(lib_path, "pco_recorder.dll")
        if !isfile(recorder_dll_path) || !isfile(SDK_dll_path)
            throw(ArgumentError("Both 'pco_recorder.dll' and 'sc2_cam.dll' should exist at the library path"))
        end
    end
    set_preferences!(@__MODULE__, "shared library path" => lib_path;export_prefs, force = true)
    if !samefile(lib_path, shared_lib_path)
        # Re-fetch to get default values in the event that `nothing` or `missing` was passed in.
        lib_path = get_library_path()
        @info("The path of shared library is changed; restart Julia for this change to take effect", lib_path)
    end
end