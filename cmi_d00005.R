library(ggtree)
library(treeio)
library(tidyverse)

tree <- read.newick("results/Example1_Cmi_root_d00005.nwk")

#Load strain metadata
metadata <- readr::read_tsv("data/Experiment_Design_example_1.tsv")
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
readr::write_tsv(metadata_ordered, "metada_ordered_example1.tsv")
metadata_ordered <- readr::read_tsv("metada_ordered_example1.tsv")

# tree$tip.label <- metadata_ordered$Strain


#Convert tree information to tibble object and add metadata
treetib<-as_tibble(tree)
treetib<-left_join(treetib, metadata_ordered, by = c('label'))

tree_cm <- as.treedata(treetib)

tree_cm

# State plot

p <- ggtree(tree_cm, ladderize = TRUE, layout = "circular") + 
  geom_tiplab(aes(label = Strain, angle = angle),
              linesize = .07, size = 4, align = TRUE, offset = 0.001) +
  geom_tippoint(aes(color = Country), size = 5, shape = 20) +
  geom_tippoint(aes(shape = Source), size = 5, alpha = 0.5) +
  scale_shape_manual(values = c(18, 1, 18)) +
  labs(shape = "Source")+ geom_rootpoint(col="red") +
  scale_color_manual(values = c("#375c5d", "#b360a3", "darkred", "darkcyan",
                                "#a5a436", "#36a540", "#365ba5", "#0cf3f3",
                                "#0cf31e", "#e87c09", "#e80917", "#f81df1",
                                "darkblue", "darkgrey", "#1df83b", "#d65c40",
                                "#40d689", "grey", "brown", "green", "pink",
                                "orange"))


matrix_heatmap <- data.frame(metadata_ordered %>% 
                               select(Estado))


rownames(matrix_heatmap) <- make.unique(metadata_ordered$label)

# Add heatmap
pphy <- gheatmap(p, matrix_heatmap, width=0.05, 
                 colnames=FALSE, legend_title="State", color = NA, ) +
  theme(text = element_text(size = 15),
        legend.position = c(1.14,0.5), 
        # plot.margin = margin(t = 50, r = 10, b = 50, l = 10)
  ) +
  scale_fill_manual(values = c("#d65c40", "#f81df1", "#e80917", "blue",
                               "yellow", "#36a540", "darkblue", "#0cf3f3",
                               "#0cf31e", "#e87c09", 
                               "darkblue", "darkgrey", 
                               "#40d689", "grey")) +
  labs(fill = "Mexican State")



# Guardar el gráfico en PNG
ggsave(
  filename = "results/Cmi_root_d00005/Cmi_root_d00005_states.png",
  plot = pphy,
  dpi = 300,
  width = 350,   # Ancho en mm
  height = 240,  # Alto en mm
  units = "mm"
)

# Assembly Level plot

p <- ggtree(tree_cm, ladderize = TRUE, layout = "circular") + 
  geom_tiplab(aes(label = Strain, angle = angle),
              linesize = .07, size = 5, align = TRUE, offset = 0.001) +
  geom_tippoint(aes(color = Estado), size = 5, shape = 20) +
  geom_tippoint(aes(shape = Source), size = 5, alpha = 0.5) +
  scale_shape_manual(values = c(18, 1, 18)) +
  labs(shape = "Source")+ geom_rootpoint(col="red") +
  scale_color_manual(values = c("#375c5d", "#b360a3", "darkred", "darkcyan",
                                "#a5a436", "#36a540", "#365ba5", "#0cf3f3",
                                "#0cf31e", "#e87c09", "#e80917", "#f81df1",
                                "darkblue", "darkgrey", "#1df83b", "#d65c40",
                                "#40d689", "grey", "brown", "green", "pink",
                                "orange"))


matrix_heatmap <- data.frame(metadata_ordered %>% 
                               select(Assembly_level))


rownames(matrix_heatmap) <- make.unique(metadata_ordered$label)

# Add heatmap
pphy_2 <- gheatmap(p, matrix_heatmap, width=0.05, 
                   colnames=FALSE, legend_title="State", color = NA, ) +
  theme(text = element_text(size = 15),
        legend.position = c(1.09,0.5), 
        # plot.margin = margin(t = 50, r = 10, b = 50, l = 10)
  ) +
  scale_fill_manual(values = c("darkred",
                               "#f81df1", "#e87c09", "#0cf3f3",
                               "#0cf31e", 
                               "darkblue", "darkgrey", 
                               "#40d689", "grey")) +
  labs(fill = "Assembly Level")


# Guardar el gráfico en PNG
ggsave(
  filename = "results/Cmi_root_d00005/Cmi_root_d00005_AssemblyLevel.png",
  plot = pphy_2,
  dpi = 300,
  width = 400,   # Ancho en mm
  height = 300,  # Alto en mm
  units = "mm"
)


## Vertical Tree
metadata_ordered$Estado <- ifelse(is.na(metadata_ordered$Estado),"",metadata_ordered$Estado)

metadata <- metadata_ordered %>%
  mutate(newlabel = ifelse(Source == "Cliente", 
                           ifelse(Estado == "" | is.na(Estado), 
                                  paste0(Strain, "_", Country, "_+"),  # Sin "|", ya que Estado está vacío
                                  paste0(Strain, "_", Country, "|", Estado, "_+")  # Con "|Estado"
                           ), 
                           ifelse(Estado == "" | is.na(Estado), 
                                  paste0(Strain, "_", Country),  # Sin "|", porque Estado está vacío
                                  paste0(Strain, "_", Country, "|", Estado)  # Con "|Estado"
                           )))

metadata$newlabel <- gsub("-", "_", metadata$newlabel)
metadata$newlabel <- gsub("[()]", "", metadata$newlabel) # Eliminar paréntesis
# Normalizar nombres: guiones "-" a guiones bajos "_"
metadata$newlabel <- gsub("-", "_", metadata$newlabel)

# Eliminar otros caracteres problemáticos (opcional)
metadata$newlabel <- gsub("[.]", "", metadata$newlabel)  # Eliminar puntos
metadata$newlabel <- gsub(" ", "_", metadata$newlabel) 
metadata$newlabel <- gsub(":", "_", metadata$newlabel) 

tree <- read.newick("results/Example1_Cmi_root_d00005.nwk")
tree$tip.label <- metadata$newlabel[match(tree$tip.label, metadata$label)]
t1 <- ggtree(tree) +
  geom_rootpoint(col="red")+
  geom_tiplab()+
  theme(text = element_text(size=13)) 

ggsave(
  filename = "results/Cmi_root_d00005/Cmi_root_d00005_verticalTree.png",
  plot = t1,
  dpi = 300,
  width = 800,   # Ancho en mm
  height = 290,  # Alto en mm
  units = "mm"
)
