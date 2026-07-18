# Tree management

## Rerooting

### What is rerooting

The tree root is the position from which the rest of the tree is drawn. The root is handled as a node placed in the middle of some edge, normally that of an outgroup to the rest of the tree. Rerooting is simply changing the position of this node. Trees can be unrooted.

### How to reroot

First, some preparations from the [ancestry routines]():

```
library("dplyr")
library("treeio")
library("ggtree")
library("igraph")

tree_to_graph<-function(tree){
  
  #Create df to relate node labels and numbers
  node_labels<-c(tree$tip.label,1:tree$Nnode)
  node_label_id<-data.frame(label=node_labels,id=1:length(node_labels))
  
  #Create a directed graph object
  edges_df<-tree$edge %>% data.frame 
  g<-graph_from_data_frame(edges_df, directed = TRUE, vertices = NULL)
  
  return(list(g,node_label_id))
}

shortestpath_v<-function(graph, root_node, node){
  sp<-get.shortest.paths(graph,root_node,node)$vpath[[1]]
  sp<-names(sp)
  return(sp)
}

common_ancestor<-function(labs,tree){
  
  ttg<-tree_to_graph(tree)
  
  #Find the root node of the tree
  indeg<-degree(ttg[[1]], mode=c("in"))
  rootnode<-names(sort(indeg)[1])
  
  #Find the node id of each desired leaf
  node_labs_id<-ttg[[2]] %>% filter(label %in% labs) %>% .[,2] %>% as.character
  
  #Find common path from root to leaves
  commpath<-shortestpath_v(ttg[[1]],rootnode,node_labs_id[1])
  for(i in 2:length(node_labs_id)){
    thispath<-shortestpath_v(ttg[[1]],rootnode,node_labs_id[i])
    commpath<-intersect(commpath,thispath)
  }
  #Find common ancestor (end of the common path)
  commanc<-which(thispath %in% commpath)
  commanc<-thispath[max(commanc)]
  return(commanc)
}

# Proposed add: autofind root
find_root<-function(tree){
    g0=tree_to_graph(tree)
    r=names(which(degree(g0[[1]], mode=c("in"))==0))
    return(r)
}
```

Rerooting is easy to do through `phytools::reroot`:

```
library(phytools)
tree0=read.newick("example_phylo.nwk")
myroot=find_root(tree0)
outgroup="GCF_014775655.1"
tree1=reroot(tree0,which(tree0$tip.label==outgroup))
plot(tree0)
plot(tree1)
```

## Rotate branches

### What is rotating branches

Rotating branches is swapping the positions of two tips of a tree preserving the relative positions of all nodes in between. This is normally done to make visualization easier.

### How to rotate

Rotating branches is easy to do using `ggtree::flip`:

```
library(ggtree)
tree0=read.newick("example_phylo.nwk")
plo0=ggtree(tree0) +
     geom_nodelab(aes(label=c(1:(length(tree0$tip.label)+tree0$Nnode)))) +
     geom_tiplab(aes(label=c(1:(length(tree0$tip.label)+tree0$Nnode))))
     
cmp=which(tree0$tip.label=="GCF_000069225.1")
cmp=tree0$edge[which(tree0$edge[,2]==cmp),1]
plo1=flip(plo0,which(tree0$tip.label=="GCF_021952865.1"),cmp)
```

## Delete branches

Deleting branches is easy to do with `ape::drop.tip`. Most phylogeny libraries in R export this function automatically.

```
library(treeio)
tree0=read.newick("example_phylo.nwk")
outgroup="GCF_014775655.1"
tree2=drop.tip(tree0,tip=which(tree0$tip.label==outgroup))
plo2=ggtree(tree0) +
     geom_nodelab() +
     geom_tiplab()
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
  

