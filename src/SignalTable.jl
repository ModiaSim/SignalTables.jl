

"""
    sigTable = SignalTable(args...)

Returns a new SignalTable dictionary.

Arguments `args...` are dictionary pairs where `values` must be [`Var`](@ref)(...) and/or
[`Par`](@ref)(...) and/or [`Map`](@ref)(...). Example:

The *first* argument must define the *independent* signal, that is, `Var(values=..., independent=true), ...`
and `values` must be an `AbstractVector`. Further added signals with a `:values` key, must have the
same first dimension as the independent signal.

Most dictionary operations can be applied on `sigTable`, as well as all functions
of [Overview of Functions](@ref).

# Examples

```julia
using SignalTables
using Unitful

t = 0.0:0.1:0.5
sigTable = SignalTable(
  "time"         => Var(values= t, unit="s", independent=true),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)], unit="m"),
  "motor.angle"  => Var(values= sin.(t), unit="rad", state=true, der="motor.w"),
  "motor.w"      => Var(values= cos.(t), unit="rad/s"),
  "motor.w_ref"  => Var(values= 0.9*[sin.(t) cos.(t)], unit = ["rad", "1/s"],
                                info="Reference angle and speed"),
  "wm"           => Var(alias = "motor.w"),
  "ref.clock"    => Var(values= [true, missing, missing, true, missing, missing],
                                 variability="clock"),
  "motor.w_c"    => Var(values= [0.8, missing, missing, 1.5, missing, missing],
                                variability="clocked", clock="ref.clock"),
  "motor.inertia"=> Par(value = 0.02f0, unit="kg*m/s^2"),
  "motor.data"   => Par(value = "resources/motorMap.json"),
  "attributes"   => Map(experiment=Map(stoptime=0.5, interval=0.01))
)

signalInfo(sigTable)
```

This results in the following output:

```julia
name          unit          size  eltypeOrType            kind attributes
─────────────────────────────────────────────────────────────────────────────────────────────────────────
time          "s"            [6]   Float64                Var  independent=true
load.r        "m"            [6,3] Float64                Var
motor.angle   "rad"          [6]   Float64                Var  state=true, der="motor.w"
motor.w       "rad/s"        [6]   Float64                Var
motor.w_ref   ["rad", "1/s"] [6,2] Float64                Var  info="Reference angle and speed"
wm            "rad/s"        [6]   Float64                Var  alias="motor.w"
ref.clock                    [6]   Union{Missing,Bool}    Var  variability="clock"
motor.w_c                    [6]   Union{Missing,Float64} Var  variability="clocked", clock="ref.clock"
motor.inertia "kg*m/s^2"           Float32                Par
motor.data                         String                 Par
attributes                                                Map  experiment=Map(stoptime=0.5, interval=0.01)
```

The command `show(IOContext(stdout, :compact => true), sigTable)` results in the following output:

```julia
SignalTable(
  "time" => Var(values=0.0:0.1:0.5, unit="s", independent=true),
  "load.r" => Var(values=[0.0 1.0 0.0; 0.0998334 0.995004 0.0998334; 0.198669 0.980067 0.198669; 0.29552 0.955336 0.29552; 0.389418 0.921061 0.389418; 0.479426 0.877583 0.479426], unit="m"),
  "motor.angle" => Var(values=[0.0, 0.0998334, 0.198669, 0.29552, 0.389418, 0.479426], unit="rad", state=true. der="motor.w"),
  "motor.w" => Var(values=[1.0, 0.995004, 0.980067, 0.955336, 0.921061, 0.877583], unit="rad/s"),
  "motor.w_ref" => Var(values=[0.0 0.9; 0.0898501 0.895504; 0.178802 0.88206; 0.265968 0.859803; 0.350477 0.828955; 0.431483 0.789824], unit=["rad", "1/s"], info="Reference angle and speed"),
  "wm" => Var(values=[1.0, 0.995004, 0.980067, 0.955336, 0.921061, 0.877583], unit="rad/s", alias="motor.w"),
  "ref.clock" => Var(values=Union{Missing, Bool}[true, missing, missing, true, missing, missing], variability="clock"),
  "ref.trigger" => Var(values=Union{Missing, Bool}[missing, missing, true, missing, true, true], variability="trigger"),
  "motor.w_c" => Var(values=Union{Missing, Float64}[0.8, missing, missing, 1.5, missing, missing], variability="clocked", clock="ref.clock"),
  "motor.inertia" => Par(value=0.02, unit="kg*m/s^2"),
  "motor.data" => Par(value="resources/motorMap.json"),
  "attributes" => Map(experiment=Map(stoptime=0.5, interval=0.01)),
  )
```
"""
struct SignalTable <: AbstractDict{String,Any}
    dict::StringDictType
    independendentSignalNames::Vector{String}
    independentSignalsSize::NTuple

    function SignalTable(args...)
        dict = new_signal_table()
        independendentSignalNames = String[]
        independentSignalLengths = Int[]
        k = 0
        for (key, sig) in args
            if !isSignal(sig)
                error("SignalTable(\"$key\" => signal, ...): The added signal is neither a Var(..) nor a Par(..) nor a Map(...)\ntypeof(signal) = $(typeof(sig))!")
            end
            if isVar(sig)
                if haskey(sig, :values)
                    sig_values = sig[:values]
                    if !(typeof(sig_values) <: AbstractArray)
                        error("SignalTable(\"$key\" => signal, ...): typeof(signal[:values]) = $(typeof(sig_values)) but must be an `<: AbstractArray`!")
                    end
                    if get(sig, :independent, false)
                        k += 1
                        ndims_sig = ndims(sig_values)
                        if ndims_sig != 1
                            error("SignalTable(.., $key => ..): Independent signal $key must have one dimension, but has $ndims_sig dimensions.")
                        end
                        push!(independendentSignalNames, key)
                        push!(independentSignalLengths, length(sig_values))
                    else
                        for (i,val) in enumerate(independentSignalLengths)
                            if size(sig_values, i) != val
                                error("SignalTable(\"$key\" => signal, ...): size(signal[:values],$i) = $(size(sig_values,i)) but must be $val (= length of independent signal)!")
                            end
                        end
                    end
                else
                    # Needs not have :values, e.g. alias
                    # error("SignalTable(\"$key\" => signal, ...) is a Var(..) and has no key :values which is required!")
                end
                if haskey(sig, :alias)
                    aliasName = sig[:alias]
                    if haskey(sig,:values)
                        error("SignalTable(\"$key\" => Var(values=.., alias=\"$aliasName\"...): not allowed to define values and alias together.")
                    elseif !haskey(dict, aliasName)
                        error("SignalTable(\"$key\" => Var(alias=\"$aliasName\"...): referenced signal does not exist.")
                    end
                    sigAlias = dict[aliasName]
                    sig = merge(sigAlias,sig)
                end
            elseif isPar(sig)
                if haskey(sig, :alias)
                    aliasName = sig[:alias]
                    if haskey(sig,:value)
                        error("SignalTable(\"$key\" => Par(values=.., alias=\"$aliasName\"...): not allowed to define values and alias together.")
                    elseif !haskey(dict, aliasName)
                        error("SignalTable(\"$key\" => Par(alias=\"$aliasName\"...): referenced signal does not exist.")
                    end
                    sigAlias = dict[aliasName]
                    sig = merge(sigAlias,sig)
                end
            end
            dict[key] = sig
        end
        new(dict, independendentSignalNames, ntuple(i -> independentSignalLengths[i], length(independentSignalLengths)))
    end
