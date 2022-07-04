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
export SignalType, Var, Par, isVar, isPar, isSignal, showSignal, eltypeOrType, quantity, unitAsParseableString

# Abstract Signal Table Interface
export isSignalTable, getIndependentSignalNames, getSignalNames, hasSignal, getSignal, getSignalInfo, getIndependentSignalsSize, getDefaultHeading

# Signal table functions
export new_signal_table, getValues, getValue, getValuesWithUnit, getValueWithUnit, getFlattenedSignal, showInfo, getHeading
export signalTableToJSON, writeSignalTable

# SignalTable
export SignalTable, toSignalTable, signalTableToDataFrame

# Plot Package
export @usingPlotPackage, usePlotPackage, usePreviousPlotPackage, currentPlotPackage

# Examples
export getSignalTableExample

include("Signals.jl")
include("AbstractSignalTableInterface.jl")
include("AbstractPlotInterface.jl")
include("SignalTable.jl")
include("SignalTableFunctions.jl")
include("PlotPackageDefinition.jl")
include("ExampleSignalTables.jl")
include("NoPlot.jl")
include("SilentNoPlot.jl")
include("SignalTableInterface_DataFrames.jl")

#include("SilentNoPlot.jl")
#include("UserFunctions.jl")
#include("OverloadedMethods.jl")

end
