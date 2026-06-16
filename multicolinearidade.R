# Pacotes ----

library(readxl)

library(tidyverse)

library(terra)

library(tidyterra)

library(sf)

library(reshape2)

library(ggview)

# Dados ----

## Registros ----

### Importar ----

registros <- readxl::read_xlsx("registros.xlsx")

### Visualizar ----

registros

registros |> dplyr::glimpse()
