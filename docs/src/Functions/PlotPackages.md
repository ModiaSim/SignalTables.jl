# Plot Packages

```@meta
CurrentModule = SignalTables
```

The plot package `XXX` to be used can be defined by:

- `ENV["SignalTablesPlotPackage"] = XXX`\
  (e.g. in .julia/config/startup.jl file: `ENV["SignalTablesPlotPackage"] = "PyPlot"`), or
- by calling [`usePlotPackage`](@ref)(XXX) (e.g. `usePlotPackage("PyPlot")`).

Supported values for `XXX`:

- `"PyPlot"` ([PyPlot](https://github.com/JuliaPy/PyPlot.jl) plots with Matplotlib from Python),
- `"GLMakie"` ([GLMakie](https://github.com/JuliaPlots/GLMakie.jl) provides interactive plots in an OpenGL window),
- `"WGLMakie"` ([WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) provides interactive plots in a browser window),
- `"CairoMakie"` ([CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) provides static plots on file with publication quality).

Furthermore, there is a dummy implementation included in SignalTables that is useful when performing tests with runtests.jl,
in order that no plot package needs to be loaded during the tests:

- `"SilentNoPlot"` (= all plot calls are silently ignored).


Typically, runtests.jl is defined as:

```julia
using SignalTables
usePlotPackage("SilentNoPlot") # Define Plot Package (previously defined one is put on a stack)
include("include_all.jl")      # Include all tests that use a plot package
usePreviousPlotPackage()       # Use previously defined Plot package
```

The following functions are provided to define/inquire the current plot package.

!!! note
    [SignalTables.jl](https://github.com/ModiaSim/SignalTables.jl) exports all symbols of this table.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) reexports all symbols.

| Plot package functions           | Description                                               |
|:---------------------------------|:----------------------------------------------------------|
| [`@usingPlotPackage`](@ref)      | Expands into `using PlotPackage_<PlotPackageName>`        |
| [`usePlotPackage`](@ref)         | Define the plot package to be used.                       |
| [`usePreviousPlotPackage`](@ref) | Define the previously defined plot package to be used.    |
| [`currentPlotPackage`](@ref)     | Return name defined with [`usePlotPackage`](@ref)         |

```@docs
@usingPlotPackage
usePlotPackage
usePreviousPlotPackage
currentPlotPackage
```
