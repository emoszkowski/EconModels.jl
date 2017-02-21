# EconModels.jl

This is a package that defines an implicit interface for economic and
statistical models. No particular mathematical setup is required; rather, the package sets up an infrastructure for handling
computational settings and I/O - problems that are common when trying out various models. Users can import this package to
extend its functionality and create model subtypes. The code is
excerpted from [DSGE.jl](https://github.com/FRBNY-DSGE/DSGE.jl) for
more general use.

`Models.jl` provides I/O methods and a mechanism for handling
computational settings for the `ModelInterface` abstract type.
See
[here](http://frbny-dsge.github.io/DSGE.jl/latest/implementation_details.html#Model-Settings-1) for
more details on how model settings are implemented and why they are
useful,
and
[here](http://frbny-dsge.github.io/DSGE.jl/latest/running_existing_model.html#Input/Output-Directory-Structure-1) for
a description of I/O.

## Usage

The user should import `Models` and define a concrete subtype:

```julia
import Models
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


The following settings are expected to exist in the `settings` dictionary:

- `data_vintage`: a datestring in format "yymmdd"
- `use_parallel_workers`: a boolean indicating whether to parallelize or not
- `saveroot`: a filepath to the location where output directory tree should begin.
- `dataroot`: a filepath to the location where input data can be read from



They can be added to the the model object during or after construction.
