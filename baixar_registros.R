# Pacotes ----

library(rgbif)

library(tidyverse)

library(geobr)

library(sf)

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

# Sahpefile de Fernando de Noronha ----

## Importar ----

fdn <- geobr::read_municipality(year = 2019) |>
  dplyr::filter(name_muni == "Fernando de Noronha")

## Visualizar ----

ggplot() +
  geom_sf(data = fdn, color = "black")
