# Signals

```@meta
CurrentModule = SignalTables
```

The functions below operate on *signals*.

!!! note
    [SignalTables.jl](https://github.com/ModiaSim/SignalTables.jl) exports all symbols of this table.\
    [Modia.jl](https://github.com/ModiaSim/Modia.jl) reexports all symbols.

| Signal functions                | Description                                                                                |
|:--------------------------------|:-------------------------------------------------------------------------------------------|
| [`Var`](@ref)                   | Returns a variable signal definition in form of a dictionary.                              |
| [`Par`](@ref)                   | Returns a parameter signal definition in form of a dictionary.                             |
| [`Map`](@ref)                   | Returns an attribute signal definition in form of a dictionary.                            |
| [`isVar`](@ref)                 | Returns true, if signal is a [`Var`](@ref).                                                |
| [`isPar`](@ref)                 | Returns true, if signal is a [`Par`](@ref).                                                |
| [`isMap`](@ref)                 | Returns true, if signal is a [`Map`](@ref).                                                |
| [`isSignal`](@ref)              | Returns true, if signal is a [`Var`](@ref), [`Par`](@ref) or [`Map`](@ref).                |
| [`showSignal`](@ref)            | Prints a [`Var`](@ref), [`Par`](@ref) or [`Map`](@ref) signal to io.                       |
| [`eltypeOrType`](@ref)          | Returns eltype of an array (but without Missing) and otherwise returns typeof.             |
| [`quantity`](@ref)              | Returns `Unitful.Quantity` from numberType and numberUnit, e.g. `quantity(Float64,u"m/s")` |
| [`unitAsParseableString`](@ref) | Returns the unit as a String that can be parsed with `Unitful.uparse`, e.g. "m*s^-1"       |

```@docs
Var
Par
Map
isVar
isPar
isMap
isSignal
showSignal
eltypeOrType
quantity
unitAsParseableString
```
