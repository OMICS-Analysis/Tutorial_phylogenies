#Cut specific branches from a phylo tree

library(ape)
# Load your tree
tree <- read.tree("data/example_phylo.nwk")
# Cut specific branches by their tip names
pruned_tree <- drop.tip(tree, c("V9XD4P_1","V9XD4P_2","V9XD4P_3","V9XD4P_4",
                                "V9XD4P_6","V9XD4P_7"))

write.tree(pruned_tree, "data/example_phylo_Cmi.nwk")
