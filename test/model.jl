using EconModels, Base.Test

###############################################
## 1. Define a model
###############################################

type TestModel <: ModelInterface
    spec::AbstractString
    subspec::AbstractString
    settings::Dict{Symbol,Setting}
    test_settings::Dict{Symbol,Setting}
    testing::Bool
    another_field::Vector{Symbol}
end

###############################################
## 2. Construct model 
###############################################

# Define settings field
settings = Dict{Symbol, Setting}()
settings[:data_vintage] = Setting(:data_vintage, "170217", true, "vint", "Data vintage") # full constructor
settings[:use_parallel_workers] = Setting(:use_parallel_workers, false) # short constructor
tdir = tempdir()
settings[:saveroot] = Setting(:saveroot, tdir)
settings[:dataroot] = Setting(:dataroot, tdir)

# Construct test_settings field
test_settings = Dict{Symbol, Setting}()
test_settings[:data_vintage] = Setting(:data_vintage, "160217", true, "vint", "Test data vintage")

# Random other field
other_field = [:foo, :bar]

# Construct model
m = TestModel("m01", "ss1", settings, test_settings, false, other_field)


###############################################
## 3. Check that everything works
###############################################

# Getting non-test settings 
@test get_setting(m, :data_vintage) == "170217"
@test get_setting(m, :use_parallel_workers) == false

# Getting test settings
m.testing = true
@test get_setting(m, :data_vintage) == "160217"
@test get_setting(m, :use_parallel_workers) == false
@test filestring(m) == "_test"

# Overwriting test settings
a = gensym() # unlikely to clash
b = gensym()
m <= Setting(a, 0, true, "abcd", "a")
m <= Setting(a, 1)
@test m.test_settings[a].value == 1
@test m.test_settings[a].print == true
@test m.test_settings[a].code == "abcd"
@test m.test_settings[a].description == "a"
m <= Setting(b, 2, false, "", "b")
m <= Setting(b, 3, true, "abcd", "b1")
@test m.test_settings[b].value == 3
@test m.test_settings[b].print == true
@test m.test_settings[b].code == "abcd"
@test m.test_settings[b].description == "b1"


# Builtin functions
@test spec(m) == "m01"
@test subspec(m) == "ss1"
@test m.another_field == other_field

# Test filestrings
m.testing = false
m <= Setting(:test, 5, true, "test", "a test setting")
@test m.settings[:test].value == 5
@test ismatch(r"^\s*_test=5_vint=(\d{6})", filestring(m))
@test ismatch(r"^\s*_key=val_test=5_vint=(\d{6})", filestring(m, "key=val"))
@test ismatch(r"^\s*_foo=bar_key=val_test=5_vint=(\d{6})", filestring(m, ["key=val", "foo=bar"]))
m.testing = true

# Model paths. all this should work without errors
m.testing = true
addl_strings = ["foo=bar", "hat=head", "city=newyork"]
for fn in [:rawpath, :workpath, :tablespath, :figurespath]
    @eval $(fn)(m, "test")
    @eval $(fn)(m, "test", "temp")
    @eval $(fn)(m, "test", "temp", addl_strings)
end
