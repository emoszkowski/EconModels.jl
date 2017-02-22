module EconModels

using Base.Dates, DataFrames

const VERBOSITY    = Dict(:none => 0, :low => 1, :high => 2)
const DATE_FORMAT  = "yymmdd"
const DATASERIES_DELIM = "__"

export

    # interface.jl
    ModelInterface, description, spec, subspec,
    dataroot, saveroot, inpath, workpath, rawpath, tablespath, figurespath, logpath, filestring,

    # settings.jl
    Setting, get_setting, default_settings!, default_test_settings!, data_vintage,

    # data_utils.jl
    prev_quarter, next_quarter, get_quarter_ends, stringstodates, quartertodate, subtract_quarters,
    format_dates!, iterate_quarters, na2nan!, iterate_quarters,
 
    # constants
    VERBOSITY, DATE_FORMAT, DATASERIES_DELIM

include("interface.jl")
include("settings.jl")
include("data_utils.jl")

end # module
