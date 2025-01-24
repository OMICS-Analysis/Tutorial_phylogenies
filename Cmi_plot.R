library(ggtree)
library(treeio)
library(tidyverse)

tree <- read.newick("Cmi_cut_reroot.nwk")

#Load strain metadata
metadata <- readr::read_tsv("Experiment_Design_example_1.tsv")
metadata <- metadata %>%
  rename(label = Assembly.Accession)  # Para coincidir con etiquetas del árbol
metadata$Source<-ifelse(is.na(metadata$Source),"RefSeq",metadata$Source)

metadata_ordered <- metadata %>%
  filter(label %in% tree$tip.label) %>%
  arrange(match(label, tree$tip.label))

metadata_ordered <- metadata_ordered %>%
  mutate(Country = str_extract(Location, "^[^:]+"))

# Create Estado column
metadata_ordered <- metadata_ordered %>%
  mutate(Estado = ifelse(grepl("Mexico", Location), str_extract(Location, "(?<=:)[^:]+"), NA))

# Fix manual "Estado"
# readr::write_tsv(metadata_ordered, "metada_ordered_example1.tsv")
metadata_ordered <- readr::read_tsv("metada_ordered_example1.tsv")

#Convert tree information to tibble object and add metadata
treetib<-as_tibble(tree)
treetib<-left_join(treetib, metadata_ordered, by = 'label')

tree_cm <- as.treedata(treetib)


p <- ggtree(tree_cm, ladderize = TRUE, layout = "circular") + 
  geom_tiplab(aes(label = label, angle = angle),
              linesize = .07, size = 5, align = TRUE, offset = 0.001) +
  geom_tippoint(aes(color = Country), size = 5, shape = 20) +
  geom_tippoint(aes(shape = Source), size = 5, alpha = 0.5) +
  scale_shape_manual(values = c(18, 1, 18)) +
  labs(shape = "Source")+ geom_rootpoint(col="red") +
  scale_color_manual(values = c("#375c5d", "#b360a3", "darkred", "darkcyan",
                                "#a5a436", "#36a540", "#365ba5", "#0cf3f3",
                                "#0cf31e", "#e87c09", "#e80917", "#f81df1",
                                "darkblue", "darkgrey", "#1df83b", "#d65c40",
                                "#40d689", "grey"))

matrix_heatmap <- data.frame(metadata_ordered %>% 
                               select(Estado))


rownames(matrix_heatmap) <- make.unique(metadata_ordered$label)

# Add heatmap
gheatmap(p, matrix_heatmap, width=0.05, 
         colnames=FALSE, legend_title="State", color = NA, ) +
  theme(text = element_text(size = 20),
       legend.position = c(1.14,0.5), 
       plot.margin = margin(t = 50, r = 10, b = 50, l = 10)) +
  scale_fill_manual(values = c("#d65c40", "#f81df1", "#e80917", "blue",
                                "yellow", "#36a540", "darkblue", "#0cf3f3",
                                "#0cf31e", "#e87c09", 
                                "darkblue", "darkgrey", 
                                "#40d689", "grey")) +
  labs(fill = "Mexican State")


legend.position = c(1.35,0.5), 
,
plot.margin = margin(t = 50, r = 10, b = 50, l = 10)