#Source: https://yulab-smu.top/treedata-book/chapter2.html
library(dplyr)
library(ggtree)
library(treeio)
library(tidyverse)
library(tidytree)
library(adephylo)
library(dendextend)

# Load C. michiganensis tree file and edit support values to 3 digits
tree <- read.newick("data/example_phylo.nwk")

#Convert tree information to tibble object and add metadata
treetib<-as_tibble(tree)

#Load strain metadata
metadata <- readr::read_tsv("data/Experiment_Design_example_1.tsv")
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

write.tree(tree_reroot,"results/Cmi_full_reroot.nwk")

#C. michiganensis strains tree
ingroup<-treetib %>% filter(Source!="Reference")  %>% .[["label"]]
#This is the common ancestor of all C. michiganensis
mrca_ingroup<-treeio::MRCA(tree_reroot,ingroup)
ggtree(tree_reroot) + geom_point2(aes(subset=(node==mrca_ingroup)), col='red')

#Now we subset by the phylogeny using the MRCA of C. michiganensis
tree_Cmi<-tree_subset(tree_reroot,212,levels_back = 0)
ggtree(tree_Cmi) + geom_rootpoint(col="red")
write.tree(tree_Cmi,"results/Cmi_cut_reroot.nwk")

#Simplify by minimal distance among strains

#Select a minimal distance
d=0.00005 #Expecting 50 snps per million bases of the alignment, one every 20,000 bases

#Obtain a matrix of phylogenetic distances for tree
node_distances<-distTips(tree_Cmi)

#Generate hierarchical clustering from distances
hclust<-hclust(node_distances)

#Cut hclust intro groups by d
Cmi_groups<-data.frame(distance_group=cutree(hclust, h = d) %>% sort)

#How many groups do we have
Cmi_groups$distance_group %>% sort %>% unique %>% length

#Show groups with a maximal distance of d among them

cols=rev(c(1,2,3,4,5,7,8,9,18,19,20))

#Show group division

dendo<-as.dendrogram(hclust)

x<-treetib %>% select(label,Location) %>% 
  filter(label %in% labels(dendo)) %>% 
  arrange(match(label, labels(dendo))) %>% .[["Location"]]


dendo<-dendo %>%
  color_branches(h=d,col=cols) %>%
  set_labels(x) %>%
  color_labels(h=d,col=cols)

dendo <- set(dendo, "labels_cex", 0.5)

par(mar=c(2,2,2,3))
plot(dendo, horiz = TRUE, xlim=c(0.001,0))
abline(v = d)
