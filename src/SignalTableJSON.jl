
"""
    json = signalTableToJSON(signalTable)::String

Returns a signal table as JSON string.
"""
function signalTableToJSON(signalTable)
    return JSON.json(signalTable, 2)
end


"""
    writeSignalTable(filename::String, signalTable; log=true)
    
Writes a signal Table in JSON format on file.
"""
function writeSignalTable(filename::String, signalTable::AbstractDict; log=true) 
    if log
        path = joinpath(pwd(), filename)
        println("  Write signalTable in JSON format on file \"$path\"")
    end
    write(filename, signalTableToJSON(signalTable))
end