end
Base.convert(::Type{StringDictType}, sig::SignalTable) = sig.dict

Base.length(sigTable::SignalTable) = length(sigTable.dict)

Base.iterate(sigTable::SignalTable) = Base.iterate(sigTable.dict)
Base.iterate(sigTable::SignalTable, iter) = Base.iterate(sigTable.dict, iter)

Base.haskey(signalTable::SignalTable, key::String)           = Base.haskey(signalTable.dict, key)

Base.getindex(signalTable::SignalTable, key...)              = Base.getindex(signalTable.dict, key...)
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
        if key != "_class"
            Base.print(io, "  ")
            Base.show(io, key)
            Base.print(io, " => ")
            showSignal(io, sig)
            print(io, ",\n")
        end
    end
    println(io,"  )")
end


# Implementation of AbstractSignalTableInterface
isSignalTable(            sigTable::SignalTable)    = true
getIndependentSignalNames(sigTable::SignalTable)    = sigTable.independendentSignalNames
getIndependentSignalsSize(sigTable::SignalTable)    = sigTable.independentSignalsSize
getSignal(     sigTable::SignalTable, name::String) = sigTable[name]
hasSignal(     sigTable::SignalTable, name::String) = haskey(sigTable, name)
function getSignalNames(sigTable::SignalTable; getVar=true, getPar=true, getMap=true)
    if getVar && getPar && getMap
        sigNames = setdiff(String.(keys(sigTable)), ["_class"])
    else
        sigNames = String[]
        for (key,value) in sigTable.dict
            if getVar && isVar(value) ||
               getPar && isPar(value) ||
               getMap && isMap(value)
                push!(sigNames, key)
            end
        end
    end
    return sigNames
end

function getDefaultHeading(sigTable::SignalTable)::String
    attr = get(sigTable, "attributes", "")
    if attr == ""
        return ""
    else
        return get(attr, :plotHeading, "")
    end
end


"""
    toSignalTable(signalTable)::SignalTable

Returns a signalTable as instance of [`SignalTable`](@ref).
"""
function toSignalTable(sigTable)::SignalTable
    if !isSignalTable(sigTable)
        error("toSignalTable(obj): obj::$(typeof(sigTable)) is no signal table.")
    end
    sigTable2 = SignalTable()
    for name in getSignalNames(sigTable)
        sigTable2[name] = getSignal(sigTable,name)
    end
    return sigTable2
end

