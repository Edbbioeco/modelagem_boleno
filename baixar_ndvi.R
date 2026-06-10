# Pacotes ----

library(geobr)

library(tidyverse)

library(CDSE)

library(rsi)

library(terra)

library(tidyterra)

# Shapefile ----

## Baixar ----

br <- geobr::read_country(year = 2019)

#@ Visualizar ----

br

ggplot() +
  geom_sf(data = br, color = "black")

# Raster de NDVI ----

## Autenticar cliente ----

cliente <- CDSE::GetOAuthClient(id = Sys.getenv("CDSE_ID"),
                                secret = Sys.getenv("CDSE_SECRET"))

cliente

## Checar catálogo ----

catalogo <- CDSE::SearchCatalog(aoi = br,
                                from = "2020-01-01",
                                to = "2026-01-01",
                                collection = "sentinel-2-l2a",
                                with_geometry = FALSE,
                                client = cliente)

catalogo
