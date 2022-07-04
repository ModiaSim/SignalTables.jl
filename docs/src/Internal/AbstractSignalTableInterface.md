# Abstract Signal Table Interface

```@meta
CurrentModule = SignalTables
```

This chapter documents the *Abstract Signal Table Interface* for which an implementation has to be provided,
in order that the functions (see [Overview of Functions](@ref)) of the SignalTables package can be used.

A *signal table* is an *ordered dictionary* of *signals* with string keys. The first k entries
represent the k independent signals. A *signal* is either a

- [`Var`](@ref) dictionary that has a required *:values* key representing a *signal array* of any element type 
  as function of the independent signal(s) (or is the k-th independent variable), or a
- [`Par`](@ref) dictionary that has an optional *:value* key representing a constant of any type.

A *signal array* has indices `[i1,i2,...,j1,j2,...]` to hold variable elements `[j1,j2,...]` 
at the `[i1,i2,...]` independent signal(s). If an element of a signal array is *not defined* 
it has a value of *missing*. In both dictionaries, additional attributes can be stored, 
for example units, into texts, variability (continuous, clocked, ...), alias. 

Functions that are marked as *required*, need to be defined for a new signal table type.
Functions that are marked as *optional* have a default implementation.

| Abstract functions                 | Description                                                                             |
|:-----------------------------------|:----------------------------------------------------------------------------------------|
| [`getIndependentSignalNames`](@ref)   | Returns a string vector of the names of the independent signals (*required*).           |
| [`getSignalNames`](@ref)              | Returns a string vector of the signal names from a signal table (*required*).           |
| [`getSignal`](@ref)                | Returns signal from a signal table as [`Var`](@ref) or as [`Par`](@ref) (*required*).   |
| [`getSignalInfo`](@ref)            | Returns signal with :\_typeof, :\_size keys instead of :values/:value key (*optional*). |
| [`getIndependentSignalsSize`](@ref)| Returns the lengths of the independent signals as Dims. (*optional*).                   |
| [`getDefaultHeading`](@ref)        | Returns the default heading for a plot. (*optional*).                                   |
| [`hasSignal`](@ref)                | Returns true if signal name is present in signal table. (*optional*).                   |



