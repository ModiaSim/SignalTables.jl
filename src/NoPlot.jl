# License for this file: MIT (expat)
# Copyright 2021, DLR Institute of System Dynamics and Control

module NoPlot

include("AbstractLinePlotInterface.jl")

plot(signalTable, names::AbstractMatrix; heading::AbstractString="", grid::Bool=true, xAxis="time",
     figure::Int=1, prefix::AbstractString="", reuse::Bool=false, maxLegend::Integer=10,
     minXaxisTickLabels::Bool=false, MonteCarloAsArea=false) =
        println("... plot(..): Call is ignored, because of usePlotPackage(\"NoPlot\").")

showFigure(figure::Int)  = println("... showFigure($figure): Call is ignored, because of usePlotPackage(\"NoPlot\").")
closeFigure(figure::Int) = println("... closeFigure($figure): Call is ignored, because of usePlotPackage(\"NoPlot\").")
saveFigure(figure::Int, fileName::AbstractString) = println("... saveFigure($figure,\"$fileName\"): Call is ignored, because of usePlotPackage(\"NoPlot\").")
closeAllFigures() = println("... closeAllFigures(): Call is ignored, because of usePlotPackage(\"NoPlot\").")

end