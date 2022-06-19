using Documenter, SignalTables, ModiaPlot_PyPlot

makedocs(
  sitename = "SignalTables",
  authors  = "Martin Otter (DLR-SR)",
  format = Documenter.HTML(prettyurls = false),
  pages    = [
     "Home"              => "index.md",
     #"Getting Started"  => "GettingStarted.md",
	 "Functions"  => [
       "Functions/Overview.md",
       "Functions/SignalTables.md",  
       "Functions/PlotPackages.md",    
       "Functions/LinePlots.md",                  
      ],     
	 "Internal"  => [
       "Internal/AbstractSignalTableInterface.md",
       "Internal/AbstractLinePlotInterface.md",       
     #  "internal/UtilityFunctions.md"       
      ],
  ]
)

