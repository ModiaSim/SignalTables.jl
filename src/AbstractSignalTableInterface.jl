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


# Copied from Modia/src/ModelCollections.jl (= newCollection) and adapted
function newSignal(kwargs, kind)::OrderedDict{Symbol,Any}
    sig = OrderedDict{Symbol, Any}(kwargs)
    sig[:_class] = kind
    
    if kind == :Var && haskey(sig, :values)
        values = sig[:values]       
        if !(typeof(values) <: AbstractArray)
            error("Var(values=..): typeof(values) = $(typeof(values)), but must be an Array")
        end
        if haskey(sig, :unit)
            sigUnit = sig[:unit]
            if typeof(sigUnit) <: AbstractArray && 
               ndims(values) != ndims(sigUnit)+1 &&
               ndims(values) < 2 &&
               size(values)[2:end] != size(sigUnit)
                error("Var(values=..., unit=...): size(unit) = $(size(sigUnit)) and size(values)[2:end] = $(size(values)[2:end]) do not agree")
            end
        end
        sig[:eltype] = eltype(values)
        sig[:size]   = size(values)
    elseif kind == :Par && haskey(sig, :value)
        value = sig[:value]
        sig[:type] = typeof(value)
        valSize = nothing
        try
            valSize = size(value)
        catch
            valSize = nothing
        end
        if !isnothing(valSize)
            sig[:size] = valSize
        end
        if haskey(sig, :unit)
            sigUnit = sig[:unit]
            if typeof(sigUnit) <: AbstractArray && size(value) != size(sigUnit)
                error("Par(value=..., unit=...): size(unit) = $(size(sigUnit)) and size(value) = $(size(values)) do not agree")
            end
        end        
    end 
    return sig
end


