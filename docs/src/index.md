```@meta
CurrentModule = GnuplotRecipes
```

# GnuplotRecipes

Documentation for [GnuplotRecipes](https://github.com/wentasah/GnuplotRecipes.jl).

```@index
```

```@setup abc
using GnuplotRecipes, Gnuplot
Gnuplot.quitall()
mkpath("assets")
Gnuplot.options.term = "unknown"
Gnuplot.options.mime[MIME"text/html"] = "svg size 600,300 dynamic enhanced standalone fontscale 0.9"
empty!(Gnuplot.options.init)
push!( Gnuplot.options.init, linetypes(:Set1_8, lw=1.5, ps=1.5))
saveas(file) = save(term="pngcairo size 550,350 fontscale 0.8", output="assets/$(file).png")
```

```@example abc
using Measurements, DataFrames
table = DataFrame(names=["very long label", "b", "c"],
                  before=[10, 11, 13],
                  after=collect(4:-1:2) .± 1)
@gp bars(table) "set key left reverse Left"
```

```@autodocs
Modules = [GnuplotRecipes]
```
