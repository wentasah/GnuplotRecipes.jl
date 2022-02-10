using GnuplotRecipes
using Documenter

DocMeta.setdocmeta!(GnuplotRecipes, :DocTestSetup, :(using GnuplotRecipes, Gnuplot); recursive=true)

makedocs(;
    modules=[GnuplotRecipes],
    authors="Michal Sojka <michal.sojka@cvut.cz> and contributors",
    repo="https://github.com/wentasah/GnuplotRecipes.jl/blob/{commit}{path}#{line}",
    sitename="GnuplotRecipes.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://wentasah.github.io/GnuplotRecipes.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/wentasah/GnuplotRecipes.jl",
    devbranch="main",
)
