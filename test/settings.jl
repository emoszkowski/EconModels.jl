using EconModels

# Test promote rules and converts

test1 = Setting(:test1, 22.0) # short constructor
vint = Setting(:data_vintage, "REF", true, "vint", "Data vintage") # full constructor

@test promote_rule(Setting{Float64}, Float16) == Float64
@test promote_rule(Setting{Bool}, Bool) == Bool
@test promote_rule(Setting{ASCIIString}, AbstractString) == UTF8String
@test convert(Int64, test1) == 22
@test convert(Float32, test1) == Float32(22.)
@test convert(ASCIIString, vint) == "REF"
