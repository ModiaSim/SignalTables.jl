module JLD_HDF5_WriteToFile

using SignalTables
using FileIO

sigTable = getSignalTableExample("VariousTypes")

save( File(format"JLD", "VariousTypes.jld"), sigTable)

end