module test_DataFrames

using  SignalTables
import SignalTables.DataFrames

println("\n... Convert DataFrame to SignalTable object")
t  = range(0.0, stop=10.0, length=10)
df = DataFrames.DataFrame(time=t, phi=sin.(t))

@show df

sigTable = toSignalTable(df)
showInfo(sigTable)

println("\n... Convert SignalTable to DataFrame object")
sigTable2 = getSignalTableExample("VariousTypes")
df2 = signalTableToDataFrame(sigTable2)
@show df2

end