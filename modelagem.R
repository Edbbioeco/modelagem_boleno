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

## Criar multiplos modelos para os diferentes algorítimos ----

modelos <- sdm::sdm(Trachylepis_atlantica ~ .,
                    data = sdmdata,
                    methods = c("gam",
                                "glm",
                                "maxent",
                                "maxlike"),
                    replication = "sub",
                    test.percent = 30,
                    n = 10)

modelos

## Exportar modelo ----

modelos |> sdm::write.sdm("modelo.sdm")

modelo <- sdm::read.sdm("modelo.sdm")

## Selecionar os melhores modelos de cada algorírimo ----

ind_modelos <- purrr::map_dbl(modelos,
                              purrr::in_parallel(

                                ~.x |>
                                  sdm::getEvaluation() |>
                                  dplyr::arrange(AUC |> dplyr::desc(),
                                                 TSS |> dplyr::desc()) |>
                                  dplyr::slice(1) |>
                                  dplyr::pull(modelID)

                                ),
                              .progress = TRUE) |>
  setNames(c("gam",
             "glm",
             "maxent",
             "maxlike"))

ind_modelos
