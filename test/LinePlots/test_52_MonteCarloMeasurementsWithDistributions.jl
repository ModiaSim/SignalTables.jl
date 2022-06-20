module test_52_MonteCarloMeasurementsWithDistributions

using SignalTables

using SignalTables.Unitful
using SignalTables.MonteCarloMeasurements
using SignalTables.MonteCarloMeasurements.Distributions
@usingPlotPackage

t = range(0.0, stop=10.0, length=100)
uniform1(xmin,xmax) = MonteCarloMeasurements.Particles(      100,Distributions.Uniform(xmin,xmax))
uniform2(xmin,xmax) = MonteCarloMeasurements.StaticParticles(100,Distributions.Uniform(xmin,xmax))
particles1 = uniform1(-0.4, 0.4)
particles2 = uniform2(-0.4, 0.4)
sigTable = SignalTable(

# ∓ are 100 StaticParticles uniform distribution

"time" => t*u"s"
sigTable["phi1"] = [sin(t[i]) + particles1*t[i]/10.0 for i in eachindex(t)]*u"rad"
"phi2" => [sin(t[i]) + particles2*t[i]/10.0 for i in eachindex(t)]*u"rad"
sigTable["phi3"] = [sin(t[i]) ∓ 0.4*t[i]/10.0        for i in eachindex(t)]*u"rad"

println("\n... test_52_MonteCarloMeasurementsWithDistributions:")
showInfo(sigTable)

plot(sigTable, ["phi1", "phi2", "phi3"], figure=1,
     heading="Sine(time) with MonteCarloParticles/StaticParticles (plot area)")
     
plot(sigTable, ["phi1", "phi2", "phi3"], figure=2,
     heading="Sine(time) with MonteCarloParticles/StaticParticles (plot all runs)")

end

