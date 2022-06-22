module MissingValues

using SignalTables
@usingPlotPackage

sigTable = getSignalTableExample("MissingValues")
plot(sigTable, [("sigC", "load.r[2:3]"), ("sigB", "sigD")])

end
