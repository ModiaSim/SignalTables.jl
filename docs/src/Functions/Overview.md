# Function Overview

```@meta
CurrentModule = SignalTables
```

This chapter documents functions that operate on signals and on signal tables
(= *multi-dimensional* arrays with identical first dimensions that are collected in *tabular* format
and support the [Abstract Signal Table Interface](@ref)).

A *signal* is identified by its String *name* and is a representation of the values of a 
variable ``v`` as a (partial) function ``v(t)`` of the independent variable ``t = v_{independent}``. 

The values of ``v(t)`` are stored with key `:values` in dictionary [`Var`](@ref) (= abbreviation for *Variable*) 
and are represented by an array where `v.values[i,j,k,...]` is element `v[j,k,...]` of 
variable ``v`` at ``t_i``. If an element of ``v`` is *not defined* at 
``t_ì``, it has a value of *missing*.

If ``v(t) = v_{const}`` is constant, it is stored in element `:value` in dictionary [`Par`](@ref) 
(= abbreviation for *Parameter*) and is represented by any Julia type, that is
`v.value` is the value of variable ``v_{const}`` at all elements ``t_i``.

| Signal functions                | Description                                                                                |
|:--------------------------------|:-------------------------------------------------------------------------------------------|
| [`Var`](@ref)                   | Returns a variable signal definition in form of a dictionary.                              |
| [`Par`](@ref)                   | Returns a parameter signal definition in form of a dictionary.                             |
| [`isVar`](@ref)                 | Returns true, if signal is a [`Var`](@ref).                                                |
| [`isPar`](@ref)                 | Returns true, if signal is a [`Par`](@ref).                                                |
| [`isSignal`](@ref)              | Returns true, if signal is a [`Var`](@ref) or a [`Par`](@ref).                             |
| [`showSignal`](@ref)            | Prints a [`Var`](@ref)(...) or [`Par`](@ref)(...) signal to io.                            |
| [`basetype`](@ref)              | Returns eltype of an array (but without Missing) and otherwise returns typeof.             |                                 |
| [`quantity`](@ref)              | Returns `Unitful.Quantity` from numberType and numberUnit, e.g. `quantity(Float64,u"m/s")` | 
| [`unitAsParseableString`](@ref) | Returns the unit as a String that can be parsed with `Unitful.uparse`, e.g. "m*s^-1"       | 


| Signal table functions          | Description                                                                                    |
|:--------------------------------|:-----------------------------------------------------------------------------------------------|
| [`SignalTable`](@ref)           | Returns a new SignalTable dictionary.                                                          |
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
CurrentModule = SignalTablesInterface_PyPlot
```

| Line plot functions       | Description                                                    |
|:--------------------------|:---------------------------------------------------------------|
| [`plot`](@ref)            | Plot signals from a signal table in multiple diagrams/figures. |
| [`saveFigure`](@ref)      | Save figure in different formats on file.                      |
| [`closeFigure`](@ref)     | Close one figure                                               |
| [`closeAllFigures`](@ref) | Close all figures                                              |
| [`showFigure`](@ref)      | Show figure in window (only GLMakie, WGLMakie)                 |