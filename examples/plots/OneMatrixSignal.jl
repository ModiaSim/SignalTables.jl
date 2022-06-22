module OneMatrixSignal

using SignalTables
@usingPlotPackage

sigTable = getSignalTableExample("OneMatrixSignal")
plot(sigTable, ["matrix", "matrix[2,3]", "matrix[1,2:3]"], heading="Matrix signals")

end
