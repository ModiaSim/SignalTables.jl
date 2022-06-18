# SignalTables Documentation

```@meta
CurrentModule = SignalTables
```

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

The commands

```julia
# Define Plot Package in startup.jl, e.g. `ENV["SignalTablesPlotPackage"] = "PyPlot"`
# Or in Julia session, e.g. `usePlotPackage("PyPlot")`

@usingModiaPlot                                        # activate plot package
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

All packages are registered and are installed with:

```julia
julia> ]add ModiaResult
        add ModiaPlot_PyPlot        # if plotting with PyPlot desired
        add ModiaPlot_GLMakie       # if plotting with GLMakie desired
        add ModiaPlot_WGLMakie      # if plotting with WGLMakie desired
        add ModiaPlot_CairoMakie    # if plotting with CairoMakie desired
```

If you have trouble installing `ModiaPlot_PyPlot`, see 
[Installation of PyPlot.jl](https://modiasim.github.io/ModiaResult.jl/stable/index.html#Installation-of-PyPlot.jl)


## Installation of PyPlot.jl

`ModiaPlot_PyPlot.jl` uses `PyPlot.jl` which in turn uses Python. 
Therefore a Python installation is needed. Installation 
might give problems in some cases. Here are some hints what to do
(you may also consult the documentation of [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl)).

Before installing `ModiaPlot_PyPlot.jl` make sure that `PyPlot.jl` is working:

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
Note, `ModiaPlot_PyPlot` is based on the Python 3.x version of Matplotlib where some keywords
are different to the Python 2.x version.


## Release Notes

### Version 0.5.0-dev

- 


**Non-backwards compatible changes**

- A result data structure has only one time axis (previously, a result datastructure could have several time axes).
  Therefore, function `hasOneTimeSignal` makes no sense anymore and is removed.
  



### Version 0.4.3

- Internal bug fixed.


### Version 0.4.2

- `showResultInfo(..)` and `resultInfo(..)` improved
  (signals with one value defined with ModiaResult.OneValueVector are specially marked,
  for example parameters).


### Version 0.4.1

- Update of Manifest.toml file


### Version 0.4.0

- Require Julia 1.7
- Upgrade Manifest.toml to version 2.0
- Update Project.toml/Manifest.toml


### Version 0.3.10

- Packages used in test models, prefixed with `ModiaResult.` to avoid missing package errors.


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

- ModiaResult/test/Project.toml: DataStructures replaced by OrderedCollections.


### Version 0.3.2

- DataStructures replaced by OrderedCollections.
- Version numbers of used packages updated.


### Version 0.3.1

- Two new views on results added (SignalView and FlattenedSignalView).


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

- Modules NoPlot and SilentNoPlot added as sub-modules of ModiaResult. These modules are
  activated if plot package "NoPlot" or "SilentNoPlot" are selected.

- Content of directory src_plot moved into src. Afterwards src_plot was removed.

- Directory test_plot merged into test (and then removed).
  

### Version 0.1.0

- Initial version (based on the result plotting developed for [ModiaMath](https://github.com/ModiaSim/ModiaMath.jl)).

## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)

