# License for this file: MIT (expat)
# Copyright 2020-2022, DLR Institute of System Dynamics and Control
#
# This file is part of module SignalTables (is included by the SignalTablesInterface_XXMakie packages).
   
export plot, showFigure, saveFigure, closeFigure, closeAllFigures


#--------------------------- Utility definitions
             
# color definitions
const colors = ["blue1",
                "green4",
                "red1",
                "cyan1",
                "purple1",
                "orange1",
                "black",
                "blue2",
                "green3",
                "red2",
                "cyan2",
                "purple2",
                "orange2",
                "grey20",
                "blue3",
                "green2",
                "red3",
                "cyan3",
                "purple3",
                "orange3",
                "grey30",
                "blue4",
                "green1",
                "red4",
                "cyan4",
                "purple4",
                "orange4",
                "grey40"]    


mutable struct Diagram
    fig
    axis
    row::Int
    col::Int
    curves::Union{AbstractVector, Nothing}
    yLegend::Union{AbstractVector, Nothing}
    
    function Diagram(fig,row,col,title) 
        axis = fig[row,col] = Axis(fig, title=title)
        new(fig, axis, row, col, nothing, nothing) 
    end
end


# figures[i] is Figure instance of figureNumber = i
const figures = Dict{Int,Any}()   # Dictionary of MatrixFigures


mutable struct MatrixFigure
    fig
    resolution
    diagrams::Union{Matrix{Diagram},Nothing}
    
    function MatrixFigure(figureNumber::Int, nrow::Int, ncol::Int, reuse::Bool, resolution)
        if haskey(figures, figureNumber) && reuse
            # Reuse existing figure
            matrixFigure = figures[figureNumber]
            if isnothing(matrixFigure.diagrams) || size(matrixFigure.diagrams) != (nrow,ncol)
                error("From ModiaPlot.plot: reuse=true, but figure=$figureNumber has not $nrow rows and $ncol columns.")    
            end 
        else
            # Create a new figure
            fig = Figure(resolution=resolution)
            diagrams = Matrix{Diagram}(undef,nrow,ncol)  
            matrixFigure = new(fig, resolution, diagrams)
            figures[figureNumber] = matrixFigure             
        end 
        return matrixFigure
    end
end
                        
getMatrixFigure(figureNumber::Int) = figures[figureNumber]


setTheme() = set_theme!(fontsize = 12)




"""
    getColor(i::Int)
    
Return color, given an integer (from colors)
"""
function getColor(i::Int) 
    j = mod(i, length(colors))
    if j == 0
        j = length(colors)
    end
    return colors[j]
end
    


"""
    createLegend(diagram::Diagram, maxLegend)
    
Create a new legend in diagram
"""
function createLegend(diagram::Diagram, maxLegend::Int)::Nothing
    curves  = diagram.curves
    yLegend = diagram.yLegend
    if length(curves) > 1
        nc = min(length(curves), maxLegend)
        curves  = curves[1:nc]
        yLegend = yLegend[1:nc]
    end

    fig  = diagram.fig
    i    = diagram.row
    j    = diagram.col   
    fig[i,j] = Legend(fig, curves, yLegend,
                              margin=[0,0,0,0], padding=[5,5,0,0], rowgap=0, halign=:right, valign=:top, 
                              linewidth=1, labelsize=10, tellheight=false, tellwidth=false)
    return nothing
end


const reltol = 0.001

function sig_max(xsig, y_min, y_max)
    dy = y_max - y_min
    abstol = typemax(eltype(y_min))
    for (i,v) in enumerate(dy)
        if v > 0.0 && v < abstol
            abstol = v
        end
    end    
    @assert(abstol > 0.0)
    y_max2 = similar(y_max)
    for (i,value) = enumerate(y_max)
        y_max2[i] = max(y_max[i], y_min[i] + max(abstol, abs(y_min[i])*reltol))
    end
    return y_max2
end
    
# Something of the following is required in the file where makie.jl is included:
#   const Makie_Point2f = isdefined(GLMakie, :Point2f) ? Point2f : Point2f0     
function fill_between(axis, xsig, ysig_min, ysig_max, color)
    ysig_max2 = sig_max(xsig, ysig_min, ysig_max) 
    sig = Makie_Point2f.(xsig,ysig_min)
    append!(sig, reverse(Makie_Point2f.(xsig,ysig_max2)))
    push!(sig, sig[1])
    return poly!(axis, sig, color = color)  
