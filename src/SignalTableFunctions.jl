"""
    compactPaths(str::String)

Returns a compacted string, where all paths with dots are reduced to their leaf name.
Example: compactPaths("MonteCarloMeasurements.Particles") is reduced to "Particles".
"""
function compactPaths(str::String)
    str
end


"""
    dictToString(dict:AbstractDict)
"""
function dictToString(dict::AbstractDict)::String
    io = IOBuffer()
    str = ""
    first = true
    for (key,value) in dict
        if first
            first = false
        else
            show(io, ", ")
        end
        print(io, key, "=")
        show(io, value)
    end
    str = String(take!(io))
    return str
end


"""
    getValues(signalTable, name)

Returns the *values* of a [`Var`](@ref) signal name from signalTable.
"""
getValues(signalTable, name::String) = getSignal(signalTable, name)[:values]

"""
    getValue(signalTable, name)

Returns the *value* of a [`Par`](@ref) signal name from signalTable.
"""
getValue( signalTable, name::String) = getSignal(signalTable, name)[:value]


"""
    getValuesWithUnit(signalTable, name)

Returns the *values* of a [`Var`](@ref) signal name from signalTable including its unit.
"""
getValuesWithUnit(signalTable, name::String) = begin
    sig = getSignal(signalTable, name)
    sigUnit = get(sig, :unit, "")
    sigVal  = sig[:values]
    if typeof(sigUnit) <: AbstractArray
        error("getValuesWithUnit(signalTable, $name) is not yet supported for unit arrays (= $sigUnit)")
    elseif sigUnit != ""
        sigVal = sigVal*uparse(sigUnit)
    end
end


"""
    getValueWithUnit(signalTable, name)

Returns the *value* of a [`Par`](@ref) signal name from signalTable including its unit.
"""
getValueWithUnit(signalTable, name::String) = begin
    sig = getSignal(signalTable, name)
    sigUnit = get(sig, :unit, "")
    sigVal  = sig[:value]
    if typeof(sigUnit) <: AbstractArray
        error("getValueWithUnit(signalTable, $name) is not yet supported for unit arrays (= $sigUnit)")
    elseif sigUnit != ""
        sigVal = sigVal*uparse(sigUnit)
    end
end


const doNotShowAttributes = [:_class, :_typeof, :_size, :unit]


"""
    showInfo([io::IO=stdout,] signalTable;
             sorted=false, Var=true, Par=true, attributes=true)

Writes info about a signal table to the output stream.
The keyword arguments define what information shall be printed
or whether the names shall be sorted or presented in definition order.

# Example

```julia
using SignalTables
using Unitful

t = 0.0:0.1:0.5
sigTable = SignalTable(
  "time"         => Var(values= t, unit="s", independent=true),
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

signalInfo(sigTable)
```

results in the following output

```julia
name          unit          size  basetype kind attributes
─────────────────────────────────────────────────────────────────────────────────────────
time          "s"           (6,)  Float64  Var  independent=true
load.r        "m"           (6,3) Float64  Var
motor.angle   "rad"         (6,)  Float64  Var  state=true
motor.w       "rad/s"       (6,)  Float64  Var  integral="motor.angle"
motor.w_ref   ["rad","1/s"] (6,2) Float64  Var  info="Reference angle and speed"
wm            "rad/s"       (6,)  Float64  Var  integral="motor.angle", alias="motor.w"
ref.clock                   (6,)  Bool     Var  variability="clock"
ref.trigger                 (6,)  Bool     Var  variability="trigger"
motor.w_c                   (6,)  Float64  Var  variability="clocked", clock="ref.clock"
motor.inertia "kg*m/s^2"    ()    Float32  Par
motor.data                  ()    String   Par
attributes                                 Par  info="This is a test signal table"
```
"""
function showInfo(io::IO, signalTable;
                  sorted=false, Var=true, Par=true, attributes=true)::Nothing
    if isnothing(signalTable)
        @info "The call of showInfo(signalTable) is ignored, since the argument is nothing."
        return
    end

    name2     = String[]
    unit2     = String[]
    size2     = String[]
    basetype2 = String[]
    kind2     = String[]
    attr2     = String[]

    sigNames = signalNames(signalTable)
    if sorted
        sigNames = sort(sigNames)
    end
    if attributes
        iostr = IOBuffer()
    end

    for name in sigNames
        signal = getSignalInfo(signalTable, name)
        kind   = isVar(signal) ? "Var" : "Par"
        if Var && kind == "Var" || Par && kind == "Par"
            if attributes
                first = true
                for (key,val) in signal
                    if key in doNotShowAttributes
                        continue
                    end

                    if first
                        first = false
                    else
                        print(iostr, ", ")
                    end
                    print(iostr, key, "=")
                    show(iostr, val)
                end
                attr = String(take!(iostr))
            end
            independent = get(signal, :independent, false)
            valBaseType = get(signal, :_typeof, "")
            if valBaseType != ""
                @show name
                @show get(signal, :_typeof, "")
                @show BaseType(valBaseType)
                valBaseType = string( BaseType(valBaseType) )
            end
            valSize = string( get(signal, :_size, "") )
            valUnit = get(signal, :unit, "")
            if typeof(valUnit) <: AbstractString
                if valUnit != ""
                    valUnit = "\"$valUnit\""
                end
            else
                show(iostr, valUnit)
                valUnit = String(take!(iostr))
            end

            if independent
                pushfirst!(name2    , name)
                pushfirst!(unit2    , valUnit)
                pushfirst!(size2    , valSize)
                pushfirst!(basetype2, valBaseType)
                pushfirst!(kind2    , kind)
                if attributes
                    pushfirst!(attr2, attr)
                end
            else
                push!(name2    , name)
                push!(unit2    , valUnit)
                push!(size2    , valSize)
                push!(basetype2, valBaseType)
                push!(kind2    , kind)
                if attributes
                    push!(attr2, attr)
                end
            end
        end
    end

    if attributes
        infoTable = DataFrames.DataFrame(name=name2, unit=unit2, size=size2, basetype=basetype2, kind=kind2, attributes=attr2)
    else
        infoTable = DataFrames.DataFrame(name=name2, unit=unit2, size=size2, basetype=basetype2, kind=kind2)
    end

    show(io, infoTable, show_row_number=false, summary=false, allcols=true, eltypes=false, truncate=50) # rowlabel=Symbol("#")
    println(io)
    return nothing
