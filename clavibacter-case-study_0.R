#Source: https://yulab-smu.top/treedata-book/chapter2.html
library(ggtree)
library(treeio)
library(tidyverse)
library(tidytree)

# Load C. michiganensis tree file and edit support values to 3 digits
tree <- read.newick("example_phylo.nwk")

#Convert tree information to tibble object and add metadata
treetib<-as_tibble(tree)

#Load strain metadata
metadata <- readr::read_tsv("Experiment_Design_example_1.tsv")
metadata <- metadata %>%
  rename(label = Assembly.Accession)  # Para coincidir con etiquetas del árbol
metadata$Source<-ifelse(is.na(metadata$Source),"RefSeq",metadata$Source)

#Combine tree and metadata
treetib<-left_join(treetib, metadata, by = 'label')

#This is the outgroup (non C. michiganensis strains)
outgroup<-treetib %>% filter(Source=="Reference")  %>% .[["label"]]

#Reroot by outgroup
tree_reroot<-root(tree, outgroup)
ggtree(tree_reroot) + geom_rootpoint(col="red")

write.tree(tree_reroot,"Cmi_full_reroot.nwk")

#C. michiganensis strains tree
ingroup<-treetib %>% filter(Source!="Reference")  %>% .[["label"]]
#This is the common ancestor of all C. michiganensis
mrca_ingroup<-treeio::MRCA(tree_reroot,ingroup)
ggtree(tree_reroot) + geom_point2(aes(subset=(node==mrca_ingroup)), col='red')

#Now we subset by the phylogeny using the MRCA of C. michiganensis
tree_Cmi<-tree_subset(tree_reroot,212,levels_back = 0)
ggtree(tree_Cmi) + geom_rootpoint(col="red")
write.tree(tree_Cmi,"Cmi_cut_reroot.nwk")

#Convert C. michiganensis tree to tibble

treetib_Cmi<-as_tibble(tree_Cmi)

treetib_Cmi<-left_join(treetib_Cmi, metadata, by = 'label')

#Select a minimal distance
d=0.00001
treetib_Cmi$short<-ifelse((grepl("GCA",treetib_Cmi$label) & 
                             treetib_Cmi$branch.length<=d),
                          TRUE,FALSE)
treetib_Cmi$short<-as.character(treetib_Cmi$short)

tree_Cmi<-as.treedata(treetib_Cmi)

ggtree(tree_Cmi,layout="circular")+
  geom_tippoint(aes(color = short), size = 1)+
  geom_tiplab(aes(label=parent),size=2)


