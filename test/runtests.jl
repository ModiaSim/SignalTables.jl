module Runtests

using SignalTables
using Test

@testset "Test SignalTables.jl" begin
    include("include_all.jl")
end
end
