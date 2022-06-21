module test_04_ConstantSignalsWithUnit

using SignalTables
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)

inertia = [1.1  1.2  1.3;
           2.1  2.2  2.3;
           3.1  3.2  3.3] 
                              
sigTable = SignalTable(
    "time"    => Var(values = t, unit="s", independent=true),
    "phi_max" => Par(value = 1.1f0, unit="rad"),
    "i_max"   => Par(value = 2),
    "open"    => Par(value = true),
    "Inertia" => Par(value = inertia, unit="kg*m^2")
)

println("\n... test_04_ConstantSignalsWithUnit.jl:")
showInfo(sigTable)

plot(sigTable, ["phi_max", "i_max", "open", "Inertia[2,2]", "Inertia[1,2:3]", "Inertia"], heading="Constants")

end