#Cut specific branches from a phylo tree

library(ape); library(readr); library(dplyr)
# Load your tree
tree <- read.tree("all_content/results/Example1_Cmi_root_d0001.nwk")
# Cut specific branches by their tip names
pruned_tree <- drop.tip(tree, c("V9XD4P_1","V9XD4P_2","V9XD4P_3","V9XD4P_4",
                                "V9XD4P_6","V9XD4P_7"))

write.tree(pruned_tree, "data/example_phylo_Cmi_d0001.nwk")

design<-read_tsv("data/Experiment_Design_example_2.tsv")

model_strains<-design %>% filter(source=="reference")
tree_eco<-read.tree("data/example_2_phylo.nwk")

to_prune<-tree_eco$tip.label[which(!tree_eco$tip.label %in%
                           model_strains$Assembly.Accession)]

pruned_eco <- drop.tip(tree_eco, to_prune)

write.tree(pruned_eco, "data/example_eco_model.nwk")


