module test_07_OneScalarMeasurementSignalWithUnit

using SignalTables

using SignalTables.Unitful
using SignalTables.Measurements
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)
c = ones(size(t,1))

sigTable = SignalTable(

"time" => t*u"s"
"phi"  => [sin(t[i]) ± 0.1*c[i]  for i in eachindex(t)]*u"rad"

println("\n... test_07_OneScalarMeasurementSignalWithUnit:")
showInfo(sigTable)

plot(sigTable, "phi", heading="Sine(time) with Measurement")

end
