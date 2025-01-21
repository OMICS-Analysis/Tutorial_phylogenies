# `treeio` tutorial

Sources:

- [`treeio`: Phylogenetic data integration](https://www.r-bloggers.com/2018/05/treeio-phylogenetic-data-integration/) ([original](https://ropensci.org/blog/2018/05/17/treeio/))

## Purpose

Using `treeio` allows us to enrich phylogenetic trees with data on the leaves which are not directly related to the tree (as would be data like distances and support values).

## Install

From BioConductoR install, just do:

```
BiocManager::install("treeio")
```

or on the light version:

```
biocLite::install("treeio")
```

## Tree Handling

Let's call the library:

```
library(treeio)
```

`RAxML-ng` outputs Newick trees, so let's stick to that:

```
tree0=read.newick("example_phylo.nwk")
class(tree0) # simple phylo tree
print(tree0) # simple summary
```

Now we can get the metadata file, choose data, and include. Let's prepare the metadata:

```
Design=read.table("Experiment_Design_example_1.tsv",sep="\t",header=T)
colnames(Design)
rownames(Design)=Design$Assembly.Accession
```

Now we pick relevant data and compact them into a single table. For this example, we fill gradually by variable type:

```
chrs=c("Strain")
fcts=c("Organism","Host","Assembly_level")
nums=c("Count_gene_total","ANI","BUSCO_Scaffold_N50_.MB.","BUSCO_Contigs_N50_.MB.","CheckM_Completeness")

x=data.frame(label=tree0$tip.label)
for(i in fcts) {
    x[,i]=rep("",length(x$label))
    for(n in x$label){
        x[which(x$label==n),i]=as.character(Design[n,i])
    }
    x[,i]=as_factor(x[,i])
}
for(i in chrs) {
    x[,i]=rep("",length(x$label))
    for(n in x$label){
        x[which(x$label==n),i]=as.character(Design[n,i])
    }
}
for(i in nums) {
    x[,i]=rep(0,length(x$label))
    for(n in x$label){
        x[which(x$label==n),i]=Design[n,i]
    }
    x[,i]=as.numeric(x[,i])
}
```

Now we simply add the metadata to the tree using `treeio`'s `full_join()` function. This also changes the type of object to one that reflects the association:

```
tree1=full_join(tree0,x,by="label")
class(tree1) # treedata with attributes (the table)
print(tree1) # summary + tibble with data
```

## Advantages

The main advantage of using `treeio` to add metadata is that we can now take the table's variables and reference them by name in `ggtree`. This simplifies the process of handling them as part of the tree object:

```
library(ggtree)
library(RColorBrewer)

wd=20
ht=40

plo=ggtree(tree1) +
    geom_nodelab(size=ht*0.05,color="black",breaks=NA) +
    geom_tiplab(aes(label=label),size=ht*0.05,fontface=2) +
    geom_tippoint(aes(color=Organism)) +
    scale_color_manual("Organism",
                       values=brewer.pal(length(levels(x$Organism)),"Paired")
                      ) +
    theme(legend.title=element_text(size=ht*0.3),
          legend.text=element_text(size=ht*0.25),
          legend.position="bottom")

pdf("example_phylo_w_orgs.pdf",width=wd,height=ht)
print(plo)
dev.off()
```
