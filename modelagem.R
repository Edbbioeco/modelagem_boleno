# PAcotes ----

library(readxl)

library(tidyverse)

library(terra)

library(tidyterra)

library(sf)

library(usdm)

library(sdm)

# Dados ----

## Registros ----

### Importar ----

registros <- readxl::read_xlsx("registros.xlsx")

### Visualizar ----

registros

registros |> dplyr::glimpse()

### Tratar ----

registros_vect <- registros[c(1, 4, 6, 8, 11, 13, 14), ] |>
  dplyr::rename("sp" = 1) |>
  dplyr::mutate(sp = "Trachylepis_atlantica") |>
  terra::vect()

registros_vect

## Variáveis bioclimáticas ----

### Importar ----

rasters <- purrr::map(list.files(path = "./rasters/",
                      full.names = TRUE,
                      recursive = TRUE),
           terra::rast) |>
  terra::rast()

### Visualizar ----

names(rasters) <- c(paste0("Bio0", 1:9),
                    paste0("Bio", 10:19),
                    "NDVI")

rasters

purrr::map(seq(1, terra::nlyr(rasters), 1),
           purrr::in_parallel(

             ~ggplot() +
               tidyterra::geom_spatraster(data = rasters[[.x]]) +
               scale_fill_viridis_c(na.value = "transparent") +
               facet_wrap(~lyr)

             ),
           .progress = TRUE)

# Modelagem ----

## Objeto sdmData ----

sdmdata <- sdm::sdmData(sp ~ .,
                        train = registros_vect,
                        predictors = rasters,
                        bg = list(method = "gRandom", n = 1000))

sdmdata
