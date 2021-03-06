# This file contains R code to generate plots specific to the analysis for Cichlidae and the assosiated paper.

library(tidyverse)
library(ggplot2)
library(Biostrings)

# For mapping
library(OpenStreetMap)
library(DT)
library(RColorBrewer)
library(mapproj)
library(sf)
library(RgoogleMaps)
library(scales)
library(rworldmap)
library(maps)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)
library(ggspatial)
library(maptools)
library(leaflet)
library(sf)
library(tmap)
library(here)
library(rgdal)
library(scales)
library(flextable)
library(ggmap)

COLORS <- c("#003f5c", "#595959", "#58508d", "#bc5090", "#ff6361", "#ffa600")

# Folders
DATA.DIR <- "data"
DATA.DIR.RAW <- paste0(DATA.DIR, "/raw")
DATA.DIR.INTERIM <- paste0(DATA.DIR, "/interim")

## Distribution of input data - sequences, metadata

# Meta data
file.info <- paste0(DATA.DIR.INTERIM, "/bold_cichlidae_COI-5P_info_iucn.tsv")
df.info <- read.delim2(file.info) 
df.info <- df.info %>% 
  mutate_if(is.character, list(~na_if(.,""))) %>%
  mutate_if(is.character, ~replace(., is.na(.), "Not Evaluated"))

df.info$iucn <- as.factor(df.info$iucn)

# Find number of species that don't have ANY conservation status in at least 1 sample
df.info %>%
  filter(iucn == "Not Evaluated") %>%
  select(species_name) %>%
  unique() %>%
  count()

# Distributions of IUCN
ggplot(df.info, aes(x=fct_infreq(iucn))) +
  geom_bar(fill = COLORS) +
  geom_text(stat='count', aes(label=..count..), vjust=0) +
  ylab("Number of Sequence Samples") +
  xlab("Conservation Status") +
  ggtitle("") +
  theme_minimal()

# Distributions of IUCN by genus
df.info %>%
  filter(iucn != "Data deficient (DD)") %>%
  filter(iucn != "Not Evaluated") %>%
  filter(iucn != "Least Concern (LC)") %>%
  ggplot(., aes(x=fct_infreq(iucn), fill = genus_name)) +
    geom_bar() +
    ylab("Number of Sequence Samples") +
    xlab("Conservation Status") +
    ggtitle("") +
    theme_minimal() +
    theme(legend.position="bottom") +
    scale_fill_discrete(name = "Genus")

 # Map IUCN distribution on world map
worldmap <- getMap(resolution = "coarse")
plot(worldmap, xlim = c(-80, 160), ylim = c(-50, 100), 
     asp = 1, bg = "white", col = "grey", fill = T)
palette(COLORS)
points(df.info$lon, df.info$lat, 
       col = df.info$iucn, cex = 1)


# Sequences
file.seqs <- paste0(DATA.DIR.RAW, "/bold_cichlidae_COI-5P_seq.fasta")
fasta.seqs <- readDNAStringSet(file.seqs)
  