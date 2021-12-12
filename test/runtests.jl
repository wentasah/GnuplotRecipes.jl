using GnuplotRecipes
using Test
using Gnuplot, DataFrames, Measurements

if Gnuplot.options.gpviewer
    macro gpok(args...) :( @gp $(esc.(args)...); true ) end
else
    macro gpok(args...) :( display(@gp $(esc.(args)...)); true ) end
end

@testset "GnuplotRecipes.jl" begin
    # Plain numbers
    df = DataFrame(names=["a", "b", "c"], temp=10:12, speed=4:-1:2)
    @test @gpok bars(df)
    # Measurement values
    df = DataFrame(names=["very long label", "b", "c"], temp=10:12, speed=collect(4:-3:-2) .± 1)
    @test @gpok bars(df)
    @test @gpok bars(df, errorbars="lw 5 lc rgb '#ff0000'")
    @test @gpok bars(df, fill_style="pattern 1")
    @test @gpok bars(df, gap=2)
    @test @gpok bars(df, box_width=1)
    @test @gpok bars(df, label_rot=0)
    @test @gpok bars(df, label_rot=90) # visually check that labels are top-aligned
    @test @gpok bars(df, y2cols=[:speed])
    @test @gpok bars(df, y2cols=[:speed, :temp])
    @test @gpok bars(df, hist_style = "rowstacked")
    @test_logs (:warn, r"columnstacked") @gp bars(df, hist_style = "columnstacked")
    @test_throws AssertionError @gp bars(df, y2cols=[:bad])
    # Symbols as lables
    @test @gpok bars(DataFrame(l=[:a, :b], v=[1, 2]))
end
