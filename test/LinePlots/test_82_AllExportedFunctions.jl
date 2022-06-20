module test_82_AllExportedFunctions

import @usingPlotPackage
SignalTables.@usingPlotPackage

# Test the Figure operations
println("\n... test test_82_AllExportedFunctions.jl:\n")

t = range(0.0, stop=10.0, length=100)
sigTable = Dict{String,Any}("time" => t, "phi" => sin.(t))
info   = SignalTables.sigTableInfo(sigTable)
showInfo(sigTable)

plot(sigTable, "phi", figure=2)

showFigure(2)
saveFigure(2, "test_saveFigure.png")
closeFigure(2)
closeAllFigures()

end