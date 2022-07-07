module CSV_ReadFromFile

using  SignalTables
import CSV

file = joinpath(SignalTables.path, "examples", "fileIO", "Rotational_First.csv")
println("\n... Read csv file \"$file\"")
sigTable = CSV.File(file)

println("\n... Show csv file as signal table")
showInfo(sigTable)

println("\ntime[1:10] = ", getSignal(sigTable, "time")[:values][1:10])

end