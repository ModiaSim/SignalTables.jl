# Abstract Plot Interface

```@meta
CurrentModule = SignalTablesInterface_PyPlot
```

This chapter documents the *abstract plot interface* for which an implementation has to be provided,
in order that the corresponding plot package can be used from the functions of SignalTables to
provide plots in a convenient way.

For every plot package `XXX.jl` an interface package `SignalTablesInterface_XXX.jl` has to be provided
that implements the following functions (with exception of `plot`, all other functions
can be just dummy functions; the docu below was generated with [SignalTablesInterface_PyPlot](https://github.com/ModiaSim/SignalTablesInterface_PyPlot.jl)).

| Functions                  | Description                                               |
|:---------------------------|:----------------------------------------------------------|
| [`plot`](@ref)             | Plot signals of a signalTable in multiple diagrams within multiple windows/figures (*required*). |
| [`saveFigure`](@ref)       | Save figure in different formats on file (*required*).    |
| [`closeFigure`](@ref)      | Close one figure (*required*)                             |
| [`closeAllFigures`](@ref)  | Close all figures (*required*)                            |
| [`showFigure`](@ref)       | Show figure in window (*required*)                        |