end
showInfo(signalTable; kwargs...) = showInfo(stdout, signalTable; kwargs...)


const TypesForPlotting = [Float64, Float32, Int]

nameWithUnit(name::String, unit::String) = unit == "" ? name : string(name, " [", unit, "]")


#TargetElType(::Type{T})                                           where {T}     = T
#TargetElType(::Type{Measurements.Measurement{T}})                 where {T}     = T
#TargetElType(::Type{MonteCarloMeasurements.Particles{T,N}})       where {T,N}   = T
#TargetElType(::Type{MonteCarloMeasurements.StaticParticles{T,N}}) where {T,N}   = T

function basetypeWithMeasurements(obj)
    btype = basetype(obj)
    #if typeof(obj) <: AbstractArray
    #    obj1 = obj[1]
    #    if eltype(obj1) <: Real
    #        if hasfield(obj1, :particles)    # MonteCarloMeasurements
    #            btype = eltype(obj1.particles)
    #        elseif hasfield(obj1, :val) && hasfield(obj1, :err) # Measurements
    #            btype = typeof(obj1.val)
    #        end
    #    end
    #end
    return btype
end


function getValuesFromPar(signal, len::Int)
    sigValue = signal[:value]
    if typeof(sigValue) <: Number || typeof(sigValue) <: AbstractArray
        sigSize = (len,size(sigValue)...)
        sigValues2 = Array{eltype(sigValue),ndims(sigValue)+1}(undef, sigSize)
        if ndims(sigValue) == 0
            for i = 1:len
                sigValues2[i] = sigValue
            end
        else
            nsig = prod(sigSize[i] for i=2:length(sigSize))
            sig1 = reshape(sigValues2, (len, nsig))
            sig2 = reshape(sigValue, nsig)
            for i = 1:len, j=1:nsig
                sig1[i,j] = sig2[j]
            end
            sigValues2 = reshape(sig1, sigSize)
        end
        return sigValues2
    end
    return nothing
end
    

