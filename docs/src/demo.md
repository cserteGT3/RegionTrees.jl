# Demo

```@repl demo
using RegionTrees
using StaticArrays: SVector
using Plots
nothing # hide
```

The most basic data type in this package is a `Cell`, which can represent a
node or a leaf in the tree. Let's build a `Cell` which spans from `[0, 0]` and
has length 1 along each axis:

```@repl demo
root = Cell(SVector(0., 0), SVector(1., 1))
```

The `Cell` type is used for leaves and nodes. We can check if `root` is a leaf
with `isleaf()`:

```@repl demo
isleaf(root)
```

Now let's refine the cell:

```@repl demo
split!(root)
```

The cell is no longer a leaf because it now has children:

```@repl demo
isleaf(root)
```

```@repl demo
@assert length(children(root)) == 4
```

Each child now represents one quarter of the region spanned by `root`. We can
access children using the indexing notation:

```@repl demo
root[1,1]
```

or with the `children()` function:

```@repl demo
children(root)[1,1]
```

We can further refine one of the children:

```@repl demo
split!(root[1,1])
```

Now there are more children:

```@repl demo
root[1,1][1,1]
```

```@repl demo
root[1,1][1,2]
```

Let's plot the cells we have so far:

```@repl demo
plt = plot(xlim=(0, 1), ylim=(0, 1), legend=nothing)
for leaf in allleaves(root)
    v = hcat(collect(vertices(leaf.boundary))...)
    plot!(plt, v[1,[1,2,4,3,1]], v[2,[1,2,4,3,1]])
end
savefig("cell-1.svg"); nothing # hide
```

![](cell-1.svg)

Now, so far just splitting cells is not super useful. Let's try adding some data to each cell:

```@repl demo
cell = Cell(SVector(0., 0), SVector(1., 1), "A")
```

We now have a new cell, with a data payload consisting of a string:

```@repl demo
cell.data
```

The type of the data payload (`String`) is now part of the cell's type, which
lets Julia efficiently handle our cell:

```@repl demo
typeof(cell)
```

By default, `split!(cell)` just copies the cell's data into each of its children.
That's probably not what we want here. Instead, we can pass in new data for each child when we call split:

```@repl demo
split!(cell, ["B", "C", "D", "E"])
```

```@repl demo
cell[1,1].data
```

```@repl demo
cell[2,1].data
```

If managing a list of child data is inconvenient, you can instead pass in a function to generate the child data.
That function will be called with two inputs: the cell being split and the indices of the child being created:

```@repl demo
c = Cell(SVector(0., 0), SVector(1., 1), "root")
```

Let's make a simple data generator that just tacks on the indices from the root of the tree:

```@repl demo
function getdata(cell, child_indices)
    "$(cell.data) child $(child_indices)"
end

split!(c, getdata)
split!(c[1,1], getdata)
split!(c[1,2], getdata)
split!(c[1,2][2,2], getdata)

c[1,2][2,2][1,1].data
```

## Adaptive sampling with a refinery

Finally, there is a higher-level abstraction than this for automatically splitting cells and populating their data.
The concept is based around adaptive sampling and is implemented through the "refinery" concept.

A refinery is a type which inherits from `AbstractRefinery` and implements two methods:

- `needs_refinement(refinery, cell::Cell)`:
  returns `true` if the cell should be split
- `refine_data(refinery, cell::Cell, indices)`:
  returns the new data for the cell's child with the given indices

You may want to use `child_boundary(cell, indices)` to get the bounding box
corresponding to the child cell for which you are generating data.

Let's create a trivial example that will refine each cell until its width is less than a given tolerance:

```@repl demo
import RegionTrees: AbstractRefinery, needs_refinement, refine_data

struct MyRefinery <: AbstractRefinery
    tolerance::Float64
end
```

These two methods are all we need to implement:

```@repl demo
function needs_refinement(r::MyRefinery, cell)
    maximum(cell.boundary.widths) > r.tolerance
end

function refine_data(r::MyRefinery, cell::Cell, indices)
    boundary = child_boundary(cell, indices)
    "child with widths: $(boundary.widths)"
end
```

Now we can use our refinery to create the entire tree, with all cells split automatically:

```@repl demo
r = MyRefinery(0.05)
root = Cell(SVector(0., 0), SVector(1., 1), "root")
adaptivesampling!(root, r)
```

```@repl demo
root[1,1][1,1][1,1][1,1][1,1].data
```

```@repl demo
plt = plot(xlim=(0, 1), ylim=(0, 1), legend=nothing)
for leaf in allleaves(root)
    v = hcat(collect(vertices(leaf.boundary))...)
    plot!(plt, v[1,[1,2,4,3,1]], v[2,[1,2,4,3,1]])
end
savefig("cell-2.svg"); nothing # hide
```

![](cell-2.svg)
