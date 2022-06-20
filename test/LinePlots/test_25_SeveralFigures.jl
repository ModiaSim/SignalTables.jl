module test_25_SeveralFigures

using SignalTables
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)

sigTable = SignalTable(
    "time" => Var(values = t, unit="s"),
    "phi"  => Var(values = sin.(t), unit="rad"),
    "phi2" => Var(values = 0.5 * sin.(t), unit="rad"),
    "w"    => Var(values = cos.(t), unit="rad/s"),
    "w2"   => Var(values = 0.6 * cos.(t), unit="rad/s"),
    "r"    => Var(values = [0.4 * cos.(t) 0.5 * sin.(t) 0.3 * cos.(t)], unit="m")
)

println("\n... test_25_SeveralFigures:")
showInfo(sigTable)

plot(sigTable, ("phi", "r")       , heading="First figure" , figure=1)
plot(sigTable, ["w", "w2", "r[2]"], heading="Second figure", figure=2)
plot(sigTable, "r"                , heading="Third figure" , figure=3)

end
