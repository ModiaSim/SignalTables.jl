# License for this file: MIT (expat)
# Copyright 2022, DLR Institute of System Dynamics and Control (DLR-SR)
# Developer: Martin Otter, DLR-SR
#
# This file is part of module SignalTables

"""
    const SymbolDictType = OrderedDict{Symbol,Any}

Predefined dictionary type used for attributes.
"""
const SymbolDictType = OrderedDict{Symbol,Any}
SymbolDict(; kwargs...) = SymbolDictType(kwargs)


"""
    const StringDictType = OrderedDict{String,Any}

Predefined dictionary type used for the signal dictionary.
"""
const StringDictType = OrderedDict{String,Any}
StringDict(; kwargs...) = StringDictType(kwargs)



# Copied from Modia/src/ModelCollections.jl
function newCollection(kwargs, kind)
    m = OrderedDict{Symbol, Any}(kwargs)
    m[:_class] = kind
    m 
end


"""
    Var(; kwargs...)

Returns a dictionary of variable definitions.

# Example

```julia
using SignalTables

t = (0.0:0.1:0.5)
t_sig = Var(values = t, unit=u"s", independent=true),
w_sig = Var(values = sin.(t), unit="rad/s", info="Motor angular velocity"),
```
"""
Var(;kwargs...) = newCollection(kwargs, :Var)
    
    
"""
    Par(; kwargs...)

Returns a dictionary of parameter definitions.

# Example

```julia
using SignalTables

J = Par(value = 0.02, unit=u"kg*m/s^2", info="Motor inertia")
```
"""
Par(; kwargs...) = newCollection(kwargs, :Par)
    
isVar(signal) = get(signal, :_class, :_) == :Var
isPar(signal) = get(signal, :_class, :_) == :Par

"""
    showSignal([io=stdout,] signal)
    
Print a [`Var`](@ref)(...) or [`Par`](@ref)(...) signal to io.
"""
function showSignal(io, sig)
    if isVar(sig)
        print(io, Var)
    elseif isPar(sig)
        print(io, Par)
    else
        print(io, typeof(sig))
    end
    print(io, "(")
    first = true
    for (key,val) in sig
        if key != :_class
            if first
                first = false
            else
                print(io, ", ")
            end            
            print(io, key, "=")
            show(io, val)
        end            
    end
    print(io, ")")
end
showSignal(sig) = showSignal(stdout, sig)


"""
    independentSignalName(signalTable)
    
Returns the name of the independent signal (typically: "time") from signalTable
"""
function independentSignalName end


"""
    signalNames(signalTable)
    
Returns a string vector of the signal names that are present in signalTable
(including independent signal name).
"""
function signalNames end


"""
    getSignal(signalTable, name::String, default=nothing)
    
Returns signal `name` from `signalTable` as [`Var`](@ref) or as [`Par`](@ref).
If `name` does not exist, default is returned.
"""
function getSignal end


# ----------- Functions that have a default implementation ----------------------------------------

"""
    hasSignal(signalTable, name::String)
    
Returns `true` if signal `name` is available in `signalTable`.
"""
hasSignal(signalTable, name::String)::Bool = !isnothing( getSignal(signalTable, name) )

    
"""
    signalInfo(signalTable, name::String)
    signalInfo(signal)   # signal is Var() or Par()
  
Returns a copy of signal `name` from `signalTable` with exception of keys `values/value` and with additional keys 
- `type` (= typeof(values) or typeof(value)) and
- `size` (= size(values) or size(value)),

Note, some signal table types might provide `signalInfo` since it is
possible to provide this information cheaply, whereas the default
implementation is based on `getSignal` which might be an expensive operation,
since all variable values must be (potentially) transformed into multi-dimensional arrays.
"""
function signalInfo(sig)
    if haskey(sig, :values) 
        val = sig[:values] 
        info = merge(sig, Var(type=typeof(val), size=size(val)))
    elseif haskey(sig, :value)
        val = sig[:value] 
        info = merge(sig, Par(type=typeof(val), size=size(val)))    
    else
        info = copy(sig)
    end
    delete!(info, :values)
    delete!(info, :value)
end
signalInfo(signalTable, name::String) = signalInfo( getSignal(signalTable,name) )



getValues(signalTable, name::String) = getSignal(signalTable, name)[:values]
getValue( signalTable, name::String) = getSignal(signalTable, name)[:value]

getValuesWithUnit(signalTable, name::String) = begin
    sig = getSignal(signalTable, name)
    sigUnit = get(sig, :unit, "") 
    sigVal  = sig[:values]
    if sigUnit != ""
        eval(:(import Unitful;  $sigVal*Unitful.@u_str($sigUnit)))
    end
end

getValueWithUnit(signalTable, name::String) = begin
    sig = getSignal(signalTable, name)
    sigUnit = get(sig, :unit, "") 
    sigVal  = sig[:value]
    if sigUnit != ""
        eval(:(import Unitful;  $sigVal*Unitful.@u_str($sigUnit)))
    end
end
