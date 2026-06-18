# Pacotes ----

library(geobr)

library(sf)

library(tidyverse)

library(terra)

library(tidyterra)

# Fernando de Noronha ----

## Importar ----

fdn <- geobr::read_municipality(year = 2019) |>
  dplyr::filter(name_muni == "Fernando de Noronha")

## Visualizar ----

fdn

ggplot() +
  geom_sf(data = fdn, color = "black")

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

# Tratar raster ----

## Mata Atlântica ----

### Recortar ----

ndvi_cort <- ndvi |>
  terra::crop(biomas |>
                dplyr::filter(NM_BIOMA == "Mata Atlântica")) |>
  terra::mask(biomas |>
                dplyr::filter(NM_BIOMA == "Mata Atlântica"))

ndvi_cort

ggplot() +
  tidyterra::geom_spatraster(data = ndvi_cort) +
  scale_fill_viridis_c(na.value = "transparent",
                       limits = c(-1, 1))


### Reamostrar ----

ndvi_cort <- ndvi_cort |>
  terra::resample(terra::rast("./rasters/bioclim/bioclim.tif"))

ndvi_cort

ggplot() +
  tidyterra::geom_spatraster(data = ndvi_cort) +
  scale_fill_viridis_c(na.value = "transparent",
                       limits = c(-1, 1))

### Exportar ----

dir.create("./rasters/ndvi")

ndvi_cort |> terra::writeRaster(filename = "rasters/ndvi/ndvi.tif")

## Fernando de Noronha ----

### Recortar ----

ndvi_fdn <- ndvi |>
  terra::crop(fdn |>
                sf::st_concave_hull(ratio = 0.3)) |>
  terra::mask(fdn |>
                sf::st_concave_hull(ratio = 0.3))

ndvi_fdn

ggplot() +
  tidyterra::geom_spatraster(data = ndvi_fdn) +
  scale_fill_viridis_c(na.value = "transparent",
                       limits = c(-1, 1))
