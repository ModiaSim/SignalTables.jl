using SignalTables

println("\n... Constructing signalTable3")
time1 =  0.0 : 0.1 : 3.0
time2 =  3.0 : 0.1 : 11.0
time3 = 11.0 : 0.1 : 15
t     = vcat(time1,time2,time3)   
sigC  = vcat(fill(missing,length(time1)), 0.6*cos.(time2.+0.5), fill(missing,length(time3)))

function sigD()
    global t, time1, time2
    sigD = Vector{Union{Missing,Float64}}(undef, length(t))
    
    j = 1
    for i = length(time1)+1:length(time1)+length(time2)
        if j == 1 
            sigD[i] = 0.5*cos(t[i])
        end
        j = j > 3 ? 1 : j+1
    end
    return sigD
end

sigTable = SignalTable(
    "time"   => Var(values=t, unit="s", independent=true),
    "load.r" => Var(values=0.4*[sin.(t) cos.(t) sin.(t)], unit="m"),  
    "sigA"   => Var(values=0.5*sin.(t), unit="m"),
    "sigB"   => Var(values=1.1*sin.(t), unit="m/s"),
    "sigC"   => Var(values=sigC, unit="N*m"),
    "sigD"   => Var(values=sigD(), unit="rad/s", variability="clocked", info="Motor angular velocity")  
)

#showInfo(signalTable3)