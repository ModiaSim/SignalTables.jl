# FileIO Examples

```@meta
CurrentModule = SignalTables
```



## JSON - Write to File

```julia
using  SignalTables
import JSON

sigTable = getSignalTableExample("VariousTypes")

open("VariousTypes_prettyPrint.json", "w") do io
    JSON.print(io, sigTable, 2)
end

open("VariousTypes_compact.json", "w") do io
    JSON.print(io, sigTable)
end
```

results in the following files

- [VariousTypes_prettyPrint.json](../../resources/examples/fileIO/VariousTypes_prettyPrint.json).

- [VariousTypes_compact.json](../../resources/examples/fileIO/VariousTypes_compact.json).



## JSON - Write to String

```julia
using  SignalTables
import JSON

sigTable = getSignalTableExample("VariousTypes")
str = JSON.json(sigTable)

println("VariousType string = ", str)
```

results in the following print output

```julia
VariousType string = {"time":{"_class":"Var","values":[0.0,0.1,0.2,0.3,0.4,0.5],"unit":"s","independent":true},"load.r":{"_class":"Var","values":[[0.0,0.09983341664682815,0.19866933079506122,0.29552020666133955,0.3894183423086505,0.479425538604203],[1.0,0.9950041652780258,0.9800665778412416,0.955336489125606,0.9210609940028851,0.8775825618903728],[0.0,0.09983341664682815,0.19866933079506122,0.29552020666133955,0.3894183423086505,0.479425538604203]],"unit":"m"},"motor.angle":{"_class":"Var","values":[0.0,0.09983341664682815,0.19866933079506122,0.29552020666133955,0.3894183423086505,0.479425538604203],"unit":"rad","state":true},"motor.w":{"_class":"Var","values":[1.0,0.9950041652780258,0.9800665778412416,0.955336489125606,0.9210609940028851,0.8775825618903728],"unit":"rad/s","integral":"motor.angle"},"motor.w_ref":{"_class":"Var","values":[[0.0,0.08985007498214534,0.1788023977155551,0.2659681859952056,0.35047650807778546,0.4314829847437827],[0.9,0.8955037487502232,0.8820599200571175,0.8598028402130454,0.8289548946025966,0.7898243057013355]],"unit":["rad","1/s"],"info":"Reference angle and speed"},"wm":{"_class":"Var","values":[1.0,0.9950041652780258,0.9800665778412416,0.955336489125606,0.9210609940028851,0.8775825618903728],"unit":"rad/s","integral":"motor.angle","alias":"motor.w"},"ref.clock":{"_class":"Var","values":[true,null,null,true,null,null],"variability":"clock"},"motor.w_c":{"_class":"Var","values":[0.6,null,null,0.8,null,null],"variability":"clocked","clock":"ref.clock"},"motor.inertia":{"_class":"Par","value":0.02,"unit":"kg*m/s^2"},"motor.data":{"_class":"Par","value":"resources/motorMap.json"},"attributes":{"_class":"Par","info":"This is a test signal table"}}
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