end
    

function plotOneSignal(axis, xsig, ysig, color, ysigType, MonteCarloAsArea)
	if typeof(ysig[1]) <: Measurements.Measurement
		# Plot mean value signal
		xsig_mean = Measurements.value.(xsig)
		ysig_mean = Measurements.value.(ysig)
        curve = lines!(axis, xsig_mean, ysig_mean, color=color)

		# Plot area of uncertainty around mean value signal (use the same color, but transparent)
		ysig_u   = Measurements.uncertainty.(ysig)
		ysig_max = ysig_mean + ysig_u
		ysig_min = ysig_mean - ysig_u        
		fill_between(axis, xsig_mean, ysig_min, ysig_max, (color,0.2))
        
	elseif typeof(ysig[1]) <: MonteCarloMeasurements.StaticParticles ||
           typeof(ysig[1]) <: MonteCarloMeasurements.Particles
        # Plot mean value signal   
        pfunctionsDefined = isdefined(MonteCarloMeasurements, :pmean) 
        if pfunctionsDefined
            # MonteCarlMeasurements, version >= 1.0
            xsig_mean = MonteCarloMeasurements.pmean.(xsig)
            ysig_mean = MonteCarloMeasurements.pmean.(ysig)
        else
            # MonteCarloMeasurements, version < 1.0
            xsig_mean = MonteCarloMeasurements.mean.(xsig)
            ysig_mean = MonteCarloMeasurements.mean.(ysig)            
        end
        xsig_mean = ustrip.(xsig_mean)
        ysig_mean = ustrip.(ysig_mean)     
        curve = lines!(axis, xsig_mean, ysig_mean, color=color)  
        
        if MonteCarloAsArea
            # Plot area of uncertainty around mean value signal (use the same color, but transparent)
            if pfunctionsDefined
                # MonteCarlMeasurements, version >= 1.0          
                ysig_max = MonteCarloMeasurements.pmaximum.(ysig)
                ysig_min = MonteCarloMeasurements.pminimum.(ysig)
            else
                # MonteCarloMeasurements, version < 1.0
                ysig_max = MonteCarloMeasurements.maximum.(ysig)
                ysig_min = MonteCarloMeasurements.minimum.(ysig)                
            end            
            ysig_max = ustrip.(ysig_max)
            ysig_min = ustrip.(ysig_min)   
            fill_between(axis, xsig_mean, ysig_min, ysig_max, (color,0.2))
            
        else
            # Plot all particle signals
            value  = ysig[1].particles
            ysig3  = zeros(eltype(value), length(xsig))       
            for j in 1:length(value) 
                for i in eachindex(ysig)
                    ysig3[i] = ysig[i].particles[j] 
                end
                ysig3 = ustrip.(ysig3)                 
                lines!(axis, xsig, ysig3, color=(color,0.1))
            end
        end
        
	else
        if typeof(xsig[1]) <: Measurements.Measurement
            xsig = Measurements.value.(xsig)
        elseif typeof(xsig[1]) <: MonteCarloMeasurements.StaticParticles ||
               typeof(xsig[1]) <: MonteCarloMeasurements.Particles
            if isdefined(MonteCarloMeasurements, :pmean) 
                # MonteCarlMeasurements, version >= 1.0 
                xsig = MonteCarloMeasurements.pmean.(xsig)                
            else
                # MonteCarlMeasurements, version < 1.0              
                xsig = MonteCarloMeasurements.mean.(xsig)
            end
            xsig = ustrip.(xsig)
        end
  
        if ysigType == SignalTables.Continuous
            curve = lines!(axis, xsig, ysig, color=color)     
        else
            curve = scatter!(axis, xsig, ysig, color=color, markersize = 5.0)
        end            
	end
    return curve
end


