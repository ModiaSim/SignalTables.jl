isinstalled(pkg::String) = any(x -> x.name == pkg && x.is_direct_dep, values(Pkg.dependencies()))

const AvailablePlotPackages = ["GLMakie", "WGLMakie", "CairoMakie", "PyPlot", "SilentNoPlot"]
const PlotPackagesStack = String[]


"""
    @usingPlotPackage()

Execute `using XXX`, where `XXX` is the Plot package that was
activated with `usePlotPackage(plotPackage)`.
"""
macro usingPlotPackage()
    if haskey(ENV, "SignalTablesPlotPackage")
        PlotPackage = ENV["SignalTablesPlotPackage"]
        if !(PlotPackage in AvailablePlotPackages)
            @info "ENV[\"SignalTablesPlotPackage\"] = \"$PlotPackage\" is not supported!. Using \"SilentNoPlot\"."
            @goto USE_NO_PLOT
        elseif PlotPackage == "NoPlot"
            @goto USE_NO_PLOT
        elseif PlotPackage == "SilentNoPlot"
            expr = :( using SignalTables.SilentNoPlot )
            return esc( expr )
        else
            PlotPackage = Symbol("SignalTablesInterface_" * PlotPackage)
            expr = :(using $PlotPackage)
            println("$expr")
            return esc( :(using $PlotPackage) )
        end

    elseif haskey(ENV, "MODIA_PLOT_PACKAGE")
        PlotPackage = ENV["MODIA_PLOT_PACKAGE"]
        if !(PlotPackage in AvailablePlotPackages)
            @info "ENV[\"MODIA_PLOT_PACKAGE\"] = \"$PlotPackage\" is not supported!. Using \"SilentNoPlot\"."
            @goto USE_NO_PLOT
        elseif PlotPackage == "NoPlot"
            @goto USE_NO_PLOT
        elseif PlotPackage == "SilentNoPlot"
            expr = :( using SignalTables.SilentNoPlot  )
            return esc( expr )
        else
            PlotPackage = Symbol("SignalTablesInterface_" * PlotPackage)
            expr = :(using $PlotPackage)
            println("$expr")
            return esc( :(using $PlotPackage) )
        end

    else
        @info "No plot package activated. Using \"SilentNoPlot\"."
        @goto USE_NO_PLOT
    end

    @label USE_NO_PLOT
    expr = :( using SignalTables.SilentNoPlot )
    println("$expr")
    return esc( expr )
end


"""
    usePlotPackage(plotPackage::String)

Define the plot package that shall be used by command `@usingPlotPackage`.
If a PlotPackage package is already defined, save it on an internal stack
(can be reactivated with `usePreviousPlotPackage()`.

Possible values for `plotPackage`:
- `"PyPlot"`
- `"GLMakie"`
- `"WGLMakie"`
- `"CairoMakie"`
- `"SilentNoPlot"`

# Example

```julia
using SignalTables
usePlotPackage("GLMakie")

module MyTest
    using SignalTables
    @usingPlotPackage

    t = range(0.0, stop=10.0, length=100)
    result = Dict{String,Any}("time" => t, "phi" => sin.(t))

    plot(result, "phi")  # use GLMakie for the rendering
end
```
"""
function usePlotPackage(plotPackage::String; pushPreviousOnStack=true)::Bool
    success = true
    if plotPackage == "NoPlot" || plotPackage == "SilentNoPlot"
        newPlot = true
        if  pushPreviousOnStack
            if haskey(ENV, "SignalTablesPlotPackage")
                push!(PlotPackagesStack, ENV["SignalTablesPlotPackage"])
            elseif haskey(ENV, "MODIA_PLOT_PACKAGE")
                push!(PlotPackagesStack, ENV["MODIA_PLOT_PACKAGE"])
                newPlot=false
            end
        end
        if plotPackage == "NoPlot"
            if newPlot
                ENV["SignalTablesPlotPackage"] = "NoPlot"
            else
                ENV["MODIA_PLOT_PACKAGE"] = "NoPlot"
            end
        else
            if newPlot
                ENV["SignalTablesPlotPackage"] = "SilentNoPlot"
            else
                ENV["MODIA_PLOT_PACKAGE"] = "SilentNoPlot"
            end
        end
    else
        plotPackageName = "SignalTablesInterface_" * plotPackage
        if plotPackage in AvailablePlotPackages
            # Check that plotPackage is defined in current environment
            if isinstalled(plotPackageName)
                newPlot = true
                if  pushPreviousOnStack
                    if haskey(ENV, "SignalTablesPlotPackage")
                        push!(PlotPackagesStack, ENV["SignalTablesPlotPackage"])
                    elseif haskey(ENV, "MODIA_PLOT_PACKAGE")
                        push!(PlotPackagesStack, ENV["MODIA_PLOT_PACKAGE"])
                        newPlot=false
                    end
                end
                if newPlot
                    ENV["SignalTablesPlotPackage"] = plotPackage
                else
                    ENV["MODIA_PLOT_PACKAGE"] = plotPackage
                end
            else
                @warn "... usePlotPackage(\"$plotPackage\"): Call ignored, since package $plotPackageName is not in your current environment"
                success = false
            end
        else
            @warn "\n... usePlotPackage(\"$plotPackage\"): Call ignored, since argument not in $AvailablePlotPackages."
            success = false
        end
    end
    return success
end



"""
    usePreviousPlotPackage()

Pop the last saved PlotPackage package from an internal stack
and call `usePlotPackage(<popped PlotPackage package>)`.
"""
function usePreviousPlotPackage()::Bool
    if length(PlotPackagesStack) > 0
        plotPackage = pop!(PlotPackagesStack)
        usePlotPackage(plotPackage, pushPreviousOnStack=false)
    end
    return true
end


"""
    currentPlotPackage()

Return the name of the plot package as a string that was
defined with [`usePlotPackage`](@ref).
For example, the function may return "GLMakie", "PyPlot" or "NoPlot" or
or "", if no PlotPackage is defined.
"""
currentPlotPackage() = haskey(ENV, "SignalTablesPlotPackage") ? ENV["SignalTablesPlotPackage"] : 
                      (haskey(ENV, "MODIA_PLOT_PACKAGE")      ? ENV["MODIA_PLOT_PACKAGE"]      : "" )