#Source: https://yulab-smu.top/treedata-book/chapter2.html
library(ggtree)
library(treeio)
library(tidyverse)
library(tidytree)

# Load C. michiganensis tree file and edit support values to 3 digits
tree <- read.newick("example_phylo.nwk")

#Load strain metadata
metadata <- readr::read_tsv("Experiment_Design_example_1.tsv")
metadata <- metadata %>%
  rename(label = Assembly.Accession)  # Para coincidir con etiquetas del árbol
metadata$Source<-ifelse(is.na(metadata$Source),"RefSeq",metadata$Source)

#This is the outgroup (non C. michiganensis strains)
outgroup<-metadata %>% filter(Source=="Reference")  %>% .[["label"]]

#Reroot by outgroup
tree_reroot<-root(tree, outgroup)
ggtree(tree_reroot) + geom_rootpoint(col="red")

write.tree(tree_reroot,"Cmi_full_reroot.nwk")

#Convert tree information to tibble object and add metadata
treetib<-as_tibble(tree)
treetib<-left_join(treetib, metadata, by = 'label')

#Refseq strains
ingroup<-treetib %>% filter(Source!="Reference")  %>% .[["label"]]
mrca_ingroup<-treeio::MRCA(tree_reroot,ingroup)
ggtree(tree_reroot) + geom_point2(aes(subset=(node==mrca_ingroup)), col='red')

#Now we subset by the phylogeny using the MRCA of C. michiganensis
tree_Cmi<-tree_subset(tree_reroot,212,levels_back = 0)
ggtree(tree_Cmi) + geom_rootpoint(col="red")

write.tree(tree_Cmi,"Cmi_cut_reroot.nwk")
