module SignalTables

const path = dirname(dirname(@__FILE__)) 

using  OrderedCollections
using  Unitful
using  Test
import DataFrames
#import Measurements
#import MonteCarloMeasurements
import Pkg

# Signals
export Var, Par, isVar, isPar, isSignal, showSignal, basetype, quantity, unitAsParseableString

# Abstract Signal Table Interface
export independentSignalName, signalNames, getSignal, hasSignal

# Signal table functions
export getValues, getValue, getValuesWithUnit, getValueWithUnit, showInfo

# SignalTable
export SignalTable


include("Signals.jl")
include("AbstractSignalTableInterface.jl")
include("AbstractLinePlotInterface.jl")
include("SignalTable.jl")
include("SignalTableFunctions.jl")
include("PlotPackageDefinition.jl")
 
#include("SilentNoPlot.jl")
#include("UserFunctions.jl")
#include("OverloadedMethods.jl")

end
