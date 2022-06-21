module test_20_SeveralSignalsInOneDiagram

using SignalTables
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)

sigTable = SignalTable(
    "time" => Var(values = t          , unit="s", independent=true),
    "phi"  => Var(values = sin.(t)    , unit="rad"),
    "phi2" => Var(values = 0.5*sin.(t), unit="rad"),
    "w"    => Var(values = cos.(t)    , unit="rad/s"),
    "w2"   => Var(values = 0.6*cos.(t), unit="rad/s"),
    "A"    => Par(value  = 0.6)
)

println("\n... test_20_SeveralSignalsInOneDiagram:")
showInfo(sigTable)

plot(sigTable, ("phi", "phi2", "w", "w2", "A"), heading="Several signals in one diagram")

end
