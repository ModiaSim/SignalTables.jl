using Documenter, SignalTables  #, ModiaPlot_PyPlot

makedocs(
  sitename = "SignalTables",
  authors  = "Martin Otter (DLR-SR)",
  format = Documenter.HTML(prettyurls = false),
  pages    = [
     "Home"               => "index.md",
     #"Getting Started"    => "GettingStarted.md",     
	 #"Functions"          => "Functions.md",
	 #"Internal"  => [
     #  "internal/AbstractResultInterface.md",
     #  "internal/AbstractLinePlotInterface.md",       
     #  "internal/UtilityFunctions.md"       
      ],
)

