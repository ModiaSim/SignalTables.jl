# Plots

```@meta
CurrentModule = SignalTablesInterface_PyPlot
```

The functions below are used to *plot* one or more signalTable signals in one or more *diagrams*
within one or more *windows* (figures), and *save* a window (figure) in various *formats* on file
(e.g. png, pdf). The functions below are available after

```julia
using SignalTables   # Make Symbols available
@usingPlotPackage    # Define used Plot package (expands e.g., into: using PlotPackage_PyPlot)
```

or

```
using Modia
@usingPlotPackage
```

have been executed. The documentation has been generated with [SignalTablesInterface_PyPlot](https://github.com/ModiaSim/SignalTablesInterface_PyPlot.jl).

!!! note
    [SignalTables.jl](https://github.com/ModiaSim/SignalTables.jl) exports all symbols of the table.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) reexports all symbols and uses as *signalTable* argument `instantiatedModel`.

| Plot functions       | Description                                                    |
|:--------------------------|:---------------------------------------------------------------|
| [`plot`](@ref)            | Plot signals from a signal table in multiple diagrams/figures. |
| [`saveFigure`](@ref)      | Save figure in different formats on file.                      |
| [`closeFigure`](@ref)     | Close one figure                                               |
| [`closeAllFigures`](@ref) | Close all figures                                              |
| [`showFigure`](@ref)      | Show figure in window (only GLMakie, WGLMakie)                 |


```@docs
plot
saveFigure
closeFigure
closeAllFigures
showFigure
```
