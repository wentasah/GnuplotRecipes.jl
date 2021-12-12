module GnuplotRecipes

using Gnuplot, Tables, Measurements

export bars

"Helper function returning the number of columns in the table."
ncol(table) = length(Tables.columnnames(table))

"Helper function returning the number of rows in the table."
nrow(table) = Tables.rowcount(table)

"""
    bars(table; kwargs...)::Vector{Gnuplot.PlotElement}

Explicit recipe to plot bar graphs from tabular data.
`Measurement`-type data are plot with errorbars style.

# Arguments

- `table`: data to plot. The first column should contains text labels,
  the other columns the plotted values. If the values are of
  `Measurement` type, they will be plotted with errorbars style,
  unless overridden with `hist_style`.
- `box_width=0.8`: the width of the boxes. One means that the boxes
  touch each other.
- `gap::Union{Int64,Nothing}=nothing`: The gap between bar clusters.
  If `nothing`, it is set automatically depending on the number of
  bars in the cluster; to zero for one bar in the cluster, to 1 for
  multiple bars.
- `hist_style=nothing`: histogram style — see Gnuplot documentation.
- `fill_style="solid 1 border -1"`: fill style — see Gnuplot documentation.
- `errorbars=""`: errorbars style — see Gnuplot documentation.
- `label_rot=-30`: label rotation angle; if > 0, align label to right.
- `label_enhanced=false`: whether to apply Gnuplot enhanced formatting to labels.
- `key_enhanced=false`: whether to apply Gnuplot enhanced formatting to data keys.
- `y2cols=[]`: Columns (specified as symbols) which should be plot against *y2* axis.
- `linetypes=1:ncol(table)-1`: Line types (colors) used for different bars

# Example

```jldoctest
julia> using Measurements, Gnuplot, DataFrames

julia> table = DataFrame(names=["very long label", "b", "c"],
                         temp=10:12,
                         speed=collect(4:-1:2) .± 1)
3×3 DataFrame
 Row │ names            temp   speed
     │ String           Int64  Measurem…
─────┼───────────────────────────────────
   1 │ very long label     10    4.0±1.0
   2 │ b                   11    3.0±1.0
   3 │ c                   12    2.0±1.0

julia> @gp bars(table)

```
"""
function bars(table;
              box_width = 0.8,
              gap::Union{Int64,Nothing} = nothing,
              hist_style = nothing,
              fill_style = "solid 1 border -1",
              errorbars = "",
              label_rot = -30,
              label_enhanced = false,
              key_enhanced = false,
              y2cols = [],
              linetypes = 1:ncol(table)-1,
              )::Vector{Gnuplot.PlotElement}
    nr = nrow(table)

    foreach(y2cols) do col
        @assert col in propertynames(table)
    end

    axes(i) = (propertynames(table)[i] in y2cols) ? "axes x1y2 " : ""

    if hist_style === nothing
        hist_style = (any(map(eltype.(Tables.columns(table))) do type type <: Measurement end)
                      ? "errorbars" : "clustered")
    end
    eb = hist_style == "errorbars"

    if gap === nothing
        gap = ncol(table) == 2 ? 0 : 1
    end
    gap_str = (hist_style ∈ ["clustered", "errorbars"]) ? "gap $gap" : ""
    hist_style == "columnstacked" && @warn "columnstacked is not well supported"

    function gpusing(i)
        cols = [i, "xticlabels(1)"]
        eb && insert!(cols, 2, i+ncol(table)-1)
        join(cols, ":")
    end

    data=Gnuplot.DatasetText(
        String.(Tables.columns(table)[1]), # labels
        [Measurements.value.(Tables.columns(table)[i]) for i in 2:ncol(table)]...,
        [eltype(Tables.columns(table)[i]) <: Measurement ?
            Measurements.uncertainty.(Tables.columns(table)[i]) :
            fill(0.0, nr)
         for i in 2:ncol(table) if eb]...,
    )
    vcat(
        Gnuplot.PlotElement(
            xr=[-0.5, nr - 0.5],
            cmds=vcat(["set grid ytics y2tics",
                       "set style data histogram",
                       "set style histogram $hist_style $gap_str",
                       "set boxwidth $box_width",
                       "set style fill $fill_style",
                       """set xtics rotate by $label_rot $(label_rot > 0 ? "right" : "") $(label_enhanced ? "" : "no")enhanced""",
                       ],
                      !isempty(errorbars) ? ["set errorbars $errorbars"] : String[],
                      !isempty(y2cols) ? ["set ytics nomirror", "set y2tics"] : String[],
                      ),
        ),
        [
            Gnuplot.PlotElement(
                data=data,
                plot="using $(gpusing(i)) $(axes(i))" *
                """title '$(names(table, i)[1])' $(key_enhanced ? "" : "no")enhanced lt $(linetypes[i-1])""",
            )
            for i in 2:ncol(table)
        ]...
    )
end

end
