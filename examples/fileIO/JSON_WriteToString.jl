module JSON_WriteToString

using SignalTables

str = signalTableToJSON( getSignalTableExample("VariousTypes") )
println(str)

end