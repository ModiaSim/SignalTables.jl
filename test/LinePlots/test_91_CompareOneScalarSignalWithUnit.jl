module test_91_CompareOneScalarSignalWithUnit

using SignalTables
using SignalTables.Unitful
using SignalTables.DataFrames
SignalTables.@usingPlotPackagePackage

t = range(0.0, stop=10.0, length=100)

sigTable1 = DataFrame()
sigTable2 = DataFrame()
sigTable3 = DataFrame()

sigTable1."time" = t*u"s"
sigTable1."w"    => sin.(t)*u"rad/s"

sigTable2."time" = t*u"s"
sigTable2."w"    => 0.0005*u"rad/s" .+ sin.(t)*u"rad/s"

sigTable3."time" = t
sigTable3."w"    => sin.(t.+0.001)

(success2, diff2, diff_names2, max_error2, within_tolerance2) = SignalTables.compareResults(sigTable1, sigTable2)
println("success2 = $success2, max_error2 = $max_error2, within_tolerance2 = $within_tolerance2")

(success3, diff3, diff_names3, max_error3, within_tolerance3) = SignalTables.compareResults(sigTable1, sigTable3)
println("success3 = $success3, max_error3 = $max_error3, within_tolerance3 = $within_tolerance3")

plot(sigTable1, "w", prefix="r1.")
plot(sigTable2, "w", prefix="r2.", reuse=true)
plot(sigTable3, "w", prefix="r3.", reuse=true)

plot(diff2, "w", prefix="diff2_", figure=2)

plot(diff3, "w", prefix="diff3_", figure=2, reuse=true)

end
