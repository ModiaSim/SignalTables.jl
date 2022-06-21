module test_SignalTypes

using SignalTables
using SignalTables.Unitful
using SignalTables.Test

@test basetype([1.0,2.0,3.0])     == Float64
@test basetype([1.0,missing,3.0]) == Float64
@test basetype("abc")             == String
@test basetype((1,1.0,"abc"))     == Tuple{Int64, Float64, String}

s = 2.1u"m/s"
v = [1.0, 2.0, 3.0]u"m/s"

s_unit = unitAsParseableString(s)
v_unit = unitAsParseableString(v)

@test s_unit == "m*s^-1"
@test v_unit == "m*s^-1"

# Check that parsing the unit string works
s_unit2 = uparse(s_unit)
v_unit2 = uparse(s_unit)

mutable struct Data{FloatType <: AbstractFloat}
    velocity::quantity(FloatType, u"m/s")
end

v = Data{Float64}(2.0u"mm/s")
@show v  # v = Data{Float64}(0.002 m s^-1)

sig = Vector{Union{Missing,quantity(Float64,u"m/s")}}(missing,3)
append!(sig, [1.0, 2.0, 3.0]u"m/s")
append!(sig, fill(missing, 2))
@show sig   # Union{Missing, Unitful.Quantity{xxx}}[missing, missing, missing, 1.0 m s^-1, 2.0 m s^-1, 3.0 m s^-1, missing, missing]

end