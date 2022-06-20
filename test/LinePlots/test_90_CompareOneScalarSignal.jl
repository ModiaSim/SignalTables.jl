module test_90_CompareOneScalarSignal

using SignalTables

using SignalTables.DataFrames
SignalTables.@usingPlotPackagePackage

t1 = range(0.0, stop=10.0, length=100)
t2 = deepcopy(t1)
t3 = range(0.0 , stop=10.0 , length=112)
t4 = range(-0.1, stop=10.1, length=111)

sigTable1 = OrderedDict{String,Any}()
sigTable2 = DataFrame()
sigTable3 = DataFrame()
sigTable4 = DataFrame()

sigTable1["time"]   = t1
sigTable1["phi"]    = sin.(t1)

sigTable2."time"    = t2
sigTable2."phi"     = sin.(t2)

sigTable3[!,"time"] = t3
sigTable3[!,"phi"]  = sin.(t3)

sigTable4."time"    = t4
sigTable4."phi"     = sin.(t4.+0.01)


# Check makeSameTimeAxis
(sigTable1b, sigTable2b, sameTimeRange1) = SignalTables.makeSameTimeAxis(sigTable1, sigTable2, select=["phi", "w"])
println("sameTimeRange1 = ", sameTimeRange1)

(sigTable1c, sigTable3b, sameTimeRange3) = SignalTables.makeSameTimeAxis(sigTable1, sigTable3)
println("sameTimeRange3 = ", sameTimeRange3)

(sigTable1d, sigTable4b, sameTimeRange4) = SignalTables.makeSameTimeAxis(sigTable1, sigTable4)
println("sameTimeRange4 = ", sameTimeRange4)

# check compareResults
(success2, diff2, diff_names2, max_error2, within_tolerance2) = SignalTables.compareResults(sigTable1, sigTable2)
println("success2 = $success2, max_error2 = $max_error2, within_tolerance2 = $within_tolerance2")

(success3, diff3, diff_names3, max_error3, within_tolerance3) = SignalTables.compareResults(sigTable1, sigTable3)
println("success3 = $success3, max_error3 = $max_error3, within_tolerance3 = $within_tolerance3")

(success4, diff4, diff_names4, max_error4, within_tolerance4) = SignalTables.compareResults(sigTable1, sigTable4)
println("success4 = $success4, max_error4 = $max_error4, within_tolerance4 = $within_tolerance4")

plot(sigTable1, "phi", prefix="r1.")
plot(sigTable2, "phi", prefix="r2.", reuse=true)
plot(sigTable3, "phi", prefix="r3.", reuse=true)
plot(sigTable4, "phi", prefix="r4.", reuse=true)

plot(sigTable1b, "phi", prefix="r1b.", reuse=true)
plot(sigTable2b, "phi", prefix="r2b.", reuse=true)

plot(sigTable1c, "phi", prefix="r1c.", reuse=true)
plot(sigTable3b, "phi", prefix="r3b.", reuse=true)

plot(sigTable1d, "phi", prefix="r1d.", reuse=true)
plot(sigTable4b, "phi", prefix="r4b.", reuse=true)

plot(diff2, "phi", prefix="diff2_", figure=2)

plot(diff3, "phi", prefix="diff3_", figure=2, reuse=true)

plot(diff4, "phi", prefix="diff4_", figure=2, reuse=true)

end
