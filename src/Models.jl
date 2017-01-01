module Models

export

    # interface.jl
    ModelInterface, description, spec, subspec,
    dataroot, saveroot, inpath, workpath, rawpath, tablespath, figurespath, logpath,

    # settings.jl
    Setting, get_setting, default_settings!, default_test_settings!

include("interface.jl")
include("settings.jl")

end # module
