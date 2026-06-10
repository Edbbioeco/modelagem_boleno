# Pacotes ----

library(geobr)

library(tidyverse)

library(CDSE)

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
