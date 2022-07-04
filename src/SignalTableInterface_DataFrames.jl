# Signal table interface for DataFrames

isSignalTable(            obj::DataFrames.DataFrame) = true
getIndependentSignalNames(   obj::DataFrames.DataFrame) = DataFrames.names(obj, 1)[1]
getIndependentSignalsSize(obj::DataFrames.DataFrame) = [size(obj,1)]
getSignalNames(obj::DataFrames.DataFrame)               = DataFrames.names(obj)
getSignal(  obj::DataFrames.DataFrame, name::String) = Var(values = obj[!,name])
hasSignal(  obj::DataFrames.DataFrame, name::String) = haskey(obj, name)


"""
    df = signalTableToDataFrame(signalTable)
    
Returns a signal table as [DataFrame](https://github.com/JuliaData/DataFrames.jl) object.     
"""
function signalTableToDataFrame(sigTable)::DataFrames.DataFrame
    names = getSignalNames(sigTable)
    name = names[1]
    df = DataFrames.DataFrame(name = getSignal(sigTable,name)[:values])
    for i in 2:length(names)
        name = names[i]
        sig  = getSignal(sigTable,name)
        if isVar(sig)
            sigValues = sig[:values]
            if typeof(sigValues) <: AbstractVector
                df[!,name] = sig[:values]
            else
                @info "$name::$(typeof(sigValues)) is ignored, because no Vector"
            end
        elseif isPar(sig)
            @info "$name is ignored, because Par(..) signal."
        else            
            @info "$name::$(typeof(sig)) is ignored, because no Var(..) signal"
        end
    end
    return df
end


