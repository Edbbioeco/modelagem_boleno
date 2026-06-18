# Pacotes ----

library(readxl)

library(tidyverse)

library(terra)

library(tidyterra)

library(sf)

library(reshape2)

library(ggview)

# Dados ----

## Registros ----

### Importar ----

registros <- readxl::read_xlsx("registros.xlsx")

### Visualizar ----

registros

registros |> dplyr::glimpse()

### Transformar em shapefile ----

registros_sf <- registros |>
  sf::st_as_sf(coords = c(2:3),
               crs = 4326)

registros_sf

ggplot() +
  geom_sf(data = registros_sf)

## Variáveis ambientais ----

### Variáveis bioclimáticas ----

#### Importar ----

bio <- terra::rast("./rasters/bioclim/bioclim.tif")

#### Visualizar ----

bio

purrr::map(1:19,
           purrr::in_parallel(

             ~ggplot() +
               tidyterra::geom_spatraster(data = bio[[.x]]) +
               scale_fill_viridis_c(na.value = "transparent") +
               labs(title = paste0("Bio", .x))

             ),
           .progress = TRUE)

### NDVI ----

#### Importar ----

ndvi <- terra::rast("./rasters/ndvi/ndvi.tif")

#### Visualizar ----

ndvi

ggplot() +
  tidyterra::geom_spatraster(data = ndvi) +
  scale_fill_viridis_c(na.value = "transparent")

### Unir os dados ----

rasters <- c(bio, ndvi)

names(rasters) <- c(paste0("Bio0", 1:9),
                    paste0("Bio", 10:19),
                    "NDVI")

rasters

purrr::map2(seq(1, terra::nlyr(rasters), 1),
            names(rasters),
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = rasters[[.x]]) +
                scale_fill_viridis_c(na.value = "transparent") +
                labs(title = .y)

              ),
           .progress = TRUE)

# Multicolinearidade ----

## Extrair valores ----

valores <- rasters |>
  terra::extract(registros_sf) |>
  tidyr::drop_na()

valores
