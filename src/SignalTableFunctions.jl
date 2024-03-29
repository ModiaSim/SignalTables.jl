"""
    compactPaths(str::String)

Returns a compacted string, where all paths with dots are reduced to their leaf name.
Example: compactPaths("MonteCarloMeasurements.Particles") is reduced to "Particles".
"""
function compactPaths(str::String)
    i1 = findfirst("{", str)
    if isnothing(i1)
        i2 = findlast(".", str)
    else
        i2 = findprev(".", str, i1[1])
    end
    if !isnothing(i2) && length(str) > i2[1]
        str = str[i2[1]+1:end]
    end
    str = replace(str, " " => "")  # remove blanks
    return str
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
    new_signal_table(args...)::OrderedDict{String,Any}

Returns a new signal table, that is `OrderedDict{String,Any}("_class" => :SignalTable, args...)`
"""
new_signal_table(args...) = OrderedDict{String,Any}("_class" => :SignalTable, args...)


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
    return sigVal
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


const doNotShowAttributes = [:_class, :_eltypeOrType, :_size, :unit]

function showMapValue(iostr,mapValue)::Nothing
    print(iostr, "Map(")
    first = true
    for (key,val) in mapValue
        if key in doNotShowAttributes
            continue
        end
        if first
            first = false
        else
            print(iostr, ", ")
        end
        print(iostr, key, "=")
        if isMap(val)
            showMap(iostr, val)
        end
        show(iostr,val)
    end
    print(iostr, ")")
    return nothing
end

"""
    showInfo([io::IO=stdout,] signalTable;
             sorted=false, showVar=true, showPar=true, showMap=true, showAttributes=true)

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
  "motor.angle"  => Var(values= sin.(t), unit="rad", state=true, der="motor.w"),
  "motor.w"      => Var(values= cos.(t), unit="rad/s"),
  "motor.w_ref"  => Var(values= 0.9*[sin.(t) cos.(t)], unit = ["rad", "1/s"],
                                info="Reference angle and speed"),
  "wm"           => Var(alias = "motor.w"),
  "ref.clock"    => Var(values= [true, missing, missing, true, missing, missing],
                                 variability="clock"),
  "motor.w_c"    => Var(values= [0.8, missing, missing, 1.5, missing, missing],
                                variability="clocked", clock="ref.clock"),
  "motor.inertia"=> Par(value = 0.02f0, unit="kg*m/s^2"),
  "motor.data"   => Par(value = "resources/motorMap.json"),
  "attributes"   => Map(experiment=Map(stoptime=0.5, interval=0.01))
)

