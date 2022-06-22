module JSON_WriteToString

using  SignalTables
import JSON

sigTable = getSignalTableExample("VariousTypes")
str = JSON.json(sigTable)

println("VariousType string = \n", str)

end