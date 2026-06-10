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
