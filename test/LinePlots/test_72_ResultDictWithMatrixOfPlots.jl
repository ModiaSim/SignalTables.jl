module test_72_ResultDictWithMatrixOfPlots

using SignalTables
using SignalTables.Unitful
SignalTables.@usingPlotPackage

tr = [0.0, 15.0]
t0 = (tr, tr, SignalTables.Independent)
t1 = (0.0  : 0.1 : 15.0)
t2 = (0.0  : 0.1 : 3.0)
t3 = (5.0  : 0.3 : 9.5)
t4 = (11.0 : 0.1 : 15.0)
  
sigA1 = 0.9*sin.(t2)u"m"
sigA2 =     cos.(t3)u"m"
sigA3 = 1.1*sin.(t4)u"m"
R2    = [[0.4 * cos(t), 0.5 * sin(t), 0.3 * cos(t)] for t in t2]u"m"
R4    = [[0.2 * cos(t), 0.3 * sin(t), 0.2 * cos(t)] for t in t4]u"m"

sigA  = ([t2,t3,t4], [sigA1,sigA2,sigA3 ], SignalTables.Continuous)
sigB  = ([t1]      , [0.7*sin.(t1)u"m/s"], SignalTables.Continuous)
sigC  = ([t3]      , [sin.(t3)u"N*m"]    , SignalTables.Clocked)
r     = ([t2,t4]   , [R2,R4]             , SignalTables.Continuous)
    
sigTable = SignalTables.ResultDict("time" => t0, 
                                "sigA" => sigA,
                                "sigB" => sigB,
                                "sigC" => sigC,
                                "r"    => r,
                                defaultHeading = "Signals from test_72_ResultDictWithMatrixOfPlots",
                                hasOneTimeSignal = false)  

println("\n... test_72_ResultDictWithMatrixOfPlots.jl:\n")
showInfo(sigTable)

plot(sigTable, [("sigA", "sigB", "sigC"), "r[2:3]"])

end
