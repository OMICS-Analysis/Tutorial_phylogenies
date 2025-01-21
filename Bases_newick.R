library("ape")
library("ggtree")

#Newick tree format is a way of representing a phylogeny with parentheses and commas.

#The basic elements of a Newick tree are

# Branches
# Nodes
  #Leaves: Nodes with no descendants, also colled tip points
  #Internal nodes: Nodes with descendants

#Minimal newick: only the branches (edge)
#A branch for each comma and each parenthesis pair (internal parenthesis)
# (  , (,)  )
#      ^ ^    internal parenthesis
# ^        ^  external parenthesis

tree<-"(,(,));" 
tree<-read.tree(text=tree)
ggtree(tree)+geom_tiplab()

#Here you can see tip points and internal nodes colored in red and blue, respectively
ggtree(tree)+
  geom_tippoint(size=3, color="red")+
  geom_nodepoint(size=3, color="blue")


#Newick with names:
#The tree leaves (tip points) can be labeled 
#Labels correspond to clades (species, strains)

tree<-"(cat,(dog,fox));" 
tree<-read.tree(text=tree)
ggtree(tree)+geom_tiplab()

#You can indicate the length or distance of each branch
#The length is the amount of evolutionary change in each branch
tree<-"(cat:0.6,(dog:0.1,fox:0.1):0.2);" 
tree<-read.tree(text=tree)
ggtree(tree)+geom_tiplab()


#You can also label internal nodes nodes.
#Internal nodes are common ancestors for a group of leaves
tree<-"(cat:0.6,(dog:0.1,fox:0.1)Anc:0.2);" 
tree<-read.tree(text=tree)
ggtree(tree,)+geom_tiplab()+geom_nodelab()

#Or instead of a node label you can use a bootstrap value
#Bootstrap values are calculated to indicate the level of
#support of a given node.
#Here, the event with fox and dog having a common ancestor has a confidence of 0.9 of 1

tree<-"(cat:0.6,(dog:0.1,fox:0.1)0.9:0.2);" 
tree<-read.tree(text=tree)
ggtree(tree,)+geom_tiplab()+geom_nodelab()