"""
    flattenedSignal = getFlattenedSignal(signalTable, name;
                                         missingToNaN = true,
                                         targetInt    = Int,
                                         targetFloat  = Float64)

Returns a copy of a signal where the values or the value are *flattened* and converted (e.g.: missing -> NaN).
A flattened signal can be, for example, used for traditional plot functions or for traditional tables.

Flattened values is a reshape of values into a vector or a matrix with optionally the following transformations:

- `name` can be a signal name with or without array range indices (for example `name = "a.b.c[2,3:5]"`).
- If `missingToNaN=true`, then missing values are replaced by NaN values.
  If NaN does not exist in the corresponding type, the values are first converted to `targetFloat`.
- If targetInt is not nothing, Int-types are converted to targetInt
- If targetFloat is not nothing, Float-types are converted to targetFloat
- collect(..) is performed on the result.

Legend is a vector of strings that provides a description for every array column
(e.g. if `"name=a.b.c[2,3:5]", unit="m/s"`, then `legend = ["a.b.c[2,3] [m/s]", "a.b.c[2,3] [m/s]", "a.b.c[2,5] [m/s]"]`.

If the required transformation is not possible, a warning message is printed and `nothing` is returned.
"""
function getFlattenedSignal(signalTable, name::String;
                                         missingToNaN = true,
                                         targetInt    = Int,
                                         targetFloat  = Float64)                                         
    if length(signalTable.independentSignalsFirstDimension) != 1  
        ni = length(signalTable.independentSignalsFirstDimension)
        error("getFlattenedSignal(..) currently only supported for one independent signal,\nbut number of independent signals = $ni!")
    end    
    lenx = signalTable.independentSignalsFirstDimension[1]
    sigPresent = false
    if hasSignal(signalTable,name)
        # name is a signal name without range
        signal = getSignal(signalTable,name)  
        if isVar(signal) && haskey(signal, :values)
            sigValues = signal[:values]
        elseif isPar(signal) && haskey(signal, :value)
            sigValues = getValuesFromPar(signal, lenx)
            if isnothing(sigValues)
                @goto ERROR
            end
        else
            @goto ERROR            
        end
        dims = size(sigValues)
        if dims[1] > 0
            sigPresent = true
            if length(dims) > 2
                # Reshape to a matrix
                sigValues = reshape(sigValues, dims[1], prod(dims[i] for i=2:length(dims)))
            end

            # Collect information for legend
            arrayName = name
            sigUnit   = get(signal, :unit, "")
            if length(dims) == 1
                arrayIndices   = ()
                nScalarSignals = 1
            else
                varDims = dims[2:end]
                arrayIndices   = Tuple(1:Int(ni) for ni in varDims)
                nScalarSignals = prod(i for i in varDims)
            end
        end
 
    else
        # Handle signal arrays, such as a.b.c[3] or a.b.c[2:3, 1:5, 3]
        if name[end] == ']'
            i = findlast('[', name)
            if i >= 2
                arrayName = name[1:i-1]
                indices   = name[i+1:end-1]
                if hasSignal(signalTable, arrayName)
                    signal = getSignal(signalTable,arrayName)
                    if isVar(signal) && haskey(signal, :values)
                        sigValues = signal[:values]
                    elseif isPar(signal) && haskey(signal, :value)
                        sigValues = getValuesFromPar(signal, lenx)
                        if isnothing(sigValues)
                            @goto ERROR
                        end
                    else
                        @goto ERROR            
                    end
                    dims = size(sigValues)

                    if dims[1] > 0
                        sigPresent = true

                        # Determine indices as tuple
                        arrayIndices = ()
                        try
                            arrayIndices = eval( Meta.parse( "(" * indices * ",)" ) )
                        catch
                            @goto ERROR
                        end

                        # Extract sub-array and collect info for legend
                        sigValues = getindex(sigValues, (:, arrayIndices...)...)
                        sigUnit   = get(signal, :unit, "")
                        dims      = size(sigValues)
                        nScalarSignals = length(dims) == 1 ? 1 : prod(i for i in dims[2:end])
                        if length(dims) > 2
                            # Reshape to a matrix
                            sigValues = reshape(sigValues, dims[1], nScalarSignals)
                        end
                    end
                end
            end
        end
    end
    if !sigPresent
        @goto ERROR
    end
        
    # Transform sigValues
    sigElType = eltype(sigValues)
    basetype2 = basetypeWithMeasurements(sigValues)
    hasMissing = isa(missing, sigElType)

    if  (!isnothing(targetInt)   && basetype2 == targetInt || 
         !isnothing(targetFloat) && basetype2 == targetFloat) &&
         !(missingToNaN && hasMissing)        
        # Signal need not be converted - do nothing

    elseif hasMissing && missingToNaN && !isnothing(targetFloat)
        # sig contains missing or nothing - convert to targetFloat and replace missing by NaN
        sigNaN     = convert(targetFloat, NaN)
        sigValues2 = Array{targetFloat, ndims(sigValues)}(undef, size(sigValues))        
        try
            for i = 1:length(sigValues)
                sigValues2[i] = ismissing(sigValues[i]) ? sigNaN : convert(targetFloat, sigValues[i])
            end
        catch
            # Cannot be converted
            @warn "\"$name\" is ignored, because its element type = $sigElType\nwhich cannot be converted to targetFloat = $targetFloat."
            return nothing
        end
        sigValues = sigValues2
        
    elseif !hasMissing && sigElType <: Integer && !isnothing(targetInt)
        # Transform to targetInt
        sigValues2 = Array{targetInt, ndims(sigValues)}(undef, size(sigValues))
        for i = 1:length(sigValues)
            sigValues2[i] = convert(targetInt, sigValues[i])
        end
        sigValues = sigValues2

    elseif !hasMissing && sigElType <: Real && !isnothing(targetFloat)
        # Transform to targetFloat
        sigValues2 = Array{targetFloat, ndims(sigValues)}(undef, size(sigValues))
        for i = 1:length(sigValues)
            sigValues2[i] = convert(targetFloat, sigValues[i])
        end
        sigValues = sigValues2
        
    else
        @goto ERROR
    end

    # Build legend
    if arrayIndices == ()
        # sig is a scalar variable
        legend = String[nameWithUnit(name, sigUnit)]

    else
        # sig is an array variable
        legend = [arrayName * "[" for i = 1:nScalarSignals]
        i = 1
        sizeLength = Int[]
        for j1 in eachindex(arrayIndices)
            push!(sizeLength, length(arrayIndices[j1]))
            i = 1
            if j1 == 1
                for j2 in 1:div(nScalarSignals, sizeLength[1])
                    for j3 in arrayIndices[1]
                        legend[i] *= string(j3)
                        i += 1
                    end
                end
            else
                ncum = prod( sizeLength[1:j1-1] )
                for j2 in arrayIndices[j1]
                    for j3 = 1:ncum
                        legend[i] *= "," * string(j2)
                        i += 1
                    end
                end
            end
        end

        for i = 1:nScalarSignals
            legend[i] *= nameWithUnit("]", sigUnit)
        end
    end

    signal = copy(signal)
    signal[:flattenedValues] = collect(sigValues)
    signal[:legend] = legend
    return signal

    @label ERROR
    @warn "\"$name\" is ignored, because it is not defined or is not correct or has no values."
    return nothing
