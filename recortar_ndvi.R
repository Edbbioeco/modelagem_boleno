# Pacotes ----

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

# Shapefile dos biomas ----

## Importar ----

biomas <- sf::st_read("lml_bioma_e250k_v20250911_A.shp")

## Visualizar ----

biomas

ggplot() +
  geom_sf(data = biomas, color = "black")
