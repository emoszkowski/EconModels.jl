module EconModels

const VERBOSITY    = Dict(:none => 0, :low => 1, :high => 2)
const DATE_FORMAT  = "yymmdd"
const DATASERIES_DELIM = "__"

export

    # interface.jl
    ModelInterface, description, spec, subspec,
    dataroot, saveroot, inpath, workpath, rawpath, tablespath, figurespath, logpath, filestring,

    # settings.jl
    Setting, get_setting, default_settings!, default_test_settings!,

    # constants
    VERBOSITY, DATE_FORMAT, DATASERIES_DELIM

include("interface.jl")
include("settings.jl")
include("data_utils.jl")

end # module
