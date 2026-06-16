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

# Filtrar registros ----

## Filtrar para 1km ----

spThin::thin(registros_sf |>
               sf::st_drop_geometry() |>
               dplyr::mutate(longitude = registros_sf |>
                               sf::st_coordinates() |>
                               as.data.frame() |>
                               dplyr::select(1),
                             latitude = registros_sf |>
                               sf::st_coordinates() |>
                               as.data.frame() |>
                               dplyr::select(2)),
             thin.par = 1,
             reps = 10,
             long.col = "longitude",
             lat.col = "latitude",
             spec.col = "scientificName",
             out.dir = getwd())

## Visualizar ----

registros_thin <- readr::read_csv("thinned_data_thin1.csv") |>
  dplyr::select(-2) |>
  tidyr::separate(col = 2,
                  sep = ",",
                  into = c("longitude", "latitude")) |>
  dplyr::mutate(dplyr::across(.cols = dplyr::contains("itude"),
                              .fns = ~as.numeric(.)))

registros_thin

registros_thin |> dplyr::glimpse()

ggplot() +
  geom_sf(data = fdn, color = "black") +
  geom_point(data = registros_thin,
             aes(longitude, latitude))
