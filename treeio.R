# https://www.r-bloggers.com/2018/05/treeio-phylogenetic-data-integration

# basic loadup
library(treeio)
library(tidyverse)
tree0=read.newick("example_phylo.nwk")
class(tree0) # simple phylo tree
print(tree0) # simple summary

# load metadata
Design=read.table("Experiment_Design_example_1.tsv",sep="\t",header=T)
colnames(Design)
rownames(Design)=Design$Assembly.Accession

# subset metadata
chrs=c("Strain")
fcts=c("Organism","Host","Assembly_level")
nums=c("Count_gene_total","ANI","BUSCO_Scaffold_N50_.MB.","BUSCO_Contigs_N50_.MB.","CheckM_Completeness")

#Hola Erick: ¿Cómo ves esta alternativa? La puse por que es menos código, pero échale un ojo
#Subset design, leave only desired columns
x<-Design %>% select(all_of(c(chrs,fcts,nums)))
#Order rownames of dataframe x: Make them follow tree0$tip.label
x<-x[tree0$tip.label,]
#Are rownames of x identical to phylogeny tip.labels
identical(rownames(x),tree0$tip.label)
#Convert rows to first column (label column)
x<-rownames_to_column(x, "label")
#Coerce columns to appropiate type
x[chrs]<-lapply(x[chrs], as.character)
x[fcts]<-lapply(x[fcts], factor)
x[nums]<-lapply(x[nums], as.numeric)
y<-x

x=data.frame(label=tree0$tip.label)
for(i in fcts) {
    x[,i]=rep("",length(x$label))
    for(n in x$label){
        x[which(x$label==n),i]=as.character(Design[n,i])
    }
    x[,i]=as_factor(x[,i])
}
for(i in chrs) {
    x[,i]=rep("",length(x$label))
    for(n in x$label){
        x[which(x$label==n),i]=as.character(Design[n,i])
    }
}
for(i in nums) {
    x[,i]=rep(0,length(x$label))
    for(n in x$label){
        x[which(x$label==n),i]=Design[n,i]
    }
    x[,i]=as.numeric(x[,i])
}

# merge metadata into tree
#Cambié el dataframe de x a y aquí para hacer la prueba
tree1=full_join(tree0,y,by="label")
class(tree1) # treedata with attributes (the table)
print(tree1) # summary + tibble with data

# plot tree
library(ggtree)
library(RColorBrewer)

wd=20
ht=40

plo=ggtree(tree1) +
    geom_nodelab(size=ht*0.05,color="black",breaks=NA) +
    geom_tiplab(aes(label=label),size=ht*0.05,fontface=2) +
    geom_tippoint(aes(color=Organism)) +
    scale_color_manual("Organism",
                       values=brewer.pal(length(levels(x$Organism)),"Paired")
                      ) +
    theme(legend.title=element_text(size=ht*0.3),
          legend.text=element_text(size=ht*0.25),
          legend.position="bottom")

pdf("example_phylo_w_orgs.pdf",width=wd,height=ht)
print(plo)
dev.off()

