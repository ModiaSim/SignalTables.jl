module test_80_Warnings

using SignalTables

using SignalTables.Unitful
SignalTables.@usingPlotPackage

t  = range(0.0, stop=10.0, length=100)
t2 = range(0.0, stop=10.0, length=110)

sigTable = SignalTable(

"time" => t*u"s"
"phi"  => sin.(t)u"rad"
"phi2" => 0.5 * sin.(t)u"rad"
"w"    => cos.(t)u"rad/s"
"w2"   => 0.6 * cos.(t)u"rad/s"
"r"    = [[0.4 * cos(t[i]), 
                   0.5 * sin(t[i]), 
                   0.3 * cos(t[i])] for i in eachindex(t)]*u"m"

sigTable["nothingSignal"]   = nothing
sigTable["emptySignal"]     = Float64[]
sigTable["wrongSizeSignal"] = sin.(t2)u"rad"

println("\n... test_40_Warnings")
showInfo(sigTable)

plot(sigTable, ("phi", "r", "signalNotDefined"), heading="Plot with warning 1" , figure=1)
plot(sigTable, ("signalNotDefined",
              "nothingSignal",
              "emptySignal",
              "wrongSizeSignal"), 
              heading="Plot with warning 2" , figure=2)
end