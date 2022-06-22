module ConstantSignals

using SignalTables
@usingPlotPackage

sigTable = getSignalTableExample("ConstantSignals")

plot(sigTable, [("phi_max", "i_max", "open"), ("matrix3[2,2]", "matrix2[1,2:3]"), "matrix1"], heading="Constants")

end