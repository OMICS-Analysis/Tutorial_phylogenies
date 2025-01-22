library("dplyr")
library("treeio")
library("ggtree")
library("igraph")

#Lets explore the contents of the phylo object
tree<-"(Bovine:0.69395,
      (Gibbon:0.36079,
          (Orang:0.33636,
              (Gorilla:0.17147,
                  (Chimp:0.19268, Human:0.11927):0.08386
               ):0.06124
           ):0.15057
       ):0.54939,Mouse:1.21460
       );"

tree<-read.tree(text=tree)
ggtree(tree)+geom_tiplab()+ geom_tippoint(size=3, color="red")+
  geom_nodepoint(size=3, color="blue")

#These is the list of leaves (red in the previous picture)
tree$tip.label %>% print
#And the number of internal nodes (blue in the previous picture)
tree$Nnode %>% print

#This would be the node order in the pylo object
nodes<-c(tree$tip.label,1:tree$Nnode)
print(nodes)

#The node number in the phylo object would be as follows
node_number<-data.frame(node=nodes,node_number=1:length(nodes))
print(node_number)

#The phylogeny edges are defined by the parent node and the child node
#This would be the node were each line starts and the node were it ends

tree$edge %>% print
edges_df<-tree$edge %>% data.frame 

#As a phylogeny is a group of nodes connected by edges it can be
#easily converted to a directed graph

g<-graph_from_data_frame(edges_df, directed = TRUE, vertices = NULL)

#These are the vertices of the graph (phylogeny nodes)
V(g)

#This is the image of the graph
plot(g)

#There is a single node (vertice/node 8) that has only outgoing 
#connections and no incomming connections
#This would be the root of the tree (the point from where all the branches originate)
#In the graph language we say that "Node 8 has a in degree of 0"
#Lets find the in degree of all nodes

indeg<-degree(g, mode=c("in"))
print(indeg)

#And this would be the name of the root node
r<-names(sort(indeg)[1])
print(r)

#If we want to find the common ancestor (internal node) of a group of leaves we can ...

#Find the shortest way to each leave
get_shortest_paths(g,8,5)

s85<-get.shortest.paths(g,"8","5")
