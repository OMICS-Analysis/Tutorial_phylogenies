library(treeio)
library(ape)
#To generate phylogenetic trees we start from a protein or a DNA alignment
#The DNA alignment shows the places along the sequence where there are differences (mutations)
#From one species or strain to another.
#RaxML uses this information to calculate distances, which are
#the number of expected mutations per site from one strain to another.

tree<-read.tree("example_phylo.nwk")

edgelens<-tree$edge.length

#Select a minimal distance m
#Find leaves which have less than m distance from parent
#Identify the parent node
#Generate a column with the group of the strains