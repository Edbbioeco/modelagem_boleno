# Pacotes ----

library(sf)

library(tidyverse)

library(geodata)

library(tidyterra)

library(terra)

# Shapefile dos biomas ----

## Importar ----

biomas <- sf::st_read("lml_bioma_e250k_v20250911_A.shp")

## Visualizar ----

biomas

ggplot() +
  geom_sf(data = biomas, color = "black")

# Variáveis bioclimáticas ----

## Baixar ----

bio <- geodata::worldclim_country(country = "BRA",
                                  var = "bio",
                                  res = 0.5,
                                  path = tempdir())

## Visualizar ----

bio

ggplot() +
  tidyterra::geom_spatraster(data = bio[[1]]) +
  scale_fill_viridis_c(na.value = "transparent")

## Recortar para a Mata Atlântica ----

bio_cort <- bio |>
  terra::crop(biomas |>
                dplyr::filter(NM_BIOMA == "Mata Atlântica")) |>
  terra::mask(biomas |>
                dplyr::filter(NM_BIOMA == "Mata Atlântica"))

bio_cort

ggplot() +
  tidyterra::geom_spatraster(data = bio_cort[[1]]) +
  scale_fill_viridis_c(na.value = "transparent")
