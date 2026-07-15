**PHYLO TRAINING REPOSITORY**

The goal of this repository is to create a set of training resources and recipes for phylogeny manipulation and analysis.
We will focus on the following *subjects*

+ Understand the Newick format and the phylogenetic information contained in it
+ Brief manual of the the main packages for phylogeny analysis
+ Create recipes for frequent tasks

*Specific tasks*

- [x] Newick format mini-manual A
- [ ] Phylogenies mini-manual A
  - [ ] Distances
  - [ ] Bootstrapping and support values
  - [ ] Root
- [ ] Graph: ggtree (graphs) and its main functions E
- [x] Manipulate phylogeny: treeio D
- [ ] Metadata managing: df o treeio-> ggtree E
- [ ] Frequent processes in visualización
 - [x] Tip and node labels E
 - [x] Metadata addition in tips and nodes E
 - [x] Basic functions of ggtree E
 - [x] Root and re-root (first: basic concepts) D
 - [x] Rotate branches D
 - [x] Cut or resize an edge D
 - [x] Eliminate branches D
 - [x] Cut phylogeny by internal node A
 - [ ] Parent, child, ancestor and MRCA identification A + D
- [ ] Convert treeio.R* to tree_object_handling.R: phylo, tibble, ggtree, igraph
- [ ] Create: tree_explore_and_transforme.R: ancestor, child, MCRA, siblings, root, cut, prune

 *Keep in mind* that phylogenies are created with two main goals:

 1. To verify the phylogenetic position of know strains
 2. To eliminate or re-label redundant or problematic strains
 3. To test different representations using the matetadata
 4. To deliver final phylogeny to customers

So it is important that phylogenetic distances, support values, as well as relevant data are clearly visible in the phylogeny images :)
(Big font, color: high contrast)
