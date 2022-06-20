# Abstract Line Plot Interface

```@meta
CurrentModule = SignalTablesInterface_PyPlot
```

This chapter documents the *abstract line plot interface* for which an implementation has to be provided,
in order that the corresponding plot package can be used from the functions of SignalTables to
provide line plots in a convenient way.

For every plot package `XXX.jl` an interface package `SignalTablesInterface_XXX.jl` has to be provided
that implements the following functions (with exception of `plot`, all other functions
can be just dummy functions; the docu below was generated with [SignalTablesInterface_PyPlot](https://github.com/ModiaSim/SignalTablesInterface_PyPlot.jl)).

| Functions                  | Description                                               |
|:---------------------------|:----------------------------------------------------------|
| [`plot`](@ref)             | Plot simulation signalTables in multiple diagrams within multiple windows/figures (*required*). |
| [`saveFigure`](@ref)       | Save figure in different formats on file (*required*).    |
| [`closeFigure`](@ref)      | Close one figure (*required*)                             |
| [`closeAllFigures`](@ref)  | Close all figures (*required*)                            |
| [`showFigure`](@ref)       | Show figure in window (*required*)                        |

*Concrete implementations* of these functions are provided for:

- [PyPlot](https://github.com/JuliaPy/PyPlot.jl) (plots with [Matplotlib](https://matplotlib.org/stable/) from Python), 
- [GLMakie](https://github.com/JuliaPlots/GLMakie.jl) (interactive plots in an OpenGL window),
- [WGLMakie](https://github.com/JuliaPlots/WGLMakie.jl) (interactive plots in a browser window),
- [CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl) (static plots on file with publication quality).

Furthermore, there are two dummy modules included in SignalTables, that are useful when performing tests with runtests.jl, 
in order that no plot package needs to be loaded during the tests:

- NoPlot (= all plot calls are ignored and info messages are instead printed), or
- SilentNoPlot (= NoPlot without messages).
