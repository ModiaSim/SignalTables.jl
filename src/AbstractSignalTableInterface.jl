# License for this file: MIT (expat)
# Copyright 2022, DLR Institute of System Dynamics and Control (DLR-SR)
# Developer: Martin Otter, DLR-SR
#
# This file is part of module SignalTables

import Tables

"""
    isSignalTable(obj)::Bool

Returns true, if `obj` is a signal table and supports the functions of the [Abstract Signal Table Interface](@ref).
"""
isSignalTable(obj) = Tables.istable(obj) && Tables.columnaccess(obj)


"""
    getIndependentSignalNames(signalTable)::Vector{String}

Returns the names of the independent signals (often: ["time"]) from signalTable.
"""
function getIndependentSignalNames(obj)
    if Tables.istable(obj) && Tables.columnaccess(obj)
        return [string(Tables.columnnames(obj)[1])]
    else
        @error "getIndependentSignalNames(obj) is not supported for typeof(obj) = " * string(typeof(obj))
    end
end


"""
    getSignalNames(signalTable)::Vector{String}

Returns a string vector of the signal names that are present in signalTable
(including independent signal names).
"""
function getSignalNames(obj)
    if Tables.istable(obj) && Tables.columnaccess(obj)
        return string.(Tables.columnnames(obj))
    else
        @error "getSignalNames(obj) is not supported for typeof(obj) = " * string(typeof(obj))
    end
end


"""
    getSignal(signalTable, name::String)

Returns signal `name` from `signalTable` (that is a [`Var`](@ref) or a [`Par`](@ref)).
If `name` does not exist, an error is raised.
"""
function getSignal(obj, name::String)
    if Tables.istable(obj) && Tables.columnaccess(obj)
        return Var(values= Tables.getcolumn(obj, Symbol(name)))
    else
        @error "getSignal(obj, \"$name\") is not supported for typeof(obj) = " * string(typeof(obj))
    end
end


# ----------- Functions that have a default implementation ----------------------------------------

"""
    hasSignal(signalTable, name::String)

Returns `true` if signal `name` is present in `signalTable`.
"""
function hasSignal(signalTable, name::String)::Bool
    hasName = true
    try
        sig = getSignal(signalTable, name)
    catch
        hasName = false
    end
    return hasName
end


"""
    getSignalInfo(signalTable, name::String)

Returns signal in form of a [`Var`](@ref) or a [`Par`](@ref)) without :values or :value
but instead with :_eltypeOrType (eltype of the values if AbstractArray, otherwise typeof the values) 
and :_size (if defined on the values)
 
If `name` does not exist, an error is raised.

This function is useful if only the attributes of a signal are needed, but not their values
(returning the attributes might be a *cheap* operation, whereas returning the values 
might be an *expensive* operation).
"""
function getSignalInfo(signalTable, name::String)::SymbolDictType
    signal  = getSignal(signalTable,name)
    signal2 = copy(signal)
    delete!(signal2, :values)
    delete!(signal2, :value)
    _eltypeOrType = nothing    
    _size         = nothing
    type_available = false
    size_available = false    
    if isVar(signal)
        if haskey(signal, :values)
            type_available = true
            try
                sig           = signal[:values]
                _eltypeOrType = eltypeOrType(sig)
                _size          = size(sig)
                size_available = true                
            catch
                size_available = false
            end
        end
    else
        if haskey(signal, :value)
            type_available = true        
            try
                sig           = signal[:value]
                _eltypeOrType = eltypeOrType(sig)            
                _size         = size(sig)
                size_available = true                  
            catch
                size_available = false
            end
        end
    end
    if type_available
        signal2[:_eltypeOrType] = _eltypeOrType
    end        
    if size_available
        signal2[:_size] = _size
    end
    return signal2
end


"""
    getIndependentSignalsSize(signalTable)::Dims

Returns the lengths of the independent signals as Dims. 
E.g. for one independent signal of length 5 return (5,),
or for two independent signals of length 5 and 7 return (5,7).
"""
function getIndependentSignalsSize(signalTable)::Dims
    sigLength = Int[]
    for name in getIndependentSignalNames(signalTable)
        sigSize = getSignalInfo(signalTable,name)[:_size]
        if length(sigSize) != 1
            error("Independent signal $name has not one dimension but has size = $sigSize")
        end
        push!(sigLength, sigSize[1])
    end
    return ntuple(i -> sigLength[i], length(sigLength))
end


"""
    getDefaultHeading(signalTable, name::String)::String

Returns the default heading for a plot.
"""
getDefaultHeading(signalTable)::String = ""
