abstract ModelInterface{T}

description(m::ModelInterface) = "$(typeof(m)): $(m.spec), $(m.subspec)"
function Base.show{T<:ModelInterface}(io::IO, m::T)
    @printf io "Model\n"
    @printf io "%s\n" T
    @printf io "description:\n %s\n"          description(m)
    @printf io "data vintage:           %s\n" data_vintage(m)
end

# Interface for I/O settings
spec(m::ModelInterface)         = m.spec
subspec(m::ModelInterface)      = m.subspec
saveroot(m::ModelInterface)     = get_setting(m, :saveroot)
dataroot(m::ModelInterface)     = get_setting(m, :dataroot)

# Interface for data
data_vintage(m::ModelInterface) = get_setting(m, :data_vintage)

# Interface for general computation settings
use_parallel_workers(m::ModelInterface)    = get_setting(m, :use_parallel_workers)


#=
Build paths to where input/output/results data are stored.

Description:
Creates the proper directory structure for input and output files, treating the DSGE/save
    directory as the root of a savepath directory subtree. Specifically, the following
    structure is implemented:

    dataroot/

    savepathroot/
                 output_data/<spec>/<subspec>/log/
                 output_data/<spec>/<subspec>/<out_type>/raw/
                 output_data/<spec>/<subspec>/<out_type>/work/
                 output_data/<spec>/<subspec>/<out_type>/tables/
                 output_data/<spec>/<subspec>/<out_type>/figures/

Note: we refer to the savepathroot/output_data/<spec>/<subspec>/ directory as saveroot.
=#
"""
```
logpath(model)
```
Returns path to log file. Path built as
```
<output root>/output_data/<spec>/<subspec>/log/log_<filestring>.log
```
"""
function logpath(m::ModelInterface)
    return savepath(m, "log", "log.log")
end

strs = [:work, :raw, :tables, :figures]
fns = [symbol(x, "path") for x in strs]
for (str, fn) in zip(strs, fns)
    @eval begin
        # First eval function
        function $fn{T<:AbstractString}(m::ModelInterface,
                                             out_type::T,
                                             file_name::T="",
                                             filestring_addl::Vector{T}=Vector{T}())
            return savepath(m, out_type, $(string(str)), file_name, filestring_addl)
        end

        # Then, add docstring to it
        @doc $(
        """
        ```
        $fn{T<:AbstractString}(m::ModelInterface, out_type::T, file_name::T="")
        ```

        Returns path to specific $str output file, creating containing directory as needed. If
        `file_name` not specified, creates and returns path to containing directory only. Path built
        as
        ```
        <output root>/output_data/<spec>/<subspec>/<out_type>/$str/<file_name>_<filestring>.<ext>
        ```
        """
        ) $fn
    end
end

# Not exposed to user. Actually create path and insert model string to file name.
function savepath{T<:AbstractString}(m::ModelInterface,
                                     out_type::T,
                                     sub_type::T,
                                     file_name::T="",
                                     filestring_addl::Vector{T}=Vector{T}())
    # Containing dir
    path = joinpath(saveroot(m), "output_data", spec(m), subspec(m), out_type, sub_type)
    if !isdir(path)
        mkpath(path)
    end

    # File with model string inserted
    if !isempty(file_name)
        if isempty(filestring_addl)
            myfilestring = filestring(m)
        else
            myfilestring = filestring(m, filestring_addl)
        end
        (base, ext) = splitext(file_name)
        file_name_detail = base * myfilestring * ext
        path = joinpath(path, file_name_detail)
    end

    return path
end

# Input data handled slightly differently, because it is not model-specific.
"""
```
inpath{T<:AbstractString}(m::ModelInterface, in_type::T, file_name::T="")
```

Returns path to specific input data file, creating containing directory as needed. If
`file_name` not specified, creates and returns path to containing directory only. Valid
`in_type` includes:

* `"data"`: recorded data
* `"cond"`: conditional data - nowcasts for the current forecast quarter, or related
* `"user"`: user-supplied data for starting parameter vector, hessian, or related

Path built as
```
<data root>/<in_type>/<file_name>
```
"""
function inpath{T<:AbstractString}(m::ModelInterface, in_type::T, file_name::T="")
    path = dataroot(m)
    # Normal cases.
    if in_type == "data" || in_type == "cond"
        path = joinpath(path, in_type)
    # User-provided inputs. May treat this differently in the future.
    elseif in_type == "user"
        path = joinpath(path, "user")
    else
        error("Invalid in_type: ", in_type)
    end

    # Containing dir
    if !isdir(path)
        mkpath(path)
    end

    # If file_name provided, return full path
    if !isempty(file_name)
        path = joinpath(path, file_name)
    end

    return path
end

filestring(m::ModelInterface) = filestring(m, Vector{AbstractString}())
filestring(m::ModelInterface, d::AbstractString) = filestring(m, [d])
function filestring{T<:AbstractString}(m::ModelInterface,
                                        d::Vector{T})
    if !m.testing
        filestrings = Vector{T}()
        for (skey, sval) in m.settings
            if sval.print
                push!(filestrings, to_filestring(sval))
            end
        end
        append!(filestrings, d)
        sort!(filestrings)
        return "_"*join(filestrings, "_")
    else
        return "_test"
    end
end
