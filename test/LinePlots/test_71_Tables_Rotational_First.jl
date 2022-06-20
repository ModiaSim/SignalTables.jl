module test_71_Tables_Rotational_First

using SignalTables
using SignalTables.DataFrames
using CSV
SignalTables.@usingPlotPackage


sigTable1 = CSV.File("$(SignalTables.path)/test/test_71_Tables_Rotational_First.csv")
sigTable2 = DataFrames.DataFrame(sigTable1)

println("\n... test_71_Tables_Rotational_First.jl:")
println("CSV-Table (sigTable1 = CSV.File(fileName)):\n")
showInfo(sigTable1)

println("\nDataFrame-Table (sigTable2 = DataFrame(sigTable1)):\n")
showInfo(sigTable2)

plot(sigTable1, ["damper.w_rel", "inertia3.w"], prefix="sigTable1: ")
plot(sigTable2, ["damper.w_rel", "inertia3.w"], prefix="sigTable2: ", reuse=true)

end
