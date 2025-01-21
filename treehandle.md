# Tree management

## Rerooting

### What is rerooting

The tree root is the position from which the rest of the tree is drawn. The root is handled as a node placed in the middle of some edge, normally that of an outgroup to the rest of the tree. Rerooting is simply changing the position of this node. Trees can be unrooted.

### How to reroot

Rerooting is easy to do through `phytools::reroot`:

```
library(phytools)
tree0=read.newick("example_phylo.nwk")
tree1=reroot(tree0,which(tree0$tip.label==outgroup))
```

## Rotate branches

### What is rotating branches

Rotating branches is swapping the positions of two tips of a tree preserving the relative positions of all nodes in between. This is normally done to make visualization easier.

### How to rotate

Rotating branches is easy to do using `ggtree::flip`:

```
library(ggtree)
tree0=read.newick("example_phylo.nwk")
tree1=flip(tree0,1,5)
```

## Delete branches

Deleting branches is easy to do with `ape::drop.tip`. Most phylogeny libraries in R export this function automatically.

```
library(treeio)
tree0=read.newick("example_phylo.nwk")
tree1=drop.tip(tree0,tip=which(tree$tip.label==todrop)
```
## resize edges

### Why resize edges

Sometimes the lengths of certain branches like outgroups are excessively long compared to the rest of the tree, making visualization awkward. Shortening these edges makes the rest of the tree visible.

### How to resize edges

Resizing edges can be done two ways:

- Finding the nodes on the file. 

- Searching the required node in R is doable using the tree's attributes.
  - The attribute `tree$edge` describes which edges link which nodes.
  - The attributes `tree$tip.label` and `tree$node.label` contain the labels of the nodes, helping identify them. Their numbers in the vectors are the ultimate IDs; tips first, inner nodes second.
  

