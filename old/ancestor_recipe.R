library("dplyr")
library("treeio")
library("ggtree")
library("igraph")
library("ape")

#####################################
#WORKING EXAMPLE
#####################################

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

#Phylo object information can be converted to tibble
treetib<-as_tibble(tree)
View(treetib)

#The phylogeny edges are defined by the parent node and the child node
#As a phylogeny is a group of nodes connected by edges it can be
#easily converted to a directed graph

g<-graph_from_data_frame(treetib, directed=TRUE)
print(g)

#This is the image of the graph
plot(g)

#We can eliminate the self-loop of the root if present
g<-simplify(g, remove.multiple = FALSE, remove.loops = TRUE)
plot(g)

#We can see the edge properties like this
E(g)$branch.length

#####################################
#SIMPLIFY-PRUNE BY MINIMUM DISTANCE
#####################################
tree_Cmi<-read.tree("Cmi_cut_reroot.nwk")
treetib_Cmi<-as_tibble(tree_Cmi)
g_Cmi<-graph_from_data_frame(treetib_Cmi, directed=TRUE)
plot(g_Cmi,vertex.size=2,edge.arrow.size=0.01)
#####################################
#FINDING THE COMMON ANCESTOR OF A GROUP OF NODES: Bases
#####################################

#There is a single node (vertice/node 8) that has itself as a parent
#In the tibble object of the graph
#This would be the root of the tree (the point from where all the branches originate)

r<-treetib %>% filter(parent==node) %>% .$node %>% as.character
print(r)

# We delete the r connection to itself (self loop) to allow path calculation
g<-simplify(g)
plot(g)

#Find the shortest way from root to a leaf
sp<-shortest_paths(g,r,"6")$vpath[[1]] %>% names





#####################################
#FINDING THE COMMON ANCESTOR OF A GROUP OF NODES: Function
#####################################

#We want to find the common ancestor of Human and Orangutan and Chimp
#The common ancestor is an internal node

#Convert the phylo object to: directed graph object AND dataframe of node ids
tree_to_graph<-function(tree){
  
  #Create df to relate node labels and numbers
  node_labels<-c(tree$tip.label,1:tree$Nnode)
  node_label_id<-data.frame(label=node_labels,id=1:length(node_labels))
  
  #Create a directed graph object
  edges_df<-tree$edge %>% data.frame 
  g<-graph_from_data_frame(edges_df, directed = TRUE, vertices = NULL)
  
  return(list(g,node_label_id))
}

#Find the shortest path between two nodes
shortestpath_v<-function(graph, root_node, node){
  sp<-get.shortest.paths(graph,root_node,node)$vpath[[1]]
  sp<-names(sp)
  return(sp)
}
  
#Find a common ancestor
common_ancestor<-function(labs,tree){
  
  ttg<-tree_to_graph(tree)
  
  #Find the root node of the tree
  print
  indeg<-degree(ttg[[1]], mode=c("in"))
  rootnode<-names(sort(indeg)[1])
  
  #Find the node id of each desired leaf
  node_labs_id<-ttg[[2]] %>% filter(label %in% labs) %>% .[,2] %>% as.character
  
  #Find common path from root to leaves and intersect
   #For the first leaf
  commpath<-shortestpath_v(ttg[[1]],rootnode,node_labs_id[1])
   #For the rest of the leaves
  for(i in 2:length(node_labs_id)){
    thispath<-shortestpath_v(ttg[[1]],rootnode,node_labs_id[i])
    commpath<-intersect(commpath,thispath)
  }
  #Find common ancestor (end of the common path)
  commanc<-which(thispath %in% commpath)
  commanc<-thispath[max(commanc)]
  return(commanc)
}

plot(g)
labs<-c("Human","Chimp")
common_ancestor(labs,tree) 

labs<-c("Human","Gorilla")
common_ancestor(labs,tree) 

labs<-c("Human","Orang")
common_ancestor(labs,tree) 

labs<-c("Human","Gibbon")
common_ancestor(labs,tree) 

labs<-c("Human","Bovine")
common_ancestor(labs,tree) 

labs<-c("Mouse","Bovine")
common_ancestor(labs,tree) 

