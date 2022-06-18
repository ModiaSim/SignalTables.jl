

"""
    sigTable = SignalTable(args...)

Returns a new SignalTable dictionary.

Arguments `args...` are dictionary key/values. `values` must be [`Var`](@ref)(...) or [`Par`](@ref)(...).
Most dictionary operations can be applied on sigTable, 
and additionally `sigTable.key` is provided as alternative to `sigTable[key]`.

# Examples

```julia
using SignalTables
using Unitful

t = 0.0:0.1:0.5
sigTable = SignalTable(
  "time"         => Var(values= t, unit="s", independent=true),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)]),  
  "motor.angle"  => Var(values= sin.(t), unit="rad"),
  "motor.w_ref"  => Var(values= cos.(t), unit="rad/s", info="Reference"),                       
  "motor.w_m"    => Var(values= Clocked(0.9*cos.(t),factor=2), unit="rad/s", info="Measured"),
  "motor.inertia"=> Par(value = 0.02, unit="kg*m/s^2"),
  "attributes"   => Par(info  = "This is a test signal table")
)
                      
# Abstract Signal Tables Interface
w_m_sig = getSignal(        sigTable, "motor.w_ref")   # = Var(values=..., unit=..., info=...)
w_ref   = getValuesWithUnit(sigTable, "motor.w_ref")   # = [0.0, 0.0998, 0.1986, ...]u"rad/s"
w_m     = getValues(        sigTable, "motor.w_m"  )   # = [0.9, missing, missing, 0.859, ...]
inertia = getValueWithUnit( sigTable, "motor.inertia") # = 0.02u"kg*m/s^2"

showInfo(sigTable)
```

results in the following output:

```julia
 name           unit       size  eltype   kind   attributes
───────────────────────────────────────────────────────────────────
 time           s          (6,)  Float64  Var    independent=true
 load.r                    (6,3) Float64  Var
 motor.angle    rad        (6,)  Float64  Var
 motor.w_ref    rad*s^-1   (6,)  Float64  Var    info="Reference"
 motor.w_m      rad*s^-1   (6,)  Float64  Var    info="Measured"
 motor.inertia  kg*m/s^2   ()    Float64  Par
 attributes                               Par    info="This is a.."
```

The command `show(IOContext(stdout, :compact => true), sigTable)` results in the following output:

```julia
SignalTable(
  "time" => IndependentSignal((0.0:0.1:0.5)*u"s"),
  "motor.angle" => DependentSignal([0.0, 0.0998334, 0.198669, 0.29552, 0.389418, 0.479426]*u"rad"),
  "motor.w_ref" => DependentSignal([1.0, 0.995004, 0.980067, 0.955336, 0.921061, 0.877583]*u"rad*s^-1", info="Reference"),
  "motor.w_m" => DependentSignal([0.9, 0.895504, 0.88206, 0.859803, 0.828955, 0.789824]*u"rad*s^-1", info="Measured"),
  "motor.inertia" => ConstantSignal((0.02)*u"kg*m*s^-2"),
  info = "This is a test signal table"
  )
```
"""
struct SignalTable <: AbstractDict{String,Any}
    dict::StringDictType

    function SignalTable(args...)
        dict = StringDictType()
        first = true
        len = 0
        for (key, sig) in args
            if first
                first = false
                @assert(get(sig, :independent, false) == true)               
                @assert(isVar(sig))
                values = get(sig, :values, nothing)
                @assert(!isnothing(values))
                @assert(ndims(values) == 1)
                len = length(values)
            else
                @assert(isVar(sig) || isPar(sig))
                if isVar(sig)
                    values = get(sig, :values, nothing)
                    @assert(!isnothing(values))
                    @assert( typeof(values) <: AbstractArray )
                    @assert( size(values,1) == len)
                end
            end
            dict[key] = sig
        end
        new(dict)
    end
end
Base.convert(::Type{StringDictType}, sig::SignalTable) = sig.dict

Base.length(sigTable::SignalTable) = length(sigTable.dict)

Base.iterate(sigTable::SignalTable) = Base.iterate(sigTable.dict)
Base.iterate(sigTable::SignalTable, iter) = Base.iterate(sigTable.dict, iter)

Base.haskey(signalTable::SignalTable, key::String)           = Base.haskey(signalTable.dict, key)

Base.get(signalTable::SignalTable, key::String, default)     = Base.get(signalTable.dict, key, default)
Base.get(f::Function, signalTable::SignalTable, key::String) = Base.get(f, signalTable.dict, key)

Base.get!(signalTable::SignalTable, key::String, default)     = Base.get!(signalTable.dict, key, default)
Base.get!(f::Function, signalTable::SignalTable, key::String) = Base.get!(f, signalTable.dict, key)

Base.keys(signalTable::SignalTable)   = Base.keys(signalTable.dict)
Base.values(signalTable::SignalTable) = Base.values(signalTable.dict)

Base.setindex!(signalTable::SignalTable, value, key...) = Base.setindex!(signalTable.dict, value, key...)
Base.getproperty(signalTable::SignalTable, key::String) = signalTable[key]

Base.pop!(signalTable::SignalTable) = Base.pop!(signalTable.dict)

Base.delete!(signalTable::SignalTable, key::String) = Base.delete!(signalTable.dict, key)

function Base.show(io::IO, sigTable::SignalTable)
    print(io, "SignalTable(\n")
    for (key,sig) in sigTable
        Base.print(io, "  ")
        Base.show(io, key)
        Base.print(io, " => ")
        showSignal(io, sig)
        print(io, ",\n")
    end
    println(io,"  )")      
end


# Implementation of AbstractSignalTableInterface

independentSignalName(sigTable::SignalTable) = first(sigTable).first
signalNames(sigTable::SignalTable) = String.(keys(sigTable))
getSignal(sigTable::SignalTable, name::String, default=nothing) = get(sigTable, name, default)

