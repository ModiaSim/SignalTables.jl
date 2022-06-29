# License for this file: MIT (expat)
# Copyright 2022, DLR Institute of System Dynamics and Control (DLR-SR)
# Developer: Martin Otter, DLR-SR
#
# This file is part of module SignalTables

"""
    isSignalTable(obj)::Bool

Returns true, if `obj` is a signal table and supports the functions of the [Abstract Signal Table Interface](@ref).
"""
isSignalTable(obj) = false


"""
    independentSignalNames(signalTable)::Vector{String}

Returns the names of the independent signals (often: ["time"]) from signalTable.
"""
function independentSignalNames end


"""
    signalNames(signalTable)::Vector{String}

Returns a string vector of the signal names that are present in signalTable
(including independent signal names, but without "_class" => :SignalTable).
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

Returns signal in form of a [`Var`](@ref) or a [`Par`](@ref)) where
 
- :values in Var() is replaced by :_basetype = basetype(signal[:values]), :_size = size( signal[:values] )  or
- :value in Par() is replaced by :_basetype = basetype(signal[:value]), :_size = size( signal[:value] )  

provided size(..) on the value is defined (otherwise :_size is not included)

If `name` does not exist, an error is raised.

This function is useful if only the attributes of a signal are needed, but not their values
(returning the attributes might be a *cheap* operation, whereas returning the values in the form
required by the [Abstract Signal Table Interface](@ref) might be an *expensive* operation).
"""
function getSignalInfo(signalTable, name::String)::SymbolDictType
    signal  = getSignal(signalTable,name)
    signal2 = copy(signal)
    delete!(signal2, :values)
    delete!(signal2, :value)
    _basetype = nothing    
    _size     = nothing
    type_available = false
    size_available = false    
    if isVar(signal)
        if haskey(signal, :values)
            type_available = true
            try
                sig       = signal[:values]
                _basetype = basetype(sig)
                _size     = size(sig)
                size_available = true                
            catch
                size_available = false
            end
        end
    else
        if haskey(signal, :value)
            type_available = true        
            try
                sig       = signal[:value]
                _basetype = basetype(sig)            
                _size     = size(sig)
                size_available = true                  
            catch
                size_available = false
            end
        end
    end
    if type_available
        signal2[:_basetype] = _basetype
    end        
    if size_available
        signal2[:_size] = _size
    end
    return signal2
end


"""
    getIndependentSignalSizes(signalTable)::Vector{Dims}

Returns the sizes of the independent signals.
"""
getIndependentSignalSizes(signalTable)::Vector{Dims} = Dims[getSignalInfo(signalTable,name)[:_size] for name in independentSignalNames(signalTable)]


"""
    getDefaultHeading(signalTable, name::String)::String

Returns the default heading for a plot.
"""
getDefaultHeading(signalTable)::String = ""
