module test_21_VectorOfPlots

using SignalTables
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)

sigTable = SignalTable(
    "time" => Var(values=t, unit="s", independent=true),
    "phi"  => Var(values=sin.(t), unit="rad"),
    "phi2" => Var(values=0.5 * sin.(t), unit="rad"),
    "w"    => Var(values=cos.(t), unit="rad/s"),
    "w2"   => Var(values=0.6 * cos.(t), unit="rad/s")
)

println("\n... test_21_VectorOfPlots:")
showInfo(sigTable)

plot(sigTable, ["phi2", ("w",), ("phi", "phi2", "w", "w2")], heading="Vector of plots")

end