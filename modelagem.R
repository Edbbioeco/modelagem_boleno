# PAcotes ----

library(readxl)

library(tidyverse)

library(sf)

library(terra)

library(tidyterra)

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
  terra::vect()

registros_vect
