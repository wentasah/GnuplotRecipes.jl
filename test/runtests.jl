using GnuplotRecipes
using Test
using Gnuplot, DataFrames, Measurements, PNGFiles, ColorTypes, FixedPointNumbers

function compare_plot(name)
    fn = "img/$name.png"
    fn_expected = "img/$name.expect.png"
    fn_diff = "img/$name.diff.png"
    isdir("img") || mkdir("img")
    save(term="pngcairo size 640,360 fontscale 0.8", output=fn)
    cur = PNGFiles.load(fn);
    if isfile(fn_expected)
        exp = PNGFiles.load(fn_expected);
    else
        exp = cur;
        cp(fn, fn_expected)
    end
    if exp != cur
        diff = RGB{N0f8}(1,1,1) .- (RGB{Float16}.(cur) .- RGB{Float16}.(exp) .|> abs .|> RGB{N0f8})
        PNGFiles.save(fn_diff, diff);
    end

    return exp == cur
end

macro gpok(args...)
    gp_call = :(@gp $(esc.(args)...))
    if ! Gnuplot.options.gpviewer
        gp_call = :(display($gp_call))
    end
    return quote
        $gp_call
        compare_plot($("gp_" * join(string.(args))))
    end
end

orig_term = Gnuplot.options.term
if !isinteractive()
    Gnuplot.options.term = "unknown"
end

@testset "GnuplotRecipes.jl" begin
    # Plain numbers
    dfnum = DataFrame(names=["a", "b", "c"], temp=10:12, speed=4:-1:2)
    @test @gpok bars(dfnum)
    # Measurement values
    df = DataFrame(names=["very long label", "b", "c"], temp=10:12, speed=collect(5:-1.5:2) .± 1)
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
    @test @gpok bars(DataFrame(l=[:a, :b], v=[2, 1]))
    # xlabelcol
    @test @gpok bars(DataFrame(v=[2, 1, 0.5], l=[:a, :b, :c]), xlabelcol=2)
    @test @gpok bars(DataFrame(v=[2, 1, 0.5], l=[:a, :b, :c]), xlabelcol=:l)
end

Gnuplot.options.term = orig_term
