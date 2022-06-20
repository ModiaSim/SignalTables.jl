module TestSet

using SignalTables
using SignalTables.Unitful

t = 0.0:0.1:0.5
sigTable1 = SignalTable(
  "time"         => Var(values= t, unit="s", variability="independent"),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)], unit="m"),
  "motor.angle"  => Var(values= sin.(t), unit="rad", state=true),
  "motor.w"      => Var(values= cos.(t), unit="rad/s", integral="motor.angle"),
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
  "attributes"   => Par(info  = "This is a test signal table")
)

#@show sigTable1
#show(IOContext(stdout, :compact => true), sigTable1)
end