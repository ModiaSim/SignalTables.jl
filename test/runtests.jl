module Runtests

# Run all tests with SilentNoPlot (so not plots)

using SignalTables
using SignalTables.Test

@testset "Test SignalTables/test" begin
    usePlotPackage("SilentNoPlot")
    include("include_all.jl")
    usePreviousPlotPackage()
end

end