signalInfo(sigTable)
```

results in the following output

```julia
name          unit           size  eltypeOrType           kind attributes
───────────────────────────────────────────────────────────────────────────────────────────────────────
time          "s"            [6]   Float64                Var independent=true
load.r        "m"            [6,3] Float64                Var
motor.angle   "rad"          [6]   Float64                Var state=true, der="motor.w"
motor.w       "rad/s"        [6]   Float64                Var
motor.w_ref   ["rad", "1/s"] [6,2] Float64                Var info="Reference angle and speed"
wm            "rad/s"        [6]   Float64                Var alias="motor.w"
ref.clock                    [6]   Union{Missing,Bool}    Var variability="clock"
motor.w_c                    [6]   Union{Missing,Float64} Var variability="clocked", clock="ref.clock"
motor.inertia "kg*m/s^2"           Float32                Par
motor.data                         String                 Par
attributes                                                Map experiment=Map(stoptime=0.5, interval=0.01)
```
"""
function showInfo(io::IO, signalTable;
                  sorted=false, showVar=true, showPar=true, showMap=true, showAttributes=true)::Nothing
    if isnothing(signalTable)
        @info "The call of showInfo(signalTable) is ignored, since the argument is nothing."
        return
    end

    name2     = String[]
    unit2     = String[]
    size2     = String[]
    eltypeOrType2 = String[]
    kind2     = String[]
    attr2     = String[]

    sigNames = getSignalNames(signalTable, getVar=showVar, getPar=showPar, getMap=showMap)
    if sorted
        sigNames = sort(sigNames)
    end
    iostr = IOBuffer()

    for name in sigNames
        signal = getSignalInfo(signalTable, name)
        kind   = isVar(signal) ? "Var" : (isPar(signal) ? "Par" : "Map")
        if showVar && kind == "Var" || showPar && kind == "Par" || showMap && kind == "Map"
            first = true
            if kind == "Par"
                val = getValue(signalTable, name)
                if !ismutable(val)
                    first = false
                    print(iostr, "=")
                    show(iostr, val)
                end
            end
            if showAttributes
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
                    if isMap(val)
                        showMapValue(iostr, val)
                    else
                        show(iostr, val)
                    end
                end
                attr = String(take!(iostr))
            end
            independent = get(signal, :independent, false)
            #println("$name: _type = ", get(signal, :_type, "notDefined"))
            valBaseType = string( get(signal, :_eltypeOrType, "") )
            valBaseType = compactPaths(valBaseType)
            valSize = string( get(signal, :_size, "") )
            valSize = replace(valSize, "()" => "", " " => "", ",)" => "]", "(" => "[", ")" => "]")
            valUnit = get(signal, :unit, "")
            if typeof(valUnit) <: AbstractString
                if valUnit != ""
                    valUnit = "\"$valUnit\""
                end
            else
                show(iostr, valUnit)
                valUnit = String(take!(iostr))
                #valUnit = replace(valUnit, "; " => ";\n")
            end

            push!(name2    , name)
            push!(unit2    , valUnit)
            push!(size2    , valSize)
            push!(eltypeOrType2, valBaseType)
            push!(kind2    , kind)
            if showAttributes
                push!(attr2, attr)
            end
        end
    end

    if showAttributes
        infoTable = DataFrames.DataFrame(name=name2, unit=unit2, size=size2, eltypeOrType=eltypeOrType2, kind=kind2, attributes=attr2)
    else
        infoTable = DataFrames.DataFrame(name=name2, unit=unit2, size=size2, eltypeOrType=eltypeOrType2, kind=kind2)
    end

    show(io, infoTable, show_row_number=false, summary=false, allcols=true, eltypes=false, truncate=50) # rowlabel=Symbol("#")
    println(io)
    return nothing
end
showInfo(signalTable; kwargs...) = showInfo(stdout, signalTable; kwargs...)


const TypesForPlotting = [Float64, Float32, Int]

nameWithUnit(name::String, unit::String) = unit == "" ? name : string(name, " [", unit, "]")

function nameWithArrayUnit(unit, indicesAsVector::Vector{Int})::String
    if unit == ""
        return "]"
    elseif typeof(unit) == String
        return string( "] [", unit, "]")
    else
        elementIndicesAsTuple = Tuple(i for i in indicesAsVector)
        elementUnit = unit[elementIndicesAsTuple...]
        return string("] [", elementUnit, "]")
    end
end


#TargetElType(::Type{T})                                           where {T}     = T
#TargetElType(::Type{Measurements.Measurement{T}})                 where {T}     = T
#TargetElType(::Type{MonteCarloMeasurements.Particles{T,N}})       where {T,N}   = T
#TargetElType(::Type{MonteCarloMeasurements.StaticParticles{T,N}}) where {T,N}   = T
#=
function eltypeOrTypeWithMeasurements(obj)
    if typeof(obj) <: AbstractArray
        obj1 = obj[1]
        if eltype(obj1) <: Real
        println("... is Real")
            Tobj1 = typeof(obj1)
            if hasfield(Tobj1, :particles)    # MonteCarloMeasurements
                btype = eltype(obj1.particles)
            elseif hasfield(Tobj1, :val) && hasfield(Tobj1, :err) # Measurements
                btype = typeof(obj1.val)
            else
                btype = eltypeOrType(obj)
            end
        end
    else
        btype = eltypeOrType(obj)
    end
    #catch
    #    btype = eltypeOrType(obj)
    #end
    return btype
end

function eltypeOrTypeWithMeasurements(obj)
    obj_eltype = eltype(obj)
    if obj_eltype <: Real
        if hasfield(obj_eltype, :particles)    # MonteCarloMeasurements
            btype = eltype(obj1.particles)
        elseif hasfield(Tobj1, :val) && hasfield(Tobj1, :err) # Measurements
            btype = typeof(obj1.val)
        else
            btype = eltypeOrType(obj)
        end
    end
    else
        btype = eltypeOrType(obj)
    end
    #catch
    #    btype = eltypeOrType(obj)
    #end
    return btype
end
=#

function eltypeOrTypeWithMeasurements(obj)
    obj1  = typeof(obj) <: AbstractArray ? obj[1] : obj
    Tobj1 = typeof(obj1)
    if hasfield(Tobj1, :particles)    # MonteCarloMeasurements
        btype = eltype(obj1.particles)
    elseif hasfield(Tobj1, :val) && hasfield(Tobj1, :err) # Measurements
        btype = typeof(obj1.val)
    else
        btype = eltypeOrType(obj)
    end
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
    signal = getFlattenedSignal(signalTable, name;
                                missingToNaN = true,
                                targetInt    = Int,
                                targetFloat  = Float64)

Returns a copy of a signal where the *flattened* and *converted* values (e.g.: missing -> NaN)
are stored as `signal[:flattenedValues]` and the legend as `signal[:legend]`.
A flattened signal can be, for example, used for traditional plot functions or for traditional tables.

`signal[:flattenedValues]` is a reshape of values into a vector or a matrix with optionally the following transformations:

- `name` can be a signal name with or without array range indices (for example `name = "a.b.c[2,3:5]"`).
- If `missingToNaN=true`, then missing values are replaced by NaN values.
  If NaN does not exist in the corresponding type, the values are first converted to `targetFloat`.
- If targetInt is not nothing, Int-types are converted to targetInt
- If targetFloat is not nothing, Float-types are converted to targetFloat
- collect(..) is performed on the result.

`flattenedSignal[:legend]` is a vector of strings that provides a description for every array column
(e.g. if `"name=a.b.c[2,3:5]", unit="m/s"`, then `legend = ["a.b.c[2,3] [m/s]", "a.b.c[2,3] [m/s]", "a.b.c[2,5] [m/s]"]`.

If the required transformation is not possible, a warning message is printed and `nothing` is returned.

As a special case, if signal[:values] is a vector or signal[:value] is a scalar and
an element of values or value is of type `Measurements{targetFloat}` or
`MonteCarloMeasurements{targetFloat}`, then the signal is not transformed,
so signal[:flattenedValues] = signal[:values].
"""
function getFlattenedSignal(signalTable, name::String;
                                         missingToNaN = true,
                                         targetInt    = Int,
                                         targetFloat  = Float64)
    independentSignalsSize = getIndependentSignalsSize(signalTable)
    if length(independentSignalsSize) != 1
        ni = length(independentSignalsSize)
        @info "getFlattenedSignal(.., \"$name\") supported for one independent signal,\nbut number of independent signals = $(ni)! Signal is ignored."
        return nothing
    end
    lenx = independentSignalsSize[1]
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
    eltypeOrType2 = eltypeOrTypeWithMeasurements(sigValues)
    hasMissing = isa(missing, sigElType)

    if  (!isnothing(targetInt)   && eltypeOrType2 == targetInt ||
         !isnothing(targetFloat) && eltypeOrType2 == targetFloat) &&
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
            @info "\"$name\" is ignored, because its element type = $sigElType\nwhich cannot be converted to targetFloat = $targetFloat."
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
        legendIndices = Vector{Vector{Int}}(undef, nScalarSignals)
        for i = 1:nScalarSignals
            legendIndices[i] = Int[]
        end
        i = 1
        sizeLength = Int[]
        for j1 in eachindex(arrayIndices)
            push!(sizeLength, length(arrayIndices[j1]))
            i = 1
            if j1 == 1
                for j2 in 1:div(nScalarSignals, sizeLength[1])
                    for j3 in arrayIndices[1]
                        legend[i] *= string(j3)
                        push!(legendIndices[i], j3)
                        # println("i = $i, j2 = $j2, j3 = $j3, legend[$i] = ", legend[i], ", legendIndices[$i] = ", legendIndices[i])
                        i += 1
                    end
                end
            else
                ncum = prod( sizeLength[1:j1-1] )
                for j2 in arrayIndices[j1]
                    for j3 = 1:ncum
                        legend[i] *= "," * string(j2)
                        push!(legendIndices[i], j2)
                        # println("i = $i, j2 = $j2, j3 = $j3, legend[$i] = ", legend[i], ", legendIndices[$i] = ", legendIndices[i])
                        i += 1
                    end
                end
            end
        end

        for i = 1:nScalarSignals
            legend[i] *= nameWithArrayUnit(sigUnit, legendIndices[i])
        end
    end

    signal = copy(signal)
    signal[:flattenedValues] = collect(sigValues)
    signal[:legend] = legend
    return signal

    @label ERROR
    @info "\"$name\" is ignored, because it is not defined or is not correct or has no values."
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
        xNames = getIndependentSignalNames(sigTable)
        if length(xNames) != 1
            error("Plotting requires currently exactly one independent signal. However, getIndependentSignalNames = $getIndependentSignalNames")
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
        @info "\"$xsigName\" does not characterize a scalar variable as needed for the x-axis."
        @goto ERROR
    #elseif !(typeof(xsigValue) <: Real                                   ||
    #         typeof(xsigValue) <: Measurements.Measurement               ||
    #         typeof(xsigValue) <: MonteCarloMeasurements.StaticParticles ||
    #         typeof(xsigValue) <: MonteCarloMeasurements.Particles       )
    #    @info "\"$xsigName\" is of type " * string(typeof(xsigValue)) * " which is not supported for the x-axis."
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




# ------------------------------- File IO ------------------------------------------------------

#
# Encoding and decoding Modia signal tables as JSON.
#
# Based on Modia/src/JSONModel.jl developed by Hilding Elmqvist
# License: MIT (expat)


import JSON

const TypesWithoutEncoding = Set([Float64, Int64, Bool, String, Symbol])

appendNames(name1, name2) = name1 == "" ? name2 : name1 * "." * string(name2)


"""
    jsigDict = encodeSignalTable(signalTable; signalNames = nothing)

Encodes a SignalTable suitable to convert to JSON format.

If a keyword signalNames with a vector of strings is provided, then only
the corresponding signals are encoded.
"""
function encodeSignalTable(signalTable; signalNames=nothing, log=false)
    if isSignalTable(signalTable)
        jdict = OrderedDict{String,Any}("_class" => "SignalTable",
                                        "_classVersion" => version_SignalTable_JSON)
        if isnothing(signalNames)
            signalNames = getSignalNames(signalTable)
        end
        for name in signalNames
            signal = getSignal(signalTable, name)
            if haskey(signal, :alias)
                signal = copy(signal)
                delete!(signal, :values)
                delete!(signal, :value)
            end
            encodedSignal = encodeSignalTableElement(name, signal, log=log)
            if !isnothing(encodedSignal)
                jdict[name] = encodedSignal
            end
        end
        return jdict
    else
        error("encodeSignalTable(signalTable, ...): signalTable::$(typeof(signalTable)) is no signal table.")
    end
end

arrayElementBaseType(::Type{T})                where {T} = T
arrayElementBaseType(::Type{Array{T,N}})       where {T,N} = arrayElementBaseType(T)
arrayElementBaseType(::Type{Union{Missing,T}}) where {T}   = T
arrayElementBaseType(A::Type{<:AbstractArray})             = arrayElementBaseType(eltype(A))


"""
    jsigDict = encodeSignalTableElement(path, signalTableElement; log=false)

Encodes a signal table element suitable to convert to JSON format.
"""
function encodeSignalTableElement(path, element; log=false)
    if isSignal(element)
        if isVar(element)
            jdict = OrderedDict{String,Any}("_class" => "Var")
        elseif isPar(element)
            jdict = OrderedDict{String,Any}("_class" => "Par")
        else
            jdict = OrderedDict{String,Any}("_class" => "Map")
        end
        available = false
        for (key,val) in element
            if key != :_class
                encodedSignal = encodeSignalTableElement(appendNames(path,key),val, log=log)
                if !isnothing(encodedSignal)
                    available = true
                    jdict[string(key)] = encodedSignal
                end
            end
        end
        if available
            return jdict
        else
            return nothing
        end

    else
        elementType = typeof(element)
        if elementType <: AbstractArray && (arrayElementBaseType(elementType) <: Number || arrayElementBaseType(elementType) <: String)
            if ndims(element) == 1 && arrayElementBaseType(elementType) in TypesWithoutEncoding
                return element
            else
                elunit = unitAsParseableString(element)
                if elunit == ""
                    if ndims(element) == 1
                        jdict = OrderedDict{String,Any}("_class" => "Array",
                                                        "eltype" => replace(string(eltype(element)), " " => ""),
                                                        "size"   => Int[i for i in size(element)],
                                                        "values" => element
                                                        )
                    else
                        jdict = OrderedDict{String,Any}("_class" => "Array",
                                                        "eltype" => replace(string(eltype(element)), " " => ""),
                                                        "size"   => Int[i for i in size(element)],
                                                        "layout" => "column-major",
                                                        "values" => reshape(element, length(element))
                                                        )
                    end
                else
                    element = ustrip.(element)
                    jdict = OrderedDict{String,Any}("_class" => "Array",
                                                    "unit"   => elunit,
                                                    "eltype" => replace(string(eltype(element)), " " => ""),
                                                    "size"   => Int[i for i in size(element)],
                                                    "layout" => "column-major",
                                                    "values" => reshape(element, length(element)))
                end
                return jdict
            end

        elseif elementType in TypesWithoutEncoding
            return element

        elseif elementType <: Number
            elunit = unitAsParseableString(element)
            if elunit == ""
                jdict = OrderedDict{String,Any}("_class" => "Number",
                                                "type"   => replace(string(typeof(element)), " " => ""),
                                                "value"  => element)
            else
                element = ustrip.(element)
                jdict = OrderedDict{String,Any}("_class" => "Number",
                                                "unit"   => elunit,
                                                "type"   => replace(string(typeof(element)), " " => ""),
                                                "value"  => element)
            end
            return jdict

        else
            @info "$path::$(typeof(element)) is ignored, because mapping to JSON not known"
            return nothing
        end
    end
end


"""
    json = signalTableToJSON(signalTable; signalNames = nothing)

Returns a JSON string representation of signalTable

If keyword signalNames with a Vector of strings is provided, then a
signal table with the corresponding signals are returned as JSON string.
"""
function signalTableToJSON(signalTable; signalNames = nothing, log=false)::String
    jsignalTable = encodeSignalTable(signalTable; signalNames=signalNames, log=log)
    return JSON.json(jsignalTable)
end


"""
    writeSignalTable(filename::String, signalTable; signalNames=nothing, indent=nothing, log=false)

Write signalTable in JSON format on file `filename`.

If keyword signalNames with a Vector of strings is provided, then a
signal table with the corresponding signals are stored on file.

If indent=<number> is given, then <number> indentation is used (otherwise, compact representation)
"""
function writeSignalTable(filename::String, signalTable; signalNames = nothing, indent=nothing, log=false)::Nothing
    file = joinpath(pwd(), filename)
    if log
        println("  Write signalTable in JSON format on file \"$file\"")
    end
    jsignalTable = encodeSignalTable(signalTable; signalNames=signalNames, log=log)
    open(file, "w") do io
        JSON.print(io, jsignalTable, indent)
    end
    return nothing
end