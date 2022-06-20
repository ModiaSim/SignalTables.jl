module test_81_SaveFigure

import @usingPlotPackage
SignalTables.@usingPlotPackage

println("\n... test test_81_SaveFigure.jl:\n")

t = range(0.0, stop=10.0, length=100)
sigTable = Dict{String,Any}("time" => t, "phi" => sin.(t))
info   = SignalTables.sigTableInfo(sigTable)
showInfo(sigTable)

plot(sigTable, "phi", figure=2)
saveFigure(2, "test_saveFigure2.png")


end