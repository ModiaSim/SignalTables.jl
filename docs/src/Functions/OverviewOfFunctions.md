# Overview of Functions

```@meta
CurrentModule = SignalTables
```

This chapter documents functions that operate on signals and on signal tables

A *signal table* is an *ordered dictionary* of *signals* with string keys that supports the
[Abstract Signal Table Interface](@ref). The first k entries
represent the k independent signals. A *signal* is either a

- [`Var`](@ref) dictionary that has a required *:values* key representing a *signal array* of any element type 
  as function of the independent signal(s) (or is the k-th independent variable), or a
- [`Par`](@ref) dictionary that has an optional *:value* key representing a constant of any type.

A *signal array* has indices `[i1,i2,...,j1,j2,...]` to hold variable elements `[j1,j2,...]` 
at the `[i1,i2,...]` independent signal(s). If an element of a signal array is *not defined* 
it has a value of *missing*. In both dictionaries, additional attributes can be stored, 
for example units, into texts, variability (continuous, clocked, ...), alias. 



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


| Signal table functions           | Description                                                                                    |
|:---------------------------------|:-----------------------------------------------------------------------------------------------|
| [`SignalTable`](@ref)            | Returns a new SignalTable dictionary.                                                          |
| [`showInfo`](@ref)               | Writes info about a signal table to the output stream.                                         |
| [`independentSignalNames`](@ref) | Returns the names of the independent signals.                                                  |
| [`signalNames`](@ref)            | Returns a string vector of the signal names that are present in a signal table.                |
| [`hasSignal`](@ref)              | Returns `true` if a signal is present in a signal table.                                       |
| [`getSignal`](@ref)              | Returns signal from a signal table as [`Var`](@ref) or as [`Par`](@ref).                       |
| [`getSignalInfo`](@ref)          | Returns signal with :\_typeof, :\_size keys instead of :values/:value keys.                    |
| [`getValues`](@ref)              | Returns the *values* of a [`Var`](@ref) signal from a signal table.                            |
| [`getValuesWithUnit`](@ref)      | Returns the *values* of a [`Var`](@ref) signal from a signal table including its unit.         |
| [`getValue`](@ref)               | Returns the *value* of a [`Par`](@ref) signal  from a signal table.                            |
| [`getValueWithUnit`](@ref)       | Returns the *value* of a [`Par`](@ref) signal from a signal table including its unit.          |
| [`getFlattenedSignal`](@ref)     | Returns a copy of a signal where the values or the value are *flattened* and converted for use in plots or traditional tables. |
| [`getDefaultHeading`](@ref)      | Returns the default heading for a plot.                                                        |
| [`signalTableToJSON`](@ref)     | Returns a signal table as JSON string.                                                         |
| [`writeSignalTable`](@ref)      | Writes a signal Table in JSON format on file.                                                  |


| Plot package functions           | Description                                               |
|:---------------------------------|:----------------------------------------------------------|
| [`@usingPlotPackage`](@ref)      | Expands into `using PlotPackage_<PlotPackageName>`        |
| [`usePlotPackage`](@ref)         | Define the plot package to be used.                       |
| [`usePreviousPlotPackage`](@ref) | Define the previously defined plot package to be used.    |
| [`currentPlotPackage`](@ref)     | Return name defined with [`usePlotPackage`](@ref)         |


```@meta
CurrentModule = SignalTablesInterface_PyPlot
```

| Plot functions       | Description                                                    |
|:--------------------------|:---------------------------------------------------------------|
| [`plot`](@ref)            | Plot signals from a signal table in multiple diagrams/figures. |
| [`saveFigure`](@ref)      | Save figure in different formats on file.                      |
| [`closeFigure`](@ref)     | Close one figure                                               |
| [`closeAllFigures`](@ref) | Close all figures                                              |
| [`showFigure`](@ref)      | Show figure in window (only GLMakie, WGLMakie)                 |