function addPlot(names::Tuple, diagram::Diagram, result, grid::Bool, xLabel::Bool, xAxis, 
                 prefix::AbstractString, reuse::Bool, maxLegend::Integer, MonteCarloAsArea::Bool)
    xsigLegend = ""
    yLegend = String[]
    curves  = Any[]

    i0 = isnothing(diagram.curves) ? 0 : length(diagram.curves)
    
    for name in names
        name2 = string(name)
        (xsig, xsigLegend, ysig, ysigLegend, ysigType) = SignalTables.getPlotSignal(result, name2; xsigName = xAxis)
        if !isnothing(xsig)
            if ndims(ysig) == 1
                push!(yLegend, prefix*ysigLegend[1])
                push!(curves, plotOneSignal(diagram.axis, xsig, ysig, getColor(i0+1), ysigType, MonteCarloAsArea))  
                i0 = i0 + 1
            else
                for i = 1:size(ysig,2)
                    curve = plotOneSignal(diagram.axis, xsig, ysig[:,i], getColor(i0+i), ysigType, MonteCarloAsArea) 
                    push!(yLegend, prefix*ysigLegend[i])
                    push!(curves, curve) 
                end
                i0 = i0 + size(ysig,2)
            end
        end
    end

    #PyPlot.grid(grid)

    if reuse
        diagram.curves  = append!(diagram.curves, curves)
        diagram.yLegend = append!(diagram.yLegend, yLegend)
    else
        diagram.curves  = curves
        diagram.yLegend = yLegend
    end  
    
    createLegend(diagram, maxLegend)

    if xLabel && !reuse && xsigLegend !== nothing
        diagram.axis.xlabel = xsigLegend
    end
end

addPlot(name::AbstractString, args...) = addPlot((name,)        , args...)
addPlot(name::Symbol        , args...) = addPlot((string(name),), args...)


#--------------------------- Plot function

function plot(result, names::AbstractMatrix; heading::AbstractString="", grid::Bool=true, xAxis=nothing, 
              figure::Int=1, prefix::AbstractString="", reuse::Bool=false, maxLegend::Integer=10, 
              minXaxisTickLabels::Bool=false, MonteCarloAsArea=false)
    if isnothing(result)
        @info "The call of ModiaPlot.plot(result, ...) is ignored, since the first argument is nothing."
        return
    end
    if !reusePossible
        reuse=false
    end
              
    # Plot a vector or matrix of diagrams
    setTheme() 
    (nrow, ncol)  = size(names)
    matrixFigure  = MatrixFigure(figure, nrow, ncol, reuse, (min(ncol*600,1500), min(nrow*350, 900))) 
    fig           = matrixFigure.fig
    xAxis2        = isnothing(xAxis) ? xAxis : string(xAxis)    
    heading2      = SignalTables.getHeading(result, heading)
    hasTopHeading = !reuse && ncol > 1 && heading2 != ""
    
    # Add diagrams
    lastRow = true
    xLabel  = true    
    for i = 1:nrow
        lastRow = i == nrow
        for j = 1:ncol
            if reuse
                diagram = matrixFigure.diagrams[i,j]
            else
                if ncol == 1 && i == 1 && !hasTopHeading
                    diagram = Diagram(fig, i, j, heading2)
                else                              
                    diagram = Diagram(fig, i, j, "")
                end
                matrixFigure.diagrams[i,j] = diagram
            end
            xLabel = !( minXaxisTickLabels && !lastRow )        
            addPlot(names[i,j], diagram, result, grid, xLabel, xAxis2, prefix, reuse, maxLegend, MonteCarloAsArea)
        end
    end
    
    # Add overall heading in case of a matrix of diagrams (ncol > 1) and add a figure label on the top level
    if hasTopHeading
        fig[0,:] = Label(fig, heading2, fontsize = 14)
    end  
    if showFigureStringInDiagram
        figText = fig[1,1,TopLeft()] = Label(fig, "showFigure(" * string(figure) * ")", fontsize=9, color=:blue, halign = :left)    
        if hasTopHeading
            figText.padding = (0, 0, 5, 0)    
        else
            figText.padding = (0, 0, 30, 0)
        end
    end
    
    # Update and display fig
    trim!(fig.layout)   
    #update!(fig.scene)
    if callDisplayFunction
        display(fig)
    end        
    return matrixFigure
end
