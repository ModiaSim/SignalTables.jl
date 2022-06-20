module test_02_OneScalarSignalWithUnit

using SignalTables
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)

sigTable = SignalTable(
    "time" => Var(values = t, unit="s", variability="independent"),
    "phi"  => Var(values = sin.(t), unit="rad")
)

println("\n... test_02_OneScalarSignalWithUnit.jl:\n")
showInfo(sigTable)

plot(sigTable, "phi", heading="Sine(time)")

end