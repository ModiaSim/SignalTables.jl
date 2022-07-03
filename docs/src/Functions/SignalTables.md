# Signal Tables

```@meta
CurrentModule = SignalTables
```

The functions below operate on a *signal table* that implements the [Abstract Signal Table Interface](@ref).

!!! note
    [SignalTables.jl](https://github.com/ModiaSim/SignalTables.jl) exports all symbols of this table.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) reexports all symbols and uses `instantiatedModel` as *signalTable* argument.

| Signal table functions             | Description                                                                                    |
|:-----------------------------------|:-----------------------------------------------------------------------------------------------|
| [`new_signal_table`](@ref)         | Returns a new signal table dictionary (= OrderedDict{String,Any}("_class" => :SignalTable)).   |
| [`SignalTable`](@ref)              | Returns a new instance of type SignalTable.                                                    |
| [`showInfo`](@ref)                 | Writes info about a signal table to the output stream.                                         |
| [`independentSignalNames`](@ref)   | Returns the names of the independent signals.                                                  |
| [`signalNames`](@ref)              | Returns a string vector of the signal names that are present in a signal table.                |
| [`hasSignal`](@ref)                | Returns `true` if a signal is present in a signal table.                                       |
| [`getSignal`](@ref)                | Returns signal from a signal table as [`Var`](@ref) or as [`Par`](@ref).                       |
| [`getSignalInfo`](@ref)            | Returns signal with :\_typeof, :\_size keys instead of :values/:value keys.                    |
| [`getIndependentSignalsSize`](@ref)| Returns the lengths of the independent signals as Dims.                                        |
| [`getValues`](@ref)                | Returns the *values* of a [`Var`](@ref) signal from a signal table.                            |
| [`getValuesWithUnit`](@ref)        | Returns the *values* of a [`Var`](@ref) signal from a signal table including its unit.         |
| [`getValue`](@ref)                 | Returns the *value* of a [`Par`](@ref) signal  from a signal table.                            |
| [`getValueWithUnit`](@ref)         | Returns the *value* of a [`Par`](@ref) signal from a signal table including its unit.          |
| [`getFlattenedSignal`](@ref)       | Returns a copy of a signal where the values or the value are *flattened* and converted for use in plots or traditional tables. |
| [`getDefaultHeading`](@ref)        | Returns the default heading for a plot.                                                        |


```@docs
new_signal_table
SignalTable
showInfo
independentSignalNames
signalNames
hasSignal
getSignal
getSignalInfo
getIndependentSignalsSize
getValues
getValuesWithUnit
getValue
getValueWithUnit
getFlattenedSignal
getDefaultHeading
```
