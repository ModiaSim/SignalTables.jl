module test_01_OneScalarSignal

using SignalTables
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)

sigTable = SignalTable(
    "time" => Var(values = t, independent=true),
    "phi"  => Var(values = sin.(t))
)

println("\n... test_01_OneScalarSignal.jl:\n")

showInfo(sigTable)

plot(sigTable, "phi", heading="sine(time)")

end