end


# Deprecated (provided to use the plot functions without any changes

@enum SignalType Independent=1 Continuous=2 Clocked=3


function signalValuesForLinePlots(sigTable, name)
    signal = getFlattenedSignal(sigTable, name)
    if isnothing(signal)
        return (nothing, nothing, nothing)
    end
    sig         = signal[:flattenedValues]
    sigLegend   = signal[:legend]
    variability = get(signal, :variability, "")  
    if variability == "independent"
        sigKind = Independent
    elseif variability == "clocked" || variability == "clock" || variability == "trigger" || get(signal, "interpolation", "") == "none"
        sigKind = Clocked
    else
        sigKind = Continuous
    end
    return (sig, sigLegend, sigKind)
end


function getPlotSignal(sigTable, ysigName::AbstractString; xsigName=nothing)
    (ysig, ysigLegend, ysigKind) = signalValuesForLinePlots(sigTable, ysigName)
    if isnothing(ysig)
        @goto ERROR
    end
    if isnothing(xsigName)
        xNames = independentSignalNames(sigTable)
        if length(xNames) != 1
            error("Plotting requires currently exactly one independent signal. However, independentSignalNames = $independentSignalNames")
        end
        xsigName2 = xNames[1]
    else
        xsigName2 = xsigName
    end
    (xsig, xsigLegend, xsigKind) = signalValuesForLinePlots(sigTable, xsigName2)
    if isnothing(xsig)
        @goto ERROR
    end    

    # Check x-axis signal
    if ndims(xsig) != 1
        @warn "\"$xsigName\" does not characterize a scalar variable as needed for the x-axis."
        @goto ERROR
    #elseif !(typeof(xsigValue) <: Real                                   || 
    #         typeof(xsigValue) <: Measurements.Measurement               ||
    #         typeof(xsigValue) <: MonteCarloMeasurements.StaticParticles ||
    #         typeof(xsigValue) <: MonteCarloMeasurements.Particles       )
    #    @warn "\"$xsigName\" is of type " * string(typeof(xsigValue)) * " which is not supported for the x-axis."
    #    @goto ERROR        
    end

    return (xsig, xsigLegend[1], ysig, ysigLegend, ysigKind)

    @label ERROR
    return (nothing, nothing, nothing, nothing, nothing)
end


"""
    getHeading(signalTable, heading)

Return `heading` if no empty string. Otherwise, return `defaultHeading(signalTable)`.
"""
getHeading(signalTable, heading::AbstractString) = heading != "" ? heading : getDefaultHeading(signalTable)
