using Documenter, RegionTrees

makedocs(
  warnonly=[:missing_docs, :cross_references],
  format=Documenter.HTML(prettyurls=get(ENV, "CI", "false") == "true"),
  sitename="RegionTrees.jl",
  authors="Tamás Cserteg and contributors",
  pages=[
    "Home" => "index.md",
    "Examples" => [
      "Demo" => "demo.md",
      "Adaptive Distance Fields" => "adaptive-distances.md",
    ],
    "Index" => "links.md"
  ]
)

deploydocs(
  repo="github.com/JuliaGeometry/RegionTrees.jl",
)
