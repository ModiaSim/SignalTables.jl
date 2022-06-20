module test_03_OneVectorSignalWithUnit

using SignalTables
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)

sigTable = SignalTable(
    "time" => Var(values = t, unit="s", variability="independent"),
    "r"    => Var(values = [0.4*cos.(t)  0.5*sin.(t)  0.3*cos.(t)], unit="m"),
)

println("\n... test_03_OneVectorSignalWithUnit.jl:")
showInfo(sigTable)

plot(sigTable, ["r", "r[2]", "r[2:3]"], heading="Plot vector signals")

end