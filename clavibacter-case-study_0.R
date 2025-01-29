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

#REROOT by outgroup
#####################################
#Outgroup (non C. michiganensis strains)
outgroup<-treetib %>% filter(Source=="Reference")  %>% .[["label"]]

#Reroot and graph
tree_reroot<-root(tree, outgroup)
ggtree(tree_reroot) + geom_rootpoint(col="red")

write.tree(tree_reroot,"results/Example1_all_root.nwk")

#C. michiganensis strains tree
##############################

ingroup<-treetib %>% filter(Source!="Reference")  %>% .[["label"]]
#This is the common ancestor of all C. michiganensis
mrca_ingroup<-treeio::MRCA(tree_reroot,ingroup)
ggtree(tree_reroot) + geom_point2(aes(subset=(node==mrca_ingroup)), col='red')

#Now we subset by the phylogeny using the MRCA of C. michiganensis
tree_Cmi<-tree_subset(tree_reroot,212,levels_back = 0)
ggtree(tree_Cmi) + geom_rootpoint(col="red")

write.tree(tree_Cmi,"results/Example1_Cmi_root.nwk")


#Simplify by minimal distance among strains
##############################

simplify_phylo_by_dist<-function(tree,dist,metadata){
  #Minimal distance between strains
  d<-dist 

  #Matrix of phylogenetic distances between leaves
  #And hierarchical clustering of leaves by distance
  hclust_all<-distTips(tree) %>% hclust
  
  #Cut hierarchical clustering tree into groups by d
  groups<-data.frame(phylo_group=cutree(hclust_all, h = d)) %>% 
    rownames_to_column(var="label")
  
  #Join groups with metadata. Select one strain per phylogroup: 
  #The one with the highest N50. Prioritize customer strains (Source==Cliente)
  selected<-left_join(groups,metadata,by="label") %>% 
    group_by(phylo_group) %>% 
    arrange(phylo_group,Source,desc(BUSCO_Contigs_N50_MB)) %>%
    filter(row_number()==1) %>% .[["label"]]
  
  #Keep only selected strains
  tree_sub<-keep.tip(tree_reroot,tip=selected)
  #Return tree and phylogenetic groups
  return(list(tree_sub,groups))
}

tree_Cmi_0001<-simplify_phylo_by_dist(tree_Cmi,0.0001,metadata)
ggtree(tree_Cmi_0001[[1]]) + geom_rootpoint(col="red") + geom_tiplab()
write.tree(tree_Cmi_0001[[1]],"results/Example1_Cmi_root_d0001.nwk")

tree_Cmi_00005<-simplify_phylo_by_dist(tree_Cmi,0.00005,metadata)
ggtree(tree_Cmi_00005[[1]]) + geom_rootpoint(col="red") + geom_tiplab()
write.tree(tree_Cmi_00005[[1]],"results/Example1_Cmi_root_d00005.nwk")

tree_Cmi_000025<-simplify_phylo_by_dist(tree_Cmi,0.000025,metadata)
ggtree(tree_Cmi_000025[[1]]) + geom_rootpoint(col="red")
write.tree(tree_Cmi_000025[[1]],"results/Example1_Cmi_root_d000025.nwk")


# #Show groups with a maximal distance of d among them
# cols=rev(c(1,2,3,4,5,7,8,9,18,19,20))
# dendo<-as.dendrogram(hclust_all)
# 
# x<-treetib %>% select(label,Location) %>% 
#   filter(label %in% labels(dendo)) %>% 
#   arrange(match(label, labels(dendo))) %>% .[["Location"]]
# 
# dendo<-dendo %>%
#   color_branches(h=d,col=cols) %>%
#   set_labels(x) %>%
#   color_labels(h=d,col=cols)
# dendo <- set(dendo, "labels_cex", 0.5)
# 
# par(mar=c(2,2,2,3))
# plot(dendo, horiz = TRUE, xlim=c(0.001,0))
# abline(v = d)

