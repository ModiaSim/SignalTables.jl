# Signal Tables

```@meta
CurrentModule = SignalTables
```

The functions below operate on a *signal table* that implements the [Abstract Signal Table Interface](@ref).

!!! note
    [SignalTables.jl](https://github.com/ModiaSim/SignalTables.jl) exports all symbols of this table.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) reexports all symbols and uses `instantiatedModel` as *signalTable* argument.

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


```@docs
SignalTable
showInfo
independentSignalName
signalNames
hasSignal
getSignal
getValues
getValuesWithUnit
getValue
getValueWithUnit
getSignalForLinePlots
```
