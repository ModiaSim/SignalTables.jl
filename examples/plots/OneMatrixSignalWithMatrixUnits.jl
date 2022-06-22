module OneMatrixSignalWithMatrixUnits

using SignalTables
@usingPlotPackage

sigTable = getSignalTableExample("OneMatrixSignalWithMatrixUnits")
plot(sigTable, ["matrix", "matrix[2,3]", "matrix[1,2:3]"], heading="Matrix signals")

end
