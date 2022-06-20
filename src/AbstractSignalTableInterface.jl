# License for this file: MIT (expat)
# Copyright 2022, DLR Institute of System Dynamics and Control (DLR-SR)
# Developer: Martin Otter, DLR-SR
#
# This file is part of module SignalTables

"""
    independentSignalName(signalTable)

Returns the name of the independent signal (typically: "time") from signalTable
"""
function independentSignalName end


"""
    signalNames(signalTable)

Returns a string vector of the signal names that are present in signalTable
(including independent signal name).
"""
function signalNames end


"""
    getSignal(signalTable, name::String; require_values=true)

Returns signal `name` from `signalTable` (that is a [`Var`](@ref) or a [`Par`](@ref)).

- If `name` does not exist, an error is raised.
- If `require_values=false`, the signal need not return `:values` ([`Var`](@ref)) or `:value` ([`Par`](@ref)).\
  This option is useful, if only the attributes of a signal are needed, but not their values
  (returning the attributes might be a *cheap* operation, whereas returning the values in the form
  required by the [Abstract Signal Table Interface](@ref) might be an *expensive* operation).
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

defaultHeading(signalTable)::String = ""
