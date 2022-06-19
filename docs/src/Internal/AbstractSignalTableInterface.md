# Abstract Signal Table Interface

```@meta
CurrentModule = SignalTables
```

This chapter documents the *Abstract Signal Table Interface* for which an implementation has to be provided,
in order that the functions (see [Function Overview](@ref)) of the SignalTables package can be used.

Functions that are marked as *required*, need to be defined for a new signal table type.
Functions that are marked as *optional* have a default implementation, but can be defined for 
a new signal table type.

| Result functions                | Description                                                                           |
|:--------------------------------|:--------------------------------------------------------------------------------------|
| [`independentSignalName`](@ref) | Returns the name of the independent signal (*required*).                              |
| [`signalNames`](@ref)           | Returns a string vector of the signal names from a signal table (*required*).         |
| [`getSignal`](@ref)             | Returns signal from a signal table as [`Var`](@ref) or as [`Par`](@ref) (*required*). |
| [`hasSignal`](@ref)             | Returns `true` if a signal is present in a signal table (*optional*).                 |


*Concrete implementations* of theses functions are provided for:

- [`SignalTable`](@ref) (included in SignalTables.jl).
- [Modia.jl](https://github.com/ModiaSim/Modia.jl) (a modeling and simulation environment)
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl)
  (tabular data; first column is independent variable; *only scalar variables*))
- [Tables.jl](https://github.com/JuliaData/Tables.jl)
  (abstract tables, e.g. [CSV](https://github.com/JuliaData/CSV.jl) tables;
  first column is independent variable; *only scalar variables*).
