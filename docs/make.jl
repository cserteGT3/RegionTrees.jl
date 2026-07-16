using Documenter, RegionTrees

makedocs(
    warnonly = [:missing_docs, :cross_references],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", "false") == "true",
        size_threshold = 1_500_000,  # because of the embedded mpc.html
        size_threshold_warn = 1_500_000,
        search_size_threshold_warn = 1_500_000
    ),
    sitename = "RegionTrees.jl",
    authors = "Tamás Cserteg and contributors",
    pages = [
        "Home" => "index.md",
        "Examples" => [
            "Demo" => "demo.md",
            "Adaptive Distance Fields" => "adaptive-distances.md",
            "Adaptive MPC" => "mpc.md",
        ],
        "Index" => "links.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaGeometry/RegionTrees.jl",
)
