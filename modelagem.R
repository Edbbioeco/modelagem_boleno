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
