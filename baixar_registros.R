# Pacotes ----

library(rgbif)

library(tidyverse)

library(geobr)

library(sf)

library(spThin)

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
             )

# Sahpefile de Fernando de Noronha ----

## Importar ----

fdn <- geobr::read_municipality(year = 2019) |>
  dplyr::filter(name_muni == "Fernando de Noronha")

## Visualizar ----

fdn

ggplot() +
  geom_sf(data = fdn, color = "black")

# Recortar os registros para Fernando de Noronha ----

registros_sf <- registros |>
  dplyr::select(scientificName, decimalLongitude, decimalLatitude) |>
  sf::st_as_sf(coords = c("decimalLongitude", "decimalLatitude"),
               crs = fdn |> sf::st_crs()) |>
  sf::st_intersection(fdn)

registros_sf

ggplot() +
  geom_sf(data = fdn, color = "black") +
  geom_sf(data = registros_sf, color = "black")
