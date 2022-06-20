module test_24_Reuse

using SignalTables
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)

sigTable1 = SignalTable(
    "time" => Var(values=t, unit="s"),
    "phi"  => Var(values=sin.(t), unit="rad"),
    "w"    => Var(values=cos.(t), unit="rad/s")
)

sigTable2 = SignalTable(
    "time" => Var(values=t, unit="s"),
    "phi"  => Var(values=1.2*sin.(t), unit="rad"),
    "w"    => Var(values=0.8*cos.(t), unit="rad/s")
)

println("\n... test_24_Reuse:")
showInfo(sigTable1)
println()
showInfo(sigTable2)

plot(sigTable1, ("phi", "w"), prefix="Sim 1:", heading="Test reuse")
plot(sigTable2, ("phi", "w"), prefix="Sim 2:", reuse=true)

end