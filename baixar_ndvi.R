# Pacotes ----

library(sf)

library(tidyverse)

library(CDSE)

library(rsi)

library(terra)

library(tidyterra)

# Shapefile da Mata Atlântica ----

## Importar ----

ma <- sf::st_read("lml_bioma_e250k_v20250911_A.shp") |>
  dplyr::filter(NM_BIOMA == "Mata Atlântica")

#@ Visualizar ----

ma

ggplot() +
  geom_sf(data = ma, color = "black")

## Divdir aos estados ----

### Shapefile dosn estados ----

estados <- sf::st_read("BR_UF_2025.shp")

estados

ggplot() +
  geom_sf(data = estados, color = "black")

### Intersecção da Mata Atlântica ----

ma_int <- ma |>
  sf::st_intersection(estados)

ma_int

ggplot() +
  geom_sf(data = ma_int, color = "black")

# Raster de NDVI ----

## Autenticar cliente ----

cliente <- CDSE::GetOAuthClient(id = Sys.getenv("CDSE_ID"),
                                secret = Sys.getenv("CDSE_SECRET"))

cliente

## Checar catálogo ----

catalogo <- CDSE::SearchCatalog(aoi = ma |>
                                  sf::st_bbox() |>
                                  sf::st_as_sfc(),
                                from = "2025-01-01",
                                to = "2026-01-01",
                                collection = "sentinel-2-l2a",
                                with_geometry = FALSE,
                                client = cliente,
                                filter = "eo:cloud_cover < 0.1")

catalogo

catalogo |> dplyr::glimpse()

## Período ----

periodo <- catalogo |>
  dplyr::mutate(ano = acquisitionDate |> lubridate::year(),
                mes = acquisitionDate |> lubridate::month()) |>
  dplyr::filter(ano == 2025,
                mes == 1,
                tileCloudCover == 0) |>
  dplyr::slice_head(n = 1) |>
  dplyr::pull(acquisitionDate)

periodo

## Evalscript ----

evalscript <- rsi::spectral_indices() |>
  dplyr::filter(short_name == "NDVI") |>
  CDSE::MakeEvalScript(constellation = "landsat") |>
  paste(collapse = "\n")

evalscript

## Criar pasta ----

dir.create("./ndvi")

## Baixar a imegem ----

ufs <- ma_int |>
  dplyr::pull(NM_UF)

ufs

purrr::map(ufs,
           purrr::in_parallel(
             ~CDSE::GetImage(bbox = ma_int |>
                               dplyr::filter(NM_UF == .x) |>
                               sf::st_bbox(),
                             time_range = periodo,
                             script = evalscript,
                             file = paste0("./ndvi/", .x, "_ndvi.tif"),
                             collection = "sentinel-2-l2a",
                             format = "image/tiff",
                             mosaicking_order = "leastCC",
                             resolution = 1000,
                             mask = FALSE,
                             buffer = 100,
                             client = cliente)),
           .progress = TRUE)
