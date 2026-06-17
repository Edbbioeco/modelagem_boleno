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
               scale_fill_viridis_c(na.value = "transparent")

             ),
           .progress = TRUE)
