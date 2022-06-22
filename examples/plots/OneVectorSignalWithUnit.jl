module OneVectorSignalWithUnit

using SignalTables
@usingPlotPackage

sigTable = getSignalTableExample("OneVectorSignalWithUnit")

plot(sigTable, ["r", "r[2]", "r[2:3]"], heading="Plot vector signals")

end