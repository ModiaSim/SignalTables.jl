
include("SignalTableFunctions/test_SignalTypes.jl")
include("SignalTableFunctions/test_SignalTable.jl")
include("SignalTableFunctions/test_DataFrames.jl")
include("SignalTableFunctions/test_json.jl")

include("../examples/plots/_include_all.jl")

#=
include("LinePlots/test_06_OneScalarMeasurementSignal.jl")
include("LinePlots/test_07_OneScalarMeasurementSignalWithUnit.jl") 
=#

include("LinePlots/test_20_SeveralSignalsInOneDiagram.jl")
include("LinePlots/test_21_VectorOfPlots.jl")
include("LinePlots/test_22_MatrixOfPlots.jl")
include("LinePlots/test_23_MatrixOfPlotsWithTimeLabelsInLastRow.jl")
include("LinePlots/test_24_Reuse.jl")
include("LinePlots/test_25_SeveralFigures.jl")
include("LinePlots/test_26_TooManyLegends.jl") 

#=
include("LinePlots/test_51_OneScalarMonteCarloMeasurementsSignal.jl")
include("LinePlots/test_52_MonteCarloMeasurementsWithDistributions.jl")    

# include("test_71_Tables_Rotational_First.jl")    # deactivated, because "using CSV"
include("test_72_ResultDictWithMatrixOfPlots.jl")

include("test_80_Warnings.jl")
include("test_81_SaveFigure.jl")
include("test_82_AllExportedFunctions.jl")
=#


# include("test_90_CompareOneScalarSignal.jl")
# include("test_91_CompareOneScalarSignalWithUnit.jl")