"""
    signal = Var(; kwargs...)::OrderedDict{Symbol,Any}

Returns a *variable* signal definition in form of a dictionary.
`kwargs...` are key/value pairs of variable attributes.

The values of a variable ``v(t)`` are stored as `signal[:values]` 
and are represented by an array where `signal[:values][i,j,k,...]` is value `v[j,k,...]`
of variable ``v(t)`` at ``t_i``. If an element of ``v`` is not defined at ``t_ì``​, it has a value of *missing*.

The following keys are recognized (all are *optional*, but usually at least either `:values` or `:eltype` and `:size` are provided):

|key             | value (of type String, if not obvious from context)                                                   |
|:---------------|:------------------------------------------------------------------------------------------------------|
|`:values`       | `Array{T,N}` such that `signal[:values][i,j,k,...]` is value `v[j,k,...]` of ``v(t_i)``.              |
|`:eltype`       | `= eltype( signal[:values] )`. *Automatically included*, if `:values` is provided.                    |
|`:size`         | `= size( signal[:values] )`. *Automatically included*, if `:values` is provided.                      |
|`:unit`         | Unit of all signal elements (parseable with `Unitful.uparse`), e.g., `"kg*m*s^2"`.                    |
|                | `Vector{String}`: `signal[:unit][j,k,...]` is unit of variable element `v[j,k,...]`.                  |
|`:info`         | Short description of signal (= `description` of [FMI 3.0](https://fmi-standard.org/docs/3.0/) and of [Modelica](https://specification.modelica.org/maint/3.5/MLS.html)).  |
|`:causality`    | Causality of signal (`"independent", "input", "output", "local"`).                                    |         
|`:variability`  | Time dependency of signal (`"tunable", "discrete", "clocked", "clock", "trigger", "continuous"`).     |
|`:state`        | = true, if signal is a (discrete, clocked or continuous) state.                                       |       
|`:integral`     | [`getSignal`](@ref)`(signalTable, signal[:integral])[:values]` is the *integral* of `signal[:values]`.          |
|`:clock`        | [`getSignal`](@ref)`(signalTable, signal[:clock])[:values]` is the *clock* associated with `signal[:values]` (is only defined at clock ticks and otherwise is *missing*). |
|                | If `Vector{String}`, a set of clocks is associated with the signal.                                   |
|`:alias`        | `signal[:values]` is a reference to [`getSignal`](@ref)`(signalTable, signal[:alias])[:values]` (and attributes are merged) |
|`:interpolation`| Interpolation of signal points (`"linear", "none"`)                                                   |
|`:extrapolation`| Extrapolation outside the values of the independent signal (`"none"`).                                |

- `:alias` takes effect when adding the Var-signal to a signal table.

- Line plots are constructed with `:interpolation`, if provided, and otherwise from `:variability` if provided, and otherwise
  the `signal[:values]` points are linearly interpolated.

Additionally, any other signal attributes can be stored in `signal` with a desired key, especially
the *Variable Types* of [FMI 3.0](https://fmi-standard.org/docs/3.0/#definition-of-types).

# Example

```julia
using SignalTables

t = (0.0:0.1:0.5)
t_sig = Var(values = t, unit=u"s",  variability="independent")
w_sig = Var(values = sin.(t), unit="rad/s", info="Motor angular velocity")
c_sig = Var(values = [1.0, missing, missing, 4.0, missing, missing],
            variability="clocked", interpolation="none")
b_sig = Var(values = [false, true, true, false, false, true])
```
"""
Var(;kwargs...) = newSignal(kwargs, :Var)
    
    
"""
    signal = Par(; kwargs...)::OrderedDict{Symbol,Any}

Returns a *parameter* signal definition in form of a dictionary.
A parameter is a variable that is constant and is not a function
of the independent variable. 
`kwargs...` are key/value pairs of parameter attributes.

The value of a parameter variable ``v(t) = v_{const}`` is stored with key `:value` in `signal` 
and is an instance of a Julia type (number, string, array, tuple, dictionary, ...).

The following keys are recognized (all are *optional*, but usually at least either `:value` or `:type` are provided):

| key      | value (of type String, if not obvious from context)                                                   |
|:---------|:------------------------------------------------------------------------------------------------------|
| `:value` | `signal[:value]::Any` is constant value ``v(t)=v_{const}`` at all values ``t_i``.                     |
| `:type`  | `= type( signal[:value] )`. *Automatically included*, if `:value` is provided.                        |
| `:size`  | `= size( signal[:values] )`, if size(..) is defined. *Automatically included*.                        |
| `:unit`  | Unit of all signal elements (parseable with `Unitful.uparse`), e.g., `"kg*m*s^2"`.                    |
|          | `Vector{String}`: `signal[:unit][j,k,...]` is unit of variable element `v[j,k,...]`.                  |
| `:info`  | Short description of signal (= `description` of [FMI 3.0](https://fmi-standard.org/docs/3.0/) and of [Modelica](https://specification.modelica.org/maint/3.5/MLS.html)).  |
| `:alias` | `signal[:value]` is a reference to [`getSignal`](@ref)`(signalTable, signal[:alias])[:value]` (and attributes are merged) |

- `:alias` takes effect when adding the Var-signal to a signal table.

Additionally, any other signal attributes can be stored in `signal` with a desired key, especially
the *Variable Types* of [FMI 3.0](https://fmi-standard.org/docs/3.0/#definition-of-types).


# Example

```julia
using SignalTables

J         = Par(value = 0.02, unit=u"kg*m/s^2", info="Motor inertia")
fileNames = Par(value = ["data1.json", "data2.json"])
```
"""
Par(; kwargs...) = newSignal(kwargs, :Par)
    

isVar(signal)    = get(signal, :_class, :_) == :Var
isPar(signal)    = get(signal, :_class, :_) == :Par
isSignal(signal) = begin
    _class = get(signal, :_class, :_)
    _class == :Var || _class == :Par
end


const doNotShow = [:_class, :eltype, :type, :size]

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
        if key in doNotShow
            continue
        end
        
        if first
            first = false
        else
            print(io, ", ")
        end            
        print(io, key, "=")
        show(io, val)        
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
    getSignal(signalTable, name::String; require_values=true)
    
Returns signal `name` from `signalTable` as [`Var`](@ref) or as [`Par`](@ref).

- If `name` does not exist, an error is raised.
- If `require_values=false`, the signal need not return `:values` ([`Var`](@ref)) or `:value` ([`Par`](@ref)).\
  This option is useful, if only the attributes of a signal are needed, but not their values
  (returning the attributes might be a *cheap* operation, whereas returning the values in the form
  required by the [Abstract Signal Table Interface](@ref) might be an *expensive* operation).
"""
function getSignal end


# ----------- Functions that have a default implementation ----------------------------------------

"""
    hasSignal(signalTable, name::String)
    
Returns `true` if signal `name` is present in `signalTable`.
"""
function hasSignal(signalTable, name::String)::Bool
    hasName = true
    try
        sig = getSignal(signalTable, name, with_values=false)
    catch
        hasName = false
    end
    return hasName
end
