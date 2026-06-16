# Pacotes ----

library(rgbif)

library(tidyverse)

library(writexl)

# Registros ----

## Baixar ----

registros <- rgbif::occ_data(scientificName = "Trachylepis atlantica",
                             hasCoordinate = TRUE,
                             limit = 1e4) %>%
  .$data

## Visualizar ----

registros

registros |> dplyr::glimpse()
