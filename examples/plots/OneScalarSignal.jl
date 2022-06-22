module OneScalarSignal

using SignalTables
@usingPlotPackage

sigTable = getSignalTableExample("OneScalarSignal")
plot(sigTable, "phi", heading="sine(time)")

end