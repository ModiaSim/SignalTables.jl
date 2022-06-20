# SignalTables Documentation

```@meta
CurrentModule = SignalTables
```

Package [SignalTables](https://github.com/ModiaSim/SignalTables.jl)
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
motor.data                        String   Par
attributes                                 Par  info="This is a test signal table"
```

The commands

```julia
# Define Plot Package in startup.jl, e.g. `ENV["SignalTablesPlotPackage"] = "PyPlot"`
# Or in Julia session, e.g. `usePlotPackage("PyPlot")`

@usingPlotPackage                                      # activate plot package
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


## Installation of PyPlot.jl

`SignalTablesInterface_PyPlot.jl` uses `PyPlot.jl` which in turn uses Python. 
Therefore a Python installation is needed. Installation 
might give problems in some cases. Here are some hints what to do
(you may also consult the documentation of [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl)).

Before installing `SignalTablesInterface_PyPlot.jl` make sure that `PyPlot.jl` is working:

```julia
]add PyPlot
using PyPlot
t = [0,1,2,3,4]
plot(t,2*t)
```

If the commands above give a plot window. Everything is fine.

If you get errors or no plot window appears or Julia crashes, 
try to first install a standard Python installation from Julia:

```julia
# Start a new Julia session
ENV["PYTHON"] = ""    # Let Julia install Python
]build PyCall
exit()   # Exit Juila

# Start a new Julia session
]add PyPlot
using PyPlot
t = [0,1,2,3,4]
plot(t,2*t)
```

If the above does not work, or you want to use another Python distribution,
install a [Python 3.x distribution](https://wiki.python.org/moin/PythonDistributions) that contains Matplotlib,
set `ENV["PYTHON"] = "<path-above-python-installation>/python.exe"` and follow the steps above.
Note, `SignalTablesInterface_PyPlot` is based on the Python 3.x version of Matplotlib where some keywords
are different to the Python 2.x version.


## Release Notes

### Version 0.5.0-dev

- 


**Non-backwards compatible changes**

- A signalTable data structure has only one time axis (previously, a signalTable datastructure could have several time axes).
  Therefore, function `hasOneTimeSignal` makes no sense anymore and is removed.
  



### Version 0.4.3

- Internal bug fixed.


### Version 0.4.2

- `showResultInfo(..)` and `signalTableInfo(..)` improved
  (signals with one value defined with SignalTables.OneValueVector are specially marked,
  for example parameters).


### Version 0.4.1

- Update of Manifest.toml file


### Version 0.4.0

- Require Julia 1.7
- Upgrade Manifest.toml to version 2.0
- Update Project.toml/Manifest.toml


### Version 0.3.10

- Packages used in test models, prefixed with `SignalTables.` to avoid missing package errors.


### Version 0.3.9

- Wrong link in README.md corrected
- makie.jl: Adapted to newer Makie version (update!(..) no longer known and needed).
- Issue with ustrip fixed.
- Broken test_52_MonteCarloMeasurementsWithDistributions.jl reactivated
- Manifest.toml updated. 

### Version 0.3.8

- Better handling if some input arguments are `nothing`.
- Bug corrected when accessing a vector element, such as `mvec[2]`.
- Documentation slightly improved.


### Version 0.3.7

- Replaced Point2f0 by Makie_Point2f that needs to be defined according to the newest Makie version.


### Version 0.3.6

- Adapt to MonteCarloMeasurements, version >= 1.0 (e.g. pmean(..) instead of mean(..))
- Remove test_71_Tables_Rotational_First.jl from runtests.jl, because "using CSV" 
  (in order that CSV.jl does not have to be added to the Project.toml file)


### Version 0.3.5

- Project.toml: Added version 1 of MonteCarloMeasurements.


### Version 0.3.4

- Project.toml: Added older versions to DataFrames, in order to reduce conflicts.

### Version 0.3.3

- SignalTables/test/Project.toml: DataStructures replaced by OrderedCollections.


### Version 0.3.2

- DataStructures replaced by OrderedCollections.
- Version numbers of used packages updated.


### Version 0.3.1

- Two new views on signalTables added (SignalView and FlattenedSignalView).


### Version 0.3

- Major clean-up of the function interfaces. This version is not backwards compatible to previous versions.


### Version 0.2.2

- Overloaded AstractDicts generalized from `AbstractDict{String,T} where {T}` to\
  `AbstractDict{T1,T2} where {T1<:AbstractString,T2}`.

- Bug fixed.



### Version 0.2.1

- Bug fixed: `<: Vector` changed to `<: AbstractVector`


### Version 0.2.0

- Abstract Interface slightly redesigned (therefore 0.2.0 is not backwards compatible to 0.1.0).

- Modules NoPlot and SilentNoPlot added as sub-modules of SignalTables. These modules are
  activated if plot package "NoPlot" or "SilentNoPlot" are selected.

- Content of directory src_plot moved into src. Afterwards src_plot was removed.

- Directory test_plot merged into test (and then removed).
  

### Version 0.1.0

- Initial version (based on the signalTable plotting developed for [ModiaMath](https://github.com/ModiaSim/ModiaMath.jl)).

## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)

