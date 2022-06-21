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
export independentSignalNames, signalNames, getSignal, hasSignal

# Signal table functions
export getValues, getValue, getValuesWithUnit, getValueWithUnit, getFlattenedSignal, showInfo, getHeading

# SignalTable
export SignalTable

# Plot Package
export @usingPlotPackage, usePlotPackage, usePreviousPlotPackage, currentPlotPackage

include("Signals.jl")
include("AbstractSignalTableInterface.jl")
include("AbstractPlotInterface.jl")
include("SignalTable.jl")
include("SignalTableFunctions.jl")
include("PlotPackageDefinition.jl")
include("SignalTableJSON.jl")

#include("SilentNoPlot.jl")
#include("UserFunctions.jl")
#include("OverloadedMethods.jl")

end
