# EconModels.jl

This is a package that defines an implicit interface for economic and
statistical models. No particular mathematical setup is required; rather, the package sets up an infrastructure for handling
computational settings and I/O - problems that are common when trying out various models. Users can import this package to
extend its functionality and create model subtypes. The code is
excerpted from [DSGE.jl](https://github.com/FRBNY-DSGE/DSGE.jl) for
more general use.

`EconModels.jl` provides I/O methods and a mechanism for handling
computational settings for the `ModelInterface` abstract type.
See
[here](http://frbny-dsge.github.io/DSGE.jl/latest/implementation_details.html#Model-Settings-1) for
more details on how model settings are implemented and why they are
useful,
and
[here](http://frbny-dsge.github.io/DSGE.jl/latest/running_existing_model.html#Input/Output-Directory-Structure-1) for
a description of I/O.

## Usage

The user should import `EconModels` and define a concrete subtype:

```julia
import EconModels
type MyModel <: ModelInterface
   ...
end
```

Concrete subtypes of `ModelInterface` are assumed to have the following fields:

- `spec::AbstractString`: a model specification identifier
- `subspec::AbstractString`: a model subspecification identifier
- `settings::Dict{Symbol,Setting}`: a dictionary of model settings
- `test_settings::Dict{Symbol,Setting}`: a dictionary of model test settings
- `testing::Bool`: a boolean for indicating whether to use `test_settings` rather than `settings`
- any additional fields desired by the user.

and the following settings are expected to exist in the `settings` dictionary:

- `data_vintage`: a datestring in format "yymmdd"
- `use_parallel_workers`: a boolean indicating whether to parallelize or not
- `saveroot`: a filepath to the location where output directory tree should begin.
- `dataroot`: a filepath to the location where input data can be read from

These settings can be passed in to the model constructor via the
`settings` dictionary, or can be added to the the model object during
or after construction using the `<=` syntax:

```julia
# Initialize arguments to MyModel
settings = Dict{Symbol, Setting}()
settings[:data_vintage] = Setting(:data_vintage, "170101", "true", "vint", "Vintage of data used")

# Construct an instance of MyModel
m = MyModel(spec,subspec,settings,test_settings,testing)

# Add setting to m.settings
m <= Setting(:dataroot, "/path/to/data")
```

If `m.testing = true`, the `<=` syntax will add the setting to `m.test_settings` rather than `m.settings`.

*Note: In some cases, especially if `MyModel` contains many fields, it
can be useful to write a constructor with no arguments. See DSGE.jl
for an example of how you might do that.*
