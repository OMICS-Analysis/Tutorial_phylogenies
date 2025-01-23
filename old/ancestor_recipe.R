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

#These are the node labels in the pylo object
labels<-c(tree$tip.label,1:tree$Nnode)
print(labels)

#The node ids in the phylo object would be as follows
node_label_id<-data.frame(node=labels,node_number=1:length(labels))
print(node_label_id)

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
#connections and no incoming connections
#This would be the root of the tree (the point from where all the branches originate)
#In the graph language we say that "Node 8 has a in degree of 0"
#Lets find the in degree of all nodes

indeg<-degree(g, mode=c("in"))
print(indeg)

#And this would be the name of the root node
r<-names(sort(indeg)[1])
print(r)

#Find the shortest way from root to a leaf
sp<-shortest_paths(g,r,"6")$vpath[[1]] %>% names
print(sp)


#####################################
#FINDING THE COMMON ANCESTOR OF A GROUP OF NODES
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

