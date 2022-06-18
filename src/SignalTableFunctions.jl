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
    showInfo([io::IO=stdout,] signalTable;
             sorted=false, Var=true, Par=true, attributes=true)

Writes info about signalTable to the output stream `io`.

The independent signal is always printed first. Otherwise, ordering is according
to signalTable (if sorted=false) or signals are sorted.

The other keyword arguments define what information shall be printed.

# Example

```julia
using SignalTables

include("$(SignalTables.path)/test/signalTables.jl")

signalInfo(sigTable1, attributes=true)
```

results in the following output

```julia
#
name        unit      size      eltype                  kind   info
─────────────────────────────────────────────────────────────────────────
time        s         (208,)    Float64                 Indep.
load.f      N         (208, 3)  Vector{Float64}         Const.
load.phi    rad       (208,)    Float64                 Depen.
load.r_abs  m         (208, 3)  Float64                
load.w      rad*s^-1  (208,)    Union{Missing,Float64}             
motor.J     kg*m^2    (208,)    Float64                 Const.
motor.b               (208,)    Bool                   
motor.data            (208,)    MotorStruct             Const.
motor.phi   rad       (208,)    Float64                 
motor.w_m   rad/s     (208,)    Union{Missing,Float64}         Clocked
reference             (208,)    String                  Const.
```
"""
function showInfo(io::IO, signalTable; 
                  sorted=false, Var=true, Par=true, attributes=true)::Nothing
    if isnothing(signalTable)
        @info "The call of showInfo(signalTable) is ignored, since the argument is nothing."
        return
    end

    name2   = String[]
    unit2   = String[]
    size2   = String[]
    eltype2 = String[]
    kind2   = String[]
    attr2   = String[]
  
    sigNames = signalNames(signalTable)
    if sorted
        sigNames = sort(sigNames)
    end
    if attributes
        iostr = IOBuffer()
    end
    
    for name in sigNames
        sigInfo = signalInfo(signalTable, name)
        kind    = isVar(sigInfo) ? "Var" : "Par"

        if Var && kind == "Var" || Par && kind == "Par"
            if attributes
                first = true
                for (key,val) in sigInfo
                    if !(key == :unit || key == :type || key == :size || key == :_class)
                        if first
                            first = false
                        else
                            print(iostr, ", ")
                        end
                        print(iostr, key, "=")
                        show(iostr, val)
                    end
                end
                attr = String(take!(iostr))
            end
            independent = get(sigInfo, :independent, false)
            valType     = get(sigInfo, :type, nothing) 
            valElType   = isnothing(valType) ? "" : string(eltype(valType))
            valSize     = string( get(sigInfo, :size, "") )
            if independent
                pushfirst!(name2  , name)
                pushfirst!(unit2  , get(sigInfo, :unit, ""))
                pushfirst!(size2  , valSize)
                pushfirst!(eltype2, valElType)
                pushfirst!(kind2  , kind)
                if attributes
                    pushfirst!(attr2, attr)
                end
            else
                push!(name2  , name)
                push!(unit2  , get(sigInfo, :unit, ""))
                push!(size2  , valSize)
                push!(eltype2, valElType)
                push!(kind2  , kind)
                if attributes
                    push!(attr2, attr)
                end       
            end
        end
    end
    
    if attributes
        infoTable = DataFrames.DataFrame(name=name2, unit=unit2, size=size2, eltype=eltype2, kind=kind2, attributes=attr2)
    else
        infoTable = DataFrames.DataFrame(name=name2, unit=unit2, size=size2, eltype=eltype2, kind=kind2)
    end

    show(io, infoTable, show_row_number=false, summary=false, allcols=true, eltypes=false, truncate=50) # rowlabel=Symbol("#")
    println(io)
    return nothing
end
showInfo(signalTable; kwargs...) = showInfo(stdout, signalTable; kwargs...)
                  

#=
const TypesForPlotting = [Float64, Float32, Int]

nameWithUnit(name::String, unit::String) = unit == "" ? name : string(name, " [", unit, "]")


"""
    (sig, legend, kind) = signalValuesForLinePlots(signalTable, name)

Given the signalTable data structure `signalTable` and a variable `name::AbstractString` with
or without array range indices (for example `name = "a.b.c[2,3:5]"`) 
return the values `sig::Union{AbstractVector,AbstractMatrix}` of `name` without units prepared for a plot package,
including `legend::Vector{String}` and `kind::ModiaResult.VariableKind`.

If `name` is not valid, or no signal values are available, or the signal values
are not suited for plotting (and cannot be converted to Float64), a warning message
is printed and `(nothing, nothing, nothing)` is returned.

# Return arguments

- `sig::AbstractVector` or `::AbstractMatrix`:
  For example, if `name = "a.b.c[2,3:5]"`, then
  `sig` consists of a matrix with three columns corresponding to the variable values of
  `"a.b.c[2,3]", "a.b.c[2,4]", "a.b.c[2,5]"` with the (potential) units are stripped off.
  `missing` values in the signal are replaced by `NaN`. If necessary, 
  the signal is converted to `Float64`.

