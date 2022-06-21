# License for this file: MIT (expat)
# Copyright 2022, DLR Institute of System Dynamics and Control (DLR-SR)
# Developer: Martin Otter, DLR-SR
#
# This file is part of module SignalTables

"""
    independentSignalNames(signalTable)::Vector{String}

Returns the names of the independent signals (often: ["time"]) from signalTable.
"""
function independentSignalNames end


"""
    signalNames(signalTable)::Vector{String}

Returns a string vector of the signal names that are present in signalTable
(including independent signal names).
"""
function signalNames end


"""
    getSignal(signalTable, name::String)

Returns signal `name` from `signalTable` (that is a [`Var`](@ref) or a [`Par`](@ref)).
If `name` does not exist, an error is raised.
"""
function getSignal end


# ----------- Functions that have a default implementation ----------------------------------------

"""
    hasSignal(signalTable, name::String)

Returns `true` if signal `name` is present in `signalTable`.
"""
function hasSignal(signalTable, name::String)::Bool
    hasName = true
    try
        sig = getSignal(signalTable, name, with_values=false)
    catch
        hasName = false
    end
    return hasName
end


"""
    getSignalInfo(signalTable, name::String)

Returns signal with :_typeof, :_size keys instead of :values/:value keys
in form of a [`Var`](@ref) or a [`Par`](@ref)):
where keys :values/:value are replaced by:

|key        | value                                                                           |
|:----------|:--------------------------------------------------------------------------------|
|`:_typeof` | `= typeof( signal[:values] )` or `typeof( signal[:value] )` (if :value defined) |
|`:_size`   | `= size( signal[:values] )` or `size( signal[:value] )` (if :value defined).    |  

If `name` does not exist, an error is raised.

This function is useful if only the attributes of a signal are needed, but not their values
(returning the attributes might be a *cheap* operation, whereas returning the values in the form
required by the [Abstract Signal Table Interface](@ref) might be an *expensive* operation).
"""
function getSignalInfo(signalTable, name::String)::SymbolDictType
    signal = getSignal(signalTable,name)
    signal2 = copy(signal)
    delete!(signal2, :values)
    delete!(signal2, :value)
    _type = nothing
    _size = nothing
    _available =false    
    if isVar(signal)
        try
            sig   = signal[:values]
            _type = typeof(sig)
            _size = size(sig)
            available = true
        catch
            available = false
        end
    else
        try
            sig   = signal[:value]
            _type = typeof(sig)
            _size = size(sig)
            available = true
        catch
            available = false
        end    
    end
    if !isnothing(_type)
        signal2[:_typeof] = _type
    end
    if !isnothing(_size)
        signal2[:_size] = _size        
    end
    return signal2
end


"""
    getDefaultHeading(signalTable, name::String)::String

Returns the default heading for a plot.
"""
getDefaultHeading(signalTable)::String = ""
