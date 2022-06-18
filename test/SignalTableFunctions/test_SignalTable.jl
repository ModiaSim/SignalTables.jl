module test_SignalTables

using SignalTables
using Unitful

t = 0.0:0.1:0.5
sigTable = SignalTable(
  "time"         => Var(values= t, unit="s", independent=true),
  "load.r"       => Var(values= [sin.(t) cos.(t) sin.(t)]),  
  "motor.angle"  => Var(values= sin.(t), unit="rad"),
  "motor.w_ref"  => Var(values= cos.(t), unit="rad/s", info="Reference"),                       
  "motor.w_m"    => Var(values= [0.0, missing, missing, 1.5, missing, missing]),
  "motor.inertia"=> Par(value = 0.02, unit="kg*m/s^2"),
  "attributes"   => Par(info  = "This is a test signal table")
)
                      
# Abstract Signal Tables Interface
w_m_sig = getSignal(        sigTable, "motor.w_ref")   # = Var(values=..., unit=..., info=...)
w_ref   = getValuesWithUnit(sigTable, "motor.w_ref")   # = [0.0, 0.0998, 0.1986, ...]u"rad/s"
w_m     = getValues(        sigTable, "motor.w_m"  )   # = [0.9, missing, missing, 0.859, ...]
inertia = getValueWithUnit( sigTable, "motor.inertia") # = 0.02u"kg*m/s^2"

end