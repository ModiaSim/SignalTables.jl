# Plot Packages

```@meta
CurrentModule = SignalTables
```

Example to define the plot package to be used:

```julia
using SignalTables
usePlotPackage("PyPlot")    # or ENV["SignalTablesPlotPackage"] = "PyPlot"
```

The following plot packages are supported:

- `"PyPlot"` ([PyPlot](https://github.com/JuliaPy/PyPlot.jl) plots with Matplotlib from Python;
  via [SignalTablesInterface_PyPlot.jl](https://github.com/ModiaSim/SignalTablesInterface_PyPlot.jl)),
- `"GLMakie"` ([GLMakie](https://github.com/JuliaPlots/GLMakie.jl) provides interactive plots in an OpenGL window;
  via [SignalTablesInterface_GLMakie.jl](https://github.com/ModiaSim/SignalTablesInterface_GLMakie.jl)),
- `"WGLMakie"` ([WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) provides interactive plots in a browser window;
  via [SignalTablesInterface_WGLMakie.jl](https://github.com/ModiaSim/SignalTablesInterface_WGLMakie.jl)),
- `"CairoMakie"` ([CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) provides static plots on file with publication quality;
  via [SignalTablesInterface_CairoMakie.jl](https://github.com/ModiaSim/SignalTablesInterface_CairoMakie.jl)).
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
