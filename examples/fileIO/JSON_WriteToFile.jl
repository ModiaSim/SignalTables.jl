module JSON_WriteToFile

using  SignalTables
import JSON

sigTable = getSignalTableExample("VariousTypes")

open("VariousTypes_prettyPrint.json", "w") do io
    JSON.print(io, sigTable, 2)
end

open("VariousTypes_compact.json", "w") do io
    JSON.print(io, sigTable)
end

end