- `legend::Vector{AbstractString}`: The legend of the signal as a vector
  of strings, where `legend[1]` is the legend for `sig`, if `sig` is a vector,
  and `legend[i]` is the legend for the i-th column of `sig`, if `sig` is a matrix.
  For example, if variable `"a.b.c"` has unit `m/s`, then `sigName = "a.b.c[2,3:5]"` signalTables in
  `legend = ["a.b.c[2,3] [m/s]", "a.b.c[2,3] [m/s]", "a.b.c[2,5] [m/s]"]`.
  
- `kind::`[`ModiaResult.VariableKind`](@ref): The variable kind (independent, constant, continuous, ...).
"""
function signalValuesForLinePlots(signalTable, name::String)
    sigPresent = false
    negate     = false
    
    if hasSignal(signalTable,name)
        # name is a signal name without range  
        sigInfo = SignalInfo(signalTable,name)  
        sigKind = sigInfo.kind
        if sigKind == ModiaResult.Eliminated
            sigInfo = SignalInfo(signalTable,sigInfo.aliasName)
            negate  = sigInfo.aliasNegate
            sigKind = sigInfo.kind            
        end
        sig     = signalValues(signalTable,name; unitless=true)
        dims    = size(sig)
        if dims[1] > 0
            sigPresent = true    
            if length(dims) > 2
                # Reshape to a matrix
                sig = reshape(sig, dims[1], prod(dims[i] for i=2:length(dims)))
            end      
            
            # Collect information for legend
            arrayName = name  
            sigUnit   = sigInfo.unit             
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
                    sigInfo = SignalInfo(signalTable,arrayName)
                    sigKind = sigInfo.kind
                    if sigKind == ModiaResult.Eliminated
                        sigInfo = SignalInfo(signalTable,sigInfo.aliasName)
                        negate  = sigInfo.aliasNegate
                        sigKind = sigInfo.kind
                    end                    
                    sig  = signalValues(signalTable,arrayName; unitless=true)
                    dims = size(sig)
 
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
                        sig     = getindex(sig, (:, arrayIndices...)...)
                        sigUnit = sigInfo.unit                         
                        dims    = size(sig)
                        nScalarSignals = length(dims) == 1 ? 1 : prod(i for i in dims[2:end])
                        if length(dims) > 2
                            # Reshape to a matrix
                            sig  = reshape(sig, dims[1], nScalarSignals)
                        end   
                    end
                end
            end
        end
    end
    if !sigPresent
        @goto ERROR
    end
    
    # Check that sig can be plotted or convert it, so that it can be plotted
    sigElType = sigInfo.elementType
    if sigElType in TypesForPlotting ||
       (sigElType <: Measurements.Measurement && BaseType(sigElType) in TypesForPlotting) ||
       (sigElType <: MonteCarloMeasurements.AbstractParticles && BaseType(sigElType) in TypesForPlotting)
        # Signal can be plotted - do nothing
    
    elseif sigElType <: Bool
        # Transform to Int
        sig2 = Array{Int, ndims(sig)}(undef, size(sig))       
        for i = 1:length(sig)
            sig2[i] = convert(Int, sig[i])
        end
        sig2 = sig
    
    elseif isa(missing, sigElType) || isa(nothing, sigElType)
        # sig contains missing or nothing - try to remove and if necessary convert to Float64
        canBePlottedWithoutConversion = false
        for T in TypesForPlotting
            if isa(T(0), sigElType)
                canBePlottedWithoutConversion = true
                break
            end
        end
        
        if canBePlottedWithoutConversion
            # Remove missing and nothing
            sigNaN = convert(sigElType, NaN)
            for i = 1:length(sig)
                if ismissing(sig[i]) || isnothing(sig[i])
                    sig[i] = sigNaN
                end
            end

        else
            # Convert to Float64 if possible and remove missing and nothing
            sig2 = similar(sig, element_type=Float64)            
            try
                for i = 1:length(sig)
                    sig2[i] = ismissing(sig[i]) || isnothing(sig[i]) ? NaN : convert(Float64, sig[i])
                end
            catch
                # Cannot be plotted
                @warn "Signal \"$name\" is ignored, because its element type = $sigElType\nand therefore its values cannot be plotted."
                return (nothing,nothing,nothing)
            end
            sig = sig2
        end

    else
        # Convert to Float64 if possible 
        sig2 = Array{Float64, ndims(sig)}(undef, size(sig))       
        try
            for i = 1:length(sig)
                sig2[i] = convert(Float64, sig[i])
            end
        catch
            # Cannot be plotted
            @warn "Signal \"$name\" is ignored, because its element type = $sigElType\nand therefore its values cannot be plotted."
            return (nothing,nothing,nothing)
        end
        sig = sig2
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

    if negate
        sig = -sig
    end
    
    return (collect(sig), legend, sigKind)
    
    @label ERROR
    @warn "\"$name\" is ignored, because it is not defined or is not correct or has no values."
    return (nothing,nothing,nothing)
end


"""
    getHeading(signalTable, heading)

Return `heading` if no empty string. Otherwise, return `defaultHeading(signalTable)`.
"""
getHeading(signalTable, heading::AbstractString) = heading != "" ? heading : defaultHeading(signalTable)


"""
    prepend!(prefix, signalLegend)

Add `prefix` string in front of every element of the `signalLegend` string-Vector.
"""
function prepend!(prefix::AbstractString, signalLegend::Vector{AbstractString})
   for i in eachindex(signalLegend)
      signalLegend[i] = prefix*signalLegend[i]
   end
   return signalLegend
end
=#