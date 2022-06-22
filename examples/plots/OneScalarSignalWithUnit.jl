module OneScalarSignalWithUnit

using SignalTables
@usingPlotPackage

sigTable = getSignalTableExample("OneScalarSignalWithUnit")
plot(sigTable, "phi", heading="Sine(time)")

end