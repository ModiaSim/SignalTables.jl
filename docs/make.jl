using Documenter, SignalTables, SignalTablesInterface_PyPlot

makedocs(
  sitename = "SignalTables",
  authors  = "Martin Otter (DLR-SR)",
  format = Documenter.HTML(prettyurls = false),
  pages    = [
     "Home"              => "index.md",
     #"Getting Started"  => "GettingStarted.md",
	 "Functions"  => [
       "Functions/OverviewOfFunctions.md",
       "Functions/Signals.md",
       "Functions/SignalTables.md",
       "Functions/PlotPackages.md",
       "Functions/Plots.md",
      ],
	 "Internal"  => [
       "Internal/AbstractSignalTableInterface.md",
       "Internal/AbstractPlotInterface.md",
     #  "internal/UtilityFunctions.md"
      ],
  ]
)

