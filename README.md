# SignalTables

Package [SignalTables](https://github.com/ModiaSim/SignalTables.jl) defines
an [Abstract Signal Table Interface](@ref) and an [Abstract Line Plot Interface](@ref)  
together with concrete implementations of these interfaces. 
Furthermore, useful functionality is provided on top of these interfaces (see [Functions](@ref)).

A *signal table* is a (dictionary-like) type that supports the [Abstract Signal Table Interface](@ref) 
for example [`SignalTable`](@ref). It defines a set of *signals* in tabular format. A *signal* is identified by its *name::String*
and is a representation of the values of a variable ``v`` as a (partial) function ``v(t)``
of the values of independent variable ``t = v_{independent}``. 
The values of ``v`` are represented by an array where
`v.values[i,j,k,...]` is element `v[j,k,...]` of variable ``v`` at ``t_i``, i.e. at `t.values[i]`.
If an element is *not defined* at ``t_ì``, it has a value of *missing*.

Example (*Par(..)* are parameters, *motor.w_ref* is a continuous variable,
*motor.w_m* is a clocked variable, *load.r* is a continuous vector variable):

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

signalTables in the following output:

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

The commands

```julia
# Define Plot Package in startup.jl, e.g. `ENV["SignalTablesPlotPackage"] = "PyPlot"`
# Or in Julia session, e.g. `usePlotPackage("PyPlot")`

@usingPlotPackage                                        # activate plot package
plot(sigTable, [("sigA", "sigB", "sigC"), "r[2:3]"])   # generate line plots
```

generate the following line plot:

![Line plots of SigTable](../resources/images/sigTable-line-plots.png)


*Concrete implementations* of the [Abstract Signal Table Interface](@ref) are provided for:

- [`SignalTable`](@ref) (included in SignalTables.jl).
- [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment)
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl)
  (tabular data; first column is independent variable; *only scalar variables*))
- [Tables.jl](https://github.com/JuliaData/Tables.jl)
  (abstract tables, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables;
  first column is independent variable; *only scalar variables*).

*Concrete implementations* of the [Abstract Line Plot Interface](@ref) are provided for:

- [PyPlot](https://github.com/JuliaPy/PyPlot.jl) (plots with [Matplotlib](https://matplotlib.org/stable/) from Python), 
- [GLMakie](https://github.com/JuliaPlots/GLMakie.jl) (interactive plots in an OpenGL window),
- [WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) (interactive plots in a browser window),
- [CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) (static plots on file with publication quality).

Furthermore, there is a dummy implementation included in SignalTables that is useful when performing tests with runtests.jl, 
in order that no plot package needs to be loaded during the tests:

- SilentNoPlot (= all plot calls are silently ignored).


## Installation

Package is not yet registered
