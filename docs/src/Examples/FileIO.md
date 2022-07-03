# FileIO Examples

```@meta
CurrentModule = SignalTables
```



## JSON - Write to File

```julia
using SignalTables

sigTable = getSignalTableExample("VariousTypes")
writeSignalTable("VariousTypes_prettyPrint.json", sigTable; indent=2, log=true)
writeSignalTable("VariousTypes_compact.json"    , sigTable)
```

results in the following files

- [VariousTypes_prettyPrint.json](../../resources/examples/fileIO/VariousTypes_prettyPrint.json).
- [VariousTypes_compact.json](../../resources/examples/fileIO/VariousTypes_compact.json).


## JSON - Write to String

```julia
using  SignalTables

str = signalTableToJSON( getSignalTableExample("VariousTypes") )
println(str)
```

results in the following print output

```julia
"{\"_class\":\"SignalTable\",\"time\":{\"_class\":\"Var\",\"values\":[0.0,0.1,0.2,0.3,0.4,0.5],\"unit\":\"s\",\"independent\":true},\"load.r\":{\"_class\":\"Var\",\"values\":{\"_class\":\"Array\",\"eltype\":\"Float64\",\"size\":[6,3],\"values\":[0.0,0.09983341664682815,0.19866933079506122,0.29552020666133955,0.3894183423086505,0.479425538604203,1.0,0.9950041652780258,0.9800665778412416,0.955336489125606,0.9210609940028851,0.8775825618903728,0.0,0.09983341664682815,0.19866933079506122,0.29552020666133955,0.3894183423086505,0.479425538604203]},\"unit\":\"m\"},\"motor.angle\":{\"_class\":\"Var\",\"values\":[0.0,0.09983341664682815,0.19866933079506122,0.29552020666133955,0.3894183423086505,0" ⋯ 533 bytes ⋯ ",\"info\":\"Reference angle and speed\"},\"wm\":{\"_class\":\"Var\",\"values\":[1.0,0.9950041652780258,0.9800665778412416,0.955336489125606,0.9210609940028851,0.8775825618903728],\"unit\":\"rad/s\",\"alias\":\"motor.w\"},\"ref.clock\":{\"_class\":\"Var\",\"values\":[true,null,null,true,null,null],\"variability\":\"clock\"},\"motor.w_c\":{\"_class\":\"Var\",\"values\":[0.6,null,null,0.8,null,null],\"variability\":\"clocked\",\"clock\":\"ref.clock\"},\"motor.inertia\":{\"_class\":\"Par\",\"value\":{\"_class\":\"Number\",\"type\":\"Float32\",\"value\":0.02},\"unit\":\"kg*m/s^2\"},\"motor.data\":{\"_class\":\"Par\",\"value\":\"resources/motorMap.json\"},\"attributes\":{\"_class\":\"Par\",\"info\":\"This is a test signal table\"}}"
```

Such a string could be communicated to a web browser.


## JLD (HDF5) - Write to File

[JLD](https://github.com/JuliaIO/JLD.jl) stores Julia objects in HDF5 format, hereby additional attributes
are stored to preserve type information. 

```julia
using SignalTables
using FileIO

sigTable = getSignalTableExample("VariousTypes")

save( File(format"JLD", "VariousTypes.jld"), sigTable)
```

results in the following file:

- [VariousTypes.jld](../../resources/examples/fileIO/VariousTypes.jld).

