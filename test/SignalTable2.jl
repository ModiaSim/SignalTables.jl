using SignalTables

println("\n... Constructing signalTable2")

t = range(0.0, stop=10.0, length=100)

signalTable2 = SignalTable(
    "time" => Var(values = t, unit="s", independent=true),
    "phi"  => Var(values = sin.(t), unit="rad"),
    "phi2" => Var(values = 0.5 * sin.(t), unit="rad"),
    "w"    => Var(values = cos.(t), unit="rad/s"),
    "w2"   => Var(values = 0.6 * cos.(t), unit="rad/s"),
    "r"    => Var(values = [0.4 * cos.(t) 0.5 * sin.(t) 0.3 * cos.(t)], unit="m")
)

#showInfo(signalTable2)