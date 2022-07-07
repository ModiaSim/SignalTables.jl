module JSON_WriteToFile

using SignalTables

sigTable = getSignalTableExample("VariousTypes")
writeSignalTable("VariousTypes_prettyPrint.json", sigTable; indent=2, log=true)
writeSignalTable("VariousTypes_compact.json"    , sigTable)

end