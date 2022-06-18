module TestSet

using SignalTables
using Unitful

t = 0.0:0.1:0.5
sigTable1 = SignalTable(
  "time"         => Var(values= t, unit="s", independent=true),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)]),  
  "motor.angle"  => Var(values= sin.(t), unit="rad"),
  "motor.w_ref"  => Var(values= cos.(t), unit="rad/s", info="Reference"),                       
  "motor.w_m"    => Var(values= [0.0, missing, missing, 1.5, missing, missing]),
  "motor.inertia"=> Par(value = 0.02, unit="kg*m/s^2"),
  "attributes"   => Par(info  = "This is a test signal table")
)
     

# @show sigTable1
# show(IOContext(stdout, :compact => true), sigTable1)
end