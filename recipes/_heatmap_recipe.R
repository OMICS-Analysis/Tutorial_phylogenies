library("ggtree")
library("readr")
library("dplyr")

tr<-read.tree("data/example_2_phylo.nwk")

design <- read_tsv("data/Experiment_Design_example_2.tsv")
design<-design %>%  select(Assembly.Accession,Strain,
         Phylogroup,Patotype,Geographic.location,source)

#Design must follow same order than tree tip labels
#In this case the same order of Assembly Accessions GCF_0020201...
design <- design %>%
  filter(Assembly.Accession %in% tr$tip.label) %>%
  arrange(match(Assembly.Accession, tr$tip.label))

#Create a data frame with heatmap data
heat_data <- data.frame(Patotype = as.factor(design$Patotype))

rownames(heat_data) <-design$Assembly.Accession

# Create a ggtree object and add the metadata
p<-ggtree(tr) %<+% design
p<-p + geom_tiplab(label="Strain")
gheatmap(p, heat_data, color="black", width=0.05, colnames=FALSE)
