module VariousTypes

using SignalTables
@usingPlotPackage

sigTable = getSignalTableExample("VariousTypes")
plot(sigTable, ["load.r", ("motor.w", "wm", "motor.w_c", "ref.clock")], heading="VariousTypes")

end
