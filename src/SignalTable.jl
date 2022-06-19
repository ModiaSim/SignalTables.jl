

"""
    sigTable = SignalTable(args...)

Returns a new SignalTable dictionary.

Arguments `args...` are dictionary pairs where `values` must be [`Var`](@ref)(...) or [`Par`](@ref)(...). Example:

```julia
using SignalTables
using Unitful

t = 0.0:0.1:0.5
sigTable = SignalTable(
  "time"         => Var(values= t, unit="s", variability = "independent"),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)]),  
  "motor.angle"  => Var(values= sin.(t), unit="rad"),
  "motor.w_ref"  => Var(values= cos.(t), unit="rad/s", info="Reference"),                       
  "motor.w_m"    => Var(values= Clocked(0.9*cos.(t),factor=2), unit="rad/s", info="Measured"),
  "motor.inertia"=> Par(value = 0.02, unit="kg*m/s^2"),
  "attributes"   => Par(info  = "This is a test signal table")
)
```

The *first* argument must define the *independent* signal, that is, `Var(values=..., variability="independent"), ...`
and `values` must be an `AbstractVector`. Further added signals with a `:values` key, must have the
same first dimension as the independent signal.

Most dictionary operations can be applied on `sigTable`, as well as all functions
of [Function Overview](@ref).

# Examples

```julia
using SignalTables
using Unitful

t = 0.0:0.1:0.5
sigTable = SignalTable(
  "time"         => Var(values= t, unit="s", variability="independent"),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)], unit="m"), 
  "motor.angle"  => Var(values= sin.(t), unit="rad", state=true),
  "motor.w"      => Var(values= cos.(t), unit="rad/s", integral="motor.angle"),
  "motor.w_ref"  => Var(values= 0.9*[sin.(t) cos.(t)], unit = ["rad", "1/s"],
                                info="Reference angle and speed"),  
  "wm"           => Var(alias = "motor.w"),
  "ref.clock"    => Var(values= [true, missing, missing, true, missing, missing],
                                 variability="clock"),  
  "ref.trigger"  => Var(values= [missing, missing, true, missing, true, true],
                                 variability="trigger"), 
  "motor.w_c"    => Var(values= [0.8, missing, missing, 1.5, missing, missing],
                                variability="clocked", clock="ref.clock"),
  "motor.inertia"=> Par(value = 0.02f0, unit="kg*m/s^2"),
  "motor.data"   => Par(value = "resources/motorMap.json"),
  "attributes"   => Par(info  = "This is a test signal table")
)

signalInfo(sigTable)
```

This results in the following output:

```julia
name          unit          size  basetype kind attributes
─────────────────────────────────────────────────────────────────────────────────────────
time          "s"           (6,)  Float64  Var  variability="independent"
load.r        "m"           (6,3) Float64  Var
motor.angle   "rad"         (6,)  Float64  Var  state=true
motor.w       "rad/s"       (6,)  Float64  Var  integral="motor.angle"
motor.w_ref   ["rad","1/s"] (6,2) Float64  Var  info="Reference angle and speed"
wm            "rad/s"       (6,)  Float64  Var  integral="motor.angle", alias="motor.w"
ref.clock                   (6,)  Bool     Var  variability="clock"
ref.trigger                 (6,)  Bool     Var  variability="trigger"
motor.w_c                   (6,)  Float64  Var  variability="clocked", clock="ref.clock"
motor.inertia "kg*m/s^2"    ()    Float32  Par
motor.data                        String   Par
attributes                                 Par  info="This is a test signal table"
```

The command `show(IOContext(stdout, :compact => true), sigTable)` results in the following output:

```julia
SignalTable(
  "time" => Var(values=0.0:0.1:0.5, unit="s", variability="independent"),
  "load.r" => Var(values=[0.0 1.0 0.0; 0.0998334 0.995004 0.0998334; 0.198669 0.980067 0.198669; 0.29552 0.955336 0.29552; 0.389418 0.921061 0.389418; 0.479426 0.877583 0.479426], unit="m"),
  "motor.angle" => Var(values=[0.0, 0.0998334, 0.198669, 0.29552, 0.389418, 0.479426], unit="rad", state=true),
  "motor.w" => Var(values=[1.0, 0.995004, 0.980067, 0.955336, 0.921061, 0.877583], unit="rad/s", integral="motor.angle"),
  "motor.w_ref" => Var(values=[0.0 0.9; 0.0898501 0.895504; 0.178802 0.88206; 0.265968 0.859803; 0.350477 0.828955; 0.431483 0.789824], unit=["rad", "1/s"], info="Reference angle and speed"),
  "wm" => Var(values=[1.0, 0.995004, 0.980067, 0.955336, 0.921061, 0.877583], unit="rad/s", integral="motor.angle", alias="motor.w"),
  "ref.clock" => Var(values=Union{Missing, Bool}[true, missing, missing, true, missing, missing], variability="clock"),
  "ref.trigger" => Var(values=Union{Missing, Bool}[missing, missing, true, missing, true, true], variability="trigger"),
  "motor.w_c" => Var(values=Union{Missing, Float64}[0.8, missing, missing, 1.5, missing, missing], variability="clocked", clock="ref.clock"),
  "motor.inertia" => Par(value=0.02, unit="kg*m/s^2"),
  "motor.data" => Par(value="resources/motorMap.json"),
  "attributes" => Par(info="This is a test signal table"),
  )
```
"""
struct SignalTable <: AbstractDict{String,Any}
    dict::StringDictType
    len::Int              # = length(<values> of independent signal>)

    function SignalTable(args...)
        dict = StringDictType()
        first = true
        len = 0
        for (key, sig) in args
            if !isSignal(sig)
                error("SignalTable($key=signal, ...): The added signal is not a Var(..) or a Par(..)!") 
            end
            if first
                first = false               
                if sig[:variability] != "independent"
                    error("SignalTable(\"$key\"=>signal, ...): The first added signal has not variability=\"independent\", which is required!")
                elseif !haskey(sig, :values)
                    error("SignalTable(\"$key\"=>signal, ...): The first added signal has no `values=...` defined, which is required!")
                elseif !haskey(sig, :values)
                    error("SignalTable(\"$key\"=>signal, ...): The first added signal has no `signal[:values]=...` defined, which is required!")
                end
                sig_values = sig[:values]
                if !(typeof(sig_values) <: AbstractVector)
                     error("SignalTable(\"$key\"=>signal, ...): typeof(signal[:values]) = $(typeof(sig_values))\nbut must be `AbstractVector` since first added signal must be independent variable!")                   
                end
                len = length(sig_values)
            else
                if isVar(sig) 
                    if haskey(sig, :values)
                        sig_values = sig[:values]
                        if !(typeof(sig_values) <: AbstractArray)
                            error("SignalTable(\"$key\"=>signal, ...): typeof(signal[:values]) = $(typeof(sig_values)) but must be an `AbstractArray`!")                   
                        elseif size(sig_values,1) != len
                            error("SignalTable(\"$key\"=>signal, ...): size(signal[:values],1) = $(size(sig_values,1)) but must be $len (= length of independent signal values)!")                   
                        end
                    end
                    if haskey(sig, :integral) 
                        sigIntegral = sig[:integral]
                        if !haskey(dict, sigIntegral)
                            error("SignalTable(\"$key\"=>Var(integral=\"$sigIntegral\"...): referenced signal does not exist")
                        end
                    end
                    if haskey(sig, :alias)
                        aliasName = sig[:alias]
                        if haskey(sig,:values)
                            error("SignalTable(\"$key\"=>Var(values=.., alias=\"$aliasName\"...): not allowed to define values and alias together.")                   
                        elseif !haskey(dict, aliasName)
                            error("SignalTable(\"$key\"=>Var(alias=\"$aliasName\"...): referenced signal does not exist.")
                        end
                        sigAlias = dict[aliasName]
                        sig = merge(sigAlias,sig)
                    end   
                else
                    if haskey(sig, :alias)
                        aliasName = sig[:alias]
                        if haskey(sig,:value)
                            error("SignalTable(\"$key\"=>Par(values=.., alias=\"$aliasName\"...): not allowed to define values and alias together.")                   
                        elseif !haskey(dict, aliasName)
                            error("SignalTable(\"$key\"=>Par(alias=\"$aliasName\"...): referenced signal does not exist.")
                        end
                        sigAlias = dict[:aliasName]
                        sig = merge(sigAlias,sig)
                    end                  
                end
            end
            dict[key] = sig
        end
        new(dict,len)
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
getSignal(sigTable::SignalTable, name::String; require_values=true) = sigTable[name]

