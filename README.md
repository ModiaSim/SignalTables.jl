# SignalTables
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://modiasim.github.io/SignalTables.jl/stable/index.html)
[![The MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](https://github.com/ModiaSim/SignalTables.jl/blob/master/LICENSE)

Package [SignalTables](https://github.com/ModiaSim/SignalTables.jl) (see [docu](https://modiasim.github.io/SignalTables.jl/stable/index.html))
provides types and functions for *signals* that are represented by
*multi-dimensional* arrays with identical first dimensions and are collected in *tables*.
Typically, simulation results, reference signals, and table-based input signals
can be represented by a *signal table*. More specifically:

A *signal table* is a (dictionary-like) type that supports the [Abstract Signal Table Interface](@ref)
for example [`SignalTable`](@ref). It defines a set of *signals* in tabular format. A *signal* is identified
by its String *name* and is a representation of the values of a variable ``v`` as a (partial) function ``v(t)``
of the independent variable ``t = v_{independent}``.

The values of ``v(t)`` are stored with key `:values` in dictionary [`Var`](@ref) (= abbreviation for *Variable*)
and are represented by an array where `v.values[i,j,k,...]` is element `v[j,k,...]` of
variable ``v`` at ``t_i``. If an element of ``v`` is *not defined* at
``t_ì``, it has a value of *missing*.\
If ``v(t) = v_{const}`` is constant, it is stored in element `:value` in dictionary [`Par`](@ref)
(= abbreviation for *Parameter*) and is represented by any Julia type where
`v.value` is the value of ``v_{const}`` at all elements ``t_i``.

Example:

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

phi_m_sig = getSignal(        sigTable, "motor.angle")   # = Var(values=..., unit=..., ...)
phi_m     = getValuesWithUnit(sigTable, "motor.angle")   # = [0.0, 0.0998, 0.1986, ...]u"rad"
w_c       = getValues(        sigTable, "motor.w_c"  )   # = [0.8, missing, missing, 1.5, ...]
inertia   = getValueWithUnit( sigTable, "motor.inertia") # = 0.02u"kg*m/s^2"
getValues(sigTable, "motor.w") === getValues(sigTable, "wm")

showInfo(sigTable)
```

The last command generates the following output:

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
motor.data                  ()    String   Par
attributes                                 Par  info="This is a test signal table"
```

The commands

```julia
usePlotPackage("PyPlot")    # or ENV["SignalTablesPlotPackage"] = "PyPlot"
...
@usingPlotPackage                                     # = using SignalTablesInterface_PyPlot
plot(sigTable, [("sigA", "sigB", "sigC"), "r[2:3]"])  # generate line plots
```

generate the following line plot:

![Line plots of SigTable](https://modiasim.github.io/SignalTables.jl/resources/images/sigTable-line-plots.png)

*Concrete implementations* of the [Abstract Signal Table Interface](@ref) are provided for:

- [`SignalTable`](@ref) (included in SignalTables.jl).

Planned implementations (basically adapting from SignalTables.jl):

- [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment)
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl)
  (tabular data; first column is independent variable; *only scalar variables*))
- [Tables.jl](https://github.com/JuliaData/Tables.jl)
  (abstract tables, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables;
  first column is independent variable; *only scalar variables*).

*Concrete implementations* of the [Abstract Line Plot Interface](@ref) are provided for:

Planned implementations (basically adapting from SignalTables.jl):

- [PyPlot](https://github.com/JuliaPy/PyPlot.jl) (plots with [Matplotlib](https://matplotlib.org/stable/) from Python),
- [GLMakie](https://github.com/JuliaPlots/GLMakie.jl) (interactive plots in an OpenGL window),
- [WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) (interactive plots in a browser window),
- [CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) (static plots on file with publication quality).

Furthermore, there is a dummy implementation included in SignalTables that is useful when performing tests with runtests.jl,
in order that no plot package needs to be loaded during the tests:

- SilentNoPlot (= all plot calls are silently ignored).


## Installation

The packages are not yet registered. Once this is done, installation is performed with

```julia
julia> ]add SignalTables
        add SignalTablesInterface_PyPlot        # if plotting with PyPlot desired
        add SignalTablesInterface_GLMakie       # if plotting with GLMakie desired
        add SignalTablesInterface_WGLMakie      # if plotting with WGLMakie desired
        add SignalTablesInterface_CairoMakie    # if plotting with CairoMakie desired
```

If you have trouble installing `SignalTablesInterface_PyPlot`, see
[Installation of PyPlot.jl](https://modiasim.github.io/SignalTables.jl/stable/index.html#Installation-of-PyPlot.jl)


## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)