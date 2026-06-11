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

# Raster de NDVI ----

## Importar ----]

ndvi <- terra::rast("MOD13A1.061__500m_16_days_NDVI_20191219T000000_aid0001.tif")

## Visualizar ----

ndvi

ggplot() +
  tidyterra::geom_spatraster(data = ndvi) +
  scale_fill_viridis_c(na.value = "transparent")
