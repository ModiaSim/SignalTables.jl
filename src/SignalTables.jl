module SignalTables

const path = dirname(dirname(@__FILE__)) 

using  OrderedCollections
using  Unitful
import DataFrames
#import Measurements
#import MonteCarloMeasurements
import Pkg

# Abstract Signal Table Interface
export Var, Par, isVar, isPar
export hasSignal, signalInfo, getValues, getValue, getValuesWithUnit, getValueWithUnit

# SignalTable
export SignalTable, independentSignalName, signalNames, getSignal

# Signal table functions
export showInfo


include("AbstractSignalTableInterface.jl")
include("SignalTable.jl")
include("SignalTableFunctions.jl")

#include("SilentNoPlot.jl")
#include("UserFunctions.jl")
#include("OverloadedMethods.jl")

end
