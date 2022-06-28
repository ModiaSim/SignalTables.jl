# SignalTables
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://modiasim.github.io/SignalTables.jl/stable/index.html)
[![The MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](https://github.com/ModiaSim/SignalTables.jl/blob/master/LICENSE)

Package [SignalTables](https://github.com/ModiaSim/SignalTables.jl) (see [docu](https://modiasim.github.io/SignalTables.jl/stable/index.html))
provides abstract and concrete types and functions for *signal tables*.
Typically, simulation results, reference signals, table-based input signals, measurement data,
look-up tables can be represented by a signal table.

A *signal table* is an *ordered dictionary* of *signals* with string keys that supports the
[Abstract Signal Table Interface](https://modiasim.github.io/SignalTables.jl/stable/Internal/AbstractSignalTableInterface.html). 
A *signal* is either a

- [Var](https://modiasim.github.io/SignalTables.jl/stable/Functions/Signals.html#SignalTables.Var) *dictionary* that has a required *:values* key representing a *signal array* of any element type 
  as function of the independent signal(s) (or is the k-th independent signal), or a
- [Par](https://modiasim.github.io/SignalTables.jl/stable/Functions/Signals.html#SignalTables.Par) *dictionary* that has an optional *:value* key representing a constant of any type.

A *signal array* is a *multi-dimensional array* with indices `[i1,i2,...,j1,j2,...]` to hold variable elements `[j1,j2,...]` 
at the `[i1,i2,...]` independent signal(s). If an element of a signal array is *not defined* 
it has a value of *missing*. In both dictionaries, additional attributes can be stored, 
for example units, info texts, variability (continuous, clocked, ...), alias, and user-defined attributes. 

## Examples

```julia
using SignalTables

t = 0.0:0.1:0.5
sigTable = SignalTable(
  "time"         => Var(values= t, unit="s", independent=true),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)], unit="m"),
  "motor.angle"  => Var(values= sin.(t), unit="rad", state=true),
  "motor.w"      => Var(values= cos.(t), unit="rad/s", integral="motor.angle"),
  "motor.w_ref"  => Var(values= 0.9*[sin.(t) cos.(t)], unit = ["rad", "1/s"],
                                info="Reference angle and speed"),
  "wm"           => Var(alias = "motor.w"),
  "ref.clock"    => Var(values= [true, missing, missing, true, missing, missing],
                                 variability="clock"),
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

Command `showInfo` generates the following output:

```julia
name          unit          size  basetype kind attributes
─────────────────────────────────────────────────────────────────────────────────────────
time          "s"           (6,)  Float64  Var  independent=true
load.r        "m"           (6,3) Float64  Var
motor.angle   "rad"         (6,)  Float64  Var  state=true
motor.w       "rad/s"       (6,)  Float64  Var  integral="motor.angle"
motor.w_ref   ["rad","1/s"] (6,2) Float64  Var  info="Reference angle and speed"
wm            "rad/s"       (6,)  Float64  Var  integral="motor.angle", alias="motor.w"
ref.clock                   (6,)  Bool     Var  variability="clock"
motor.w_c                   (6,)  Float64  Var  variability="clocked", clock="ref.clock"
motor.inertia "kg*m/s^2"    ()    Float32  Par
motor.data                        String   Par
attributes                                 Par  info="This is a test signal table"
```

The various Julia FileIO functions can be directly used to save a signal table
in various formats, e.g. JSON or HDF5 (see [FileIO Examples](https://modiasim.github.io/SignalTables.jl/stable/Examples/FileIO.html), 
[json file of sigTable above](docs/resources/examples/fileIO/VariousTypes_prettyPrint.json) ).


```julia
using SignalTable
usePlotPackage("PyPlot")    # or ENV["SignalTablesPlotPackage"] = "PyPlot"

sigTable = getSignalTableExample("MissingValues")

@usingPlotPackage                           # = using SignalTablesInterface_PyPlot
plot(sigTable, [("sigC", "load.r[2:3]"), ("sigB", "sigD")])  # generate plots
```

generate the following plot:

![Plots of SigTable](https://modiasim.github.io/SignalTables.jl/resources/images/sigTable-line-plots.png)

*Concrete implementations* of the [Abstract Signal Table Interface](https://modiasim.github.io/SignalTables.jl/stable/Internal/AbstractSignalTableInterface.html) are provided for:

- [`SignalTable`](https://modiasim.github.io/SignalTables.jl/stable/Functions/SignalTables.html#SignalTables.SignalTable) (included in SignalTables.jl).

  Planned implementations (basically adapting from [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl)):

  - [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment)
  - [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl)
    (tabular data; first column is independent variable; *only scalar variables*))
  - [Tables.jl](https://github.com/JuliaData/Tables.jl)
    (abstract tables, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables;
    first column is independent variable; *only scalar variables*).

*Concrete implementations* of the [Abstract Plot Interface](https://modiasim.github.io/SignalTables.jl/stable/Internal/AbstractPlotInterface.html) are provided for:

- [PyPlot](https://github.com/JuliaPy/PyPlot.jl) (plots with [Matplotlib](https://matplotlib.org/stable/) from Python;
  via [SignalTablesInterface_PyPlot.jl](https://github.com/ModiaSim/SignalTablesInterface_PyPlot.jl)),

  Planned implementations (basically adapting from [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl)):
  
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