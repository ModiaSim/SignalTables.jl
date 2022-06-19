# Function Overview

```@meta
CurrentModule = SignalTables
```

This chapter documents functions that operate on signals and on signal tables.

A *signal table* is a (dictionary-like) type that supports the [Abstract Signal Table Interface](@ref) 
for example [`SignalTable`](@ref). It defines a set of *signals* in tabular format. A *signal* is identified 
by its String *name* and is a representation of the values of a variable ``v`` as a (partial) function ``v(t)``
of the independent variable ``t = v_{independent}``. 

The values of ``v(t)`` are stored with key `:values` in dictionary [`Var`](@ref) (= abbreviation for *Variable*) 
and are represented by an array where `v.values[i,j,k,...]` is element `v[j,k,...]` of 
variable ``v`` at ``t_i``. If an element of ``v`` is *not defined* at 
``t_ì``, it has a value of *missing*.

If ``v(t) = v_{const}`` is constant, it is stored in element `:value` in dictionary [`Par`](@ref) 
(= abbreviation for *Parameter*) and is represented by any Julia type, that is
`v.value` is the value of variable ``v_{const}`` at all elements ``t_i``.


| Signal table functions          | Description                                                                                    |
|:--------------------------------|:-----------------------------------------------------------------------------------------------|
| [`SignalTable`](@ref)           | Returns a new SignalTable dictionary.                                                          |
| [`Var`](@ref)                   | Returns a variable signal definition in form of a dictionary.                                  |
| [`Par`](@ref)                   | Returns a parameter signal definition in form of a dictionary.                                 |
| [`showInfo`](@ref)              | Writes info about a signal table to the output stream.                                         |
| [`independentSignalName`](@ref) | Returns the name of the independent signal.                                                    |
| [`signalNames`](@ref)           | Returns a string vector of the signal names that are present in a signal table.                |
| [`hasSignal`](@ref)             | Returns `true` if a signal is present in a signal table.                                       |
| [`getSignal`](@ref)             | Returns signal from a signal table as [`Var`](@ref) or as [`Par`](@ref).                       |
| [`getValues`](@ref)             | Returns the *values* of a [`Var`](@ref) signal from a signal table.                            |
| [`getValuesWithUnit`](@ref)     | Returns the *values* of a [`Var`](@ref) signal from a signal table including its unit.         |
| [`getValue`](@ref)              | Returns the *value* of a [`Par`](@ref) signal  from a signal table.                            |
| [`getValueWithUnit`](@ref)      | Returns the *value* of a [`Par`](@ref) signal from a signal table including its unit.          | 
| [`getSignalForLinePlots`](@ref) | Transforms signal data and returns it for use in line plots (e.g. Matrix with NaN).            |


| Plot package functions           | Description                                               |
|:---------------------------------|:----------------------------------------------------------|
| [`@usingPlotPackage`](@ref)      | Expands into `using PlotPackage_<PlotPackageName>`        |
| [`usePlotPackage`](@ref)         | Define the plot package to be used.                       |
| [`usePreviousPlotPackage`](@ref) | Define the previously defined plot package to be used.    |
| [`currentPlotPackage`](@ref)     | Return name defined with [`usePlotPackage`](@ref)         |


```@meta
CurrentModule = ModiaPlot_PyPlot
```

| Line plot functions       | Description                                                    |
|:--------------------------|:---------------------------------------------------------------|
| [`plot`](@ref)            | Plot signals from a signal table in multiple diagrams/figures. |
| [`saveFigure`](@ref)      | Save figure in different formats on file.                      |
| [`closeFigure`](@ref)     | Close one figure                                               |
| [`closeAllFigures`](@ref) | Close all figures                                              |
| [`showFigure`](@ref)      | Show figure in window (only GLMakie, WGLMakie)                 |