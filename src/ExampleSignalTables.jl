#
# This file contains a function with a set of example signal tables
#


"""
    getSignalTableExample(signalTableName::String; logTitle=true, logShowInfo=true)

Return an example signal table.
"""
function getSignalTableExample(signalTableName::String; logTitle=true, logShowInfo=true)::SignalTable

if logTitle
    println("\n... $signalTableName (from SignalTables/src/ExampleSignalTables.jl)")
end

if signalTableName == "OneScalarSignal"

    t = range(0.0, stop=10.0, length=100)

    sigTable = SignalTable(
        "time" => Var(values = t, independent=true),
        "phi"  => Var(values = sin.(t))
    )

elseif signalTableName == "OneScalarSignalWithUnit"

    t = range(0.0, stop=10.0, length=100)

    sigTable = SignalTable(
        "time" => Var(values = t, unit="s", independent=true),
        "phi"  => Var(values = sin.(t), unit="rad")
    )

elseif signalTableName == "OneVectorSignalWithUnit"
    t = range(0.0, stop=10.0, length=100)

    sigTable = SignalTable(
        "time" => Var(values = t, unit="s", independent=true),
        "r"    => Var(values = [0.4*cos.(t)  0.5*sin.(t)  0.3*cos.(t)], unit="m"),
    )

elseif signalTableName == "OneMatrixSignal"

    t = range(0.0, stop=1.0, length=10)

    offset  = Float64[11  12  13;
                      21  22  23]
    matrix = Array{Float64,3}(undef,length(t),2,3)
    for i = 1:length(t), j = 1:2, k=1:3
        matrix[i,j,k] = offset[j,k] + 0.3*sin(t[i])
    end

    sigTable = SignalTable(
        "time"   => Var(values = t, independent=true),
        "matrix" => Var(values = matrix)
    )

elseif signalTableName == "OneMatrixSignalWithMatrixUnits"

    t = range(0.0, stop=1.0, length=10)

    offset  = Float64[11  12  13;
                      21  22  23]
    matrix = Array{Float64,3}(undef,length(t),2,3)
    for i = 1:length(t), j = 1:2, k=1:3
        matrix[i,j,k] = offset[j,k] + 0.3*sin(t[i])
    end

    sigTable = SignalTable(
        "time"   => Var(values = t, unit="s", independent=true),
        "matrix" => Var(values = matrix, unit=["m"   "m/s"   "m/s^2";
                                               "rad" "rad/s" "rad/s^2"])
    )

elseif signalTableName == "ConstantSignals"

    t = range(0.0, stop=1.0, length=5)

    matrix = Float64[11  12  13;
                     21  22  23]

    sigTable = SignalTable(
        "time"    => Var(values = t, unit="s", independent=true),
        "phi_max" => Par(value = 1.1f0, unit="rad"),
        "i_max"   => Par(value = 2),
        "open"    => Par(value = true),
        "file"    => Par(value = "filename.txt"),
        "matrix1" => Par(value = matrix),
        "matrix2" => Par(alias="matrix1", unit="m/s"),
        "matrix3" => Par(alias="matrix1", unit=["m"   "m/s"   "m/s^2";
                                                "rad" "rad/s" "rad/s^2"])
    )

elseif signalTableName == "MissingValues"

    time1 =  0.0 : 0.1 : 3.0
    time2 =  3.0 : 0.1 : 11.0
    time3 = 11.0 : 0.1 : 15
    t     = vcat(time1,time2,time3)
    sigC  = vcat(fill(missing,length(time1)), 0.6*cos.(time2.+0.5), fill(missing,length(time3)))

    function sigD(t, time1, time2)
        sig = Vector{Union{Missing,Float64}}(undef, length(t))

        j = 1
        for i = length(time1)+1:length(time1)+length(time2)
            if j == 1
                sig[i] = 0.5*cos(t[i])
            end
            j = j > 3 ? 1 : j+1
        end
        return sig
    end

    sigTable = SignalTable(
        "time"   => Var(values=t, unit="s", independent=true),
        "load.r" => Var(values=0.4*[sin.(t) cos.(t) sin.(t)], unit="m"),
        "sigA"   => Var(values=0.5*sin.(t), unit="m"),
        "sigB"   => Var(values=1.1*sin.(t), unit="m/s"),
        "sigC"   => Var(values=sigC, unit="N*m"),
        "sigD"   => Var(values=sigD(t, time1, time2), unit="rad/s", variability="clocked", info="Motor angular velocity")
    )

elseif signalTableName == "VariousTypes"

    t = 0.0:0.1:0.5
    sigTable = SignalTable(
    "_attributes" => Map(experiment=Map(stoptime=0.5, interval=0.01)),
    "time"        => Var(values= t, unit="s", independent=true),
    "load.r"      => Var(values= [sin.(t) cos.(t) sin.(t)], unit="m"),
    "motor.angle" => Var(values= sin.(t), unit="rad", state=true, der="motor.w"),
    "motor.w"     => Var(values= cos.(t), unit="rad/s", state=true, start=1.0u"rad/s"),
    "motor.w_ref" => Var(values= 0.9*[sin.(t) cos.(t)], unit = ["rad", "1/s"],
                                 info="Reference angle and speed"),
    "wm"          => Var(alias = "motor.w"),
    "ref.clock"   => Var(values= [true, missing, missing, true, missing, missing],
                                 variability="clock"),

    "motor.w_c"   => Var(values= [0.6, missing, missing, 0.8, missing, missing],
                                variability="clocked", clock="ref.clock"),

    "motor.inertia" => Par(value = 0.02f0, unit="kg*m/s^2"),
    "motor.data"    => Par(value = "resources/motorMap.json")
    )

else
    error("getSignalTableExample(\"$signalTableName\"): unknown name.")
end

if logShowInfo
    showInfo(sigTable)
    println()
end

return sigTable

end