# *Tree object Handling*
# Trees exist as objects of various forms in R before they are printed to a
# visual form. These objects allow us to modify tree data in different ways
# to enrich and improve visualization.

## *phylo objects*
## Trees are initially imported from Newick files by `read.newick` as `phylo`
## objects. These are simple objects which outline tree nodes, edges, and
## their labels making them easily accessible.

library(treeio)
tree0=read.newick("data/example_phylo.nwk")
class(tree0) # simple phylo tree
print(tree0) # simple summary

## Within the object:

names(tree0)

## `tip.label` has the leaf names.
print(head(tree0$tip.label))

## `node.label` has the tags in the nodes from the Newick file. In the case of 
## RAxML outputs, these tags are the bootstrap support values.
print(head(tree0$node.label))

## `edge` links leaves and inner nodes to build the tree.
print(head(tree0$edge))

## `edge.length` holds the lengths of the edges according to the phylogenetic
## calculations from RAxML. The edges are counted starting from the number
## of leaves + 1.
print(head(tree0$edge.length))

## The advantage of the `phylo` object is that its contents are easy to
## modify:
tree0a<-tree0
xtip<-which(tree0a$tip.label=="GCF_021952865.1")
tree0a$tip.label[xtip]="changed"
plot(tree0a)
rm(tree0a)

## *tibbles and tidytree objects*
## The downside of `phylo` objects is that they are not easy to enrich with
## needed annotations. A good way to cover this is `tidytree` objects, which
## seamlessly merge all data and make them easily accessible for routines 
## downstream. `tidytree` objects, though, are S4 objects which have more
## rigid encapsulation.
## Building `tidytree` objects from `phylo` objects can become cumbersome
## using regular data manipulation routines. Fortunately, tibble functions
## make this construction much easier.

treetib<-as_tibble(tree0)
class(treetib)
print(treetib)

## This makes it easy to add data:

Design=read.table("data/Experiment_Design_example_1.tsv",sep="\t",header=T)
colnames(Design)
rownames(Design)=Design$Assembly.Accession

library(tidyverse)

# subset metadata
chrs=c("Strain")
fcts=c("Organism","Host","Assembly_level")
nums=c("Count_gene_total","ANI","BUSCO_Scaffold_N50_.MB.","BUSCO_Contigs_N50_.MB.","CheckM_Completeness")

#Subset design, leave only desired columns
x<-Design %>% select(all_of(c(chrs,fcts,nums)))
x<-x[tree0$tip.label,]
if(identical(rownames(x),tree0$tip.label)){
    print("good")
    x<-rownames_to_column(x, "label")
    x[chrs]<-lapply(x[chrs], as.character)
    x[fcts]<-lapply(x[fcts], factor)
    x[nums]<-lapply(x[nums], as.numeric)
    treetib<-left_join(treetib, metadata_ordered, by = c('label'))
    tree_cm <- as.treedata(treetib)
}

## *ggtree objects*
## `ggplot2` produces graphs, and `ggtree` is built on top to specialize in
## plotting trees. However, to generate the plots `ggplot2` creates objects
## which specify plot properties. These objects can be handled in several
## ways to create more detailed plots.



## Another way is to use the `cowplot` library to print the plot as a grid of 
## several objects. This comes useful to create complex plots and legends in
## the cases in which `ggplot` makes this difficult.

## *igraph*
