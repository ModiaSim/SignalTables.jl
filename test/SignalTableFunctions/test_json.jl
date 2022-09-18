module test_json

using SignalTables

println("\n... Write signal table in json format to file.")

t = 0.0:0.1:0.5
signalTable1 = SignalTable(
  "time"         => Var(values= t, unit="s", independent=true),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)], unit="m"),
  "motor.angle"  => Var(values= sin.(t), unit="rad", state=true, der="motor.w"),
  "motor.w"      => Var(values= cos.(t), unit="rad/s"),
  "motor.w_ref"  => Var(values= 0.9*[sin.(t) cos.(t)], unit = ["rad", "1/s"],
                                info="Reference angle and speed"),
  "wm"           => Var(alias = "motor.w"),
  "ref.clock"    => Var(values= [true, missing, missing, true, missing, missing],
                                 variability="clock"),
  "ref.trigger"  => Var(values= [missing, missing, true, missing, true, true],
                                 variability="trigger"),
  "motor.w_c"    => Var(values= [0.8, missing, missing, 1.5, missing, missing],
                                variability="clocked", clock="ref.clock"),

  "motor.inertia"=> Par(value = 0.02f0, unit="kg*m/s^2"),
  "motor.data"   => Par(value = "resources/motorMap.json"),
  "attributes"   => Map(info  = "This is a test signal table")
)

writeSignalTable("test_json_signalTable1.json", signalTable1, log=true, indent=2)


t  = 0.0:0.1:10.0
tc = [rem(i,5) == 0 ? div(i,5)+1 : missing for i in 0:length(t)-1]
sigTable2 = SignalTable(
  "_attributes"  => Map(experiment=Map(stopTime=10.0, interval=0.1)),
  "time"         => Var(values = t, unit="s", independent=true),
  "motor.angle"  => Var(values = sin.(t), unit="rad", der="motor.w"),
  "motor.w"      => Var(values = cos.(t), unit="rad/s"),
  "motor.w_ref"  => Var(values = 0.9*cos.(t), unit="rad/s"),  
  "baseClock"    => Var(values = tc, variability="clock"),
  "motor.w_c"    => Var(values = 1.2*cos.((tc.-1)/2), unit="rad/s",
                        variability="clocked", clock="baseClock"),
  "motor.file"   => Par(value = "motormap.json", 
                        info = "File name of motor characteristics")
)
showInfo(sigTable2)
@usingPlotPackage
plot(sigTable2, ("motor.w", "motor.w_c"), figure=2)
plot(sigTable2, "motor.w_c", xAxis="baseClock", figure=3)
writeSignalTable("sigTable2.json", sigTable2, log=true, indent=2)

end