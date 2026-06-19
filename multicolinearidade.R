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

### Transformar em shapefile ----

registros_sf <- registros |>
  sf::st_as_sf(coords = c(2:3),
               crs = 4326)

registros_sf

ggplot() +
  geom_sf(data = registros_sf)

## Variáveis ambientais ----

### Variáveis bioclimáticas ----

#### Importar ----

bio <- terra::rast("./rasters/bioclim/bioclim.tif")

#### Visualizar ----

bio

purrr::map(1:19,
           purrr::in_parallel(

             ~ggplot() +
               tidyterra::geom_spatraster(data = bio[[.x]]) +
               scale_fill_viridis_c(na.value = "transparent") +
               labs(title = paste0("Bio", .x))

             ),
           .progress = TRUE)

### NDVI ----

#### Importar ----

ndvi <- terra::rast("./rasters/ndvi/ndvi.tif")

#### Visualizar ----

ndvi

ggplot() +
  tidyterra::geom_spatraster(data = ndvi) +
  scale_fill_viridis_c(na.value = "transparent")

### Unir os dados ----

rasters <- c(bio, ndvi)

names(rasters) <- c(paste0("Bio0", 1:9),
                    paste0("Bio", 10:19),
                    "NDVI")

rasters

purrr::map2(seq(1, terra::nlyr(rasters), 1),
            names(rasters),
            purrr::in_parallel(

              ~ggplot() +
                tidyterra::geom_spatraster(data = rasters[[.x]]) +
                scale_fill_viridis_c(na.value = "transparent") +
                labs(title = .y)

              ),
           .progress = TRUE)

# Multicolinearidade ----

## Extrair valores ----

valores <- rasters |>
  terra::extract(registros_sf) |>
  tidyr::drop_na()

valores

## Matriz de correlação ----

cor_matriz <- valores |>
  dplyr::select(-1) |>
  cor(method = "spearman") |>
  as.matrix()

cor_matriz

### Gráfico ----

cor_matriz[cor_matriz |> upper.tri()] <- NA

cor_matriz

cor_matriz |>
  reshape2::melt() |>
  dplyr::filter(Var1 != Var2) |>
  tidyr::drop_na() |>
  dplyr::mutate(value = value |> round(2)) |>
  ggplot(aes(Var1, Var2, fill = value, label = value)) +
  geom_tile(color = "black", linewidth = 1) +
  geom_text(color = "black", size = 5, fontface = "bold") +
  coord_equal() +
  scale_fill_gradientn(limits = c(-1, 1),
                       colours = c(viridis::viridis(n = 10) |> rev(),
                                   viridis::viridis(n = 10)),
                       guide = guide_colourbar(
                         title = "Spearman Correlation Index",
                         title.position = "top",
                         title.hjust = 0.5,
                         barwidth = 20,
                         frame.colour = "black",
                         ticks.colour = "black",
                         ticks.linewidth = 1)
                       ) +
  labs(x = NULL,
       y = NULL) +
  theme_bw() +
  theme(axis.text = element_text(color = "black", size = 20),
        axis.text.x = element_text(angle = 90, vjust = 0.5),
        legend.title = element_text(color = "black", size = 20),
        legend.text = element_text(color = "black", size = 20),
        legend.position = "bottom",
        panel.border = element_rect(color = "black", linewidth = 1)) +
  ggview::canvas(height = 12, width = 14)

## Escolher variáveis ----

vars <- c(3, 4, 13, 14, 16, 17, 18, 19, 20)

vars <- purrr::map_chr(vars,
                       ~if(.x < 10){

                         paste0("Bio0", .x)

                         } else if(.x |> dplyr::between(10, 19)){

                           paste0("Bio", .x)

                           } else {

                             "NDVI"

                             }

                       )

vars

cor_matriz |>
  reshape2::melt() |>
  dplyr::filter(Var1 != Var2) |>
  dplyr::filter(Var1 %in% vars & Var2 %in% vars) |>
  tidyr::drop_na() |>
  dplyr::mutate(value = value |> round(2)) |>
  ggplot(aes(Var1, Var2, fill = value, label = value)) +
  geom_tile(color = "black", linewidth = 1) +
  geom_text(color = "black", size = 5, fontface = "bold") +
  coord_equal() +
  scale_fill_gradientn(limits = c(-1, 1),
                       colours = c(viridis::viridis(n = 10) |> rev(),
                                   viridis::viridis(n = 10)),
                       guide = guide_colourbar(
                         title = "Spearman Correlation Index",
                         title.position = "top",
                         title.hjust = 0.5,
                         barwidth = 20,
                         frame.colour = "black",
                         ticks.colour = "black",
                         ticks.linewidth = 1)
  ) +
  labs(x = NULL,
       y = NULL) +
  theme_bw() +
  theme(axis.text = element_text(color = "black", size = 20),
        axis.text.x = element_text(angle = 90, vjust = 0.5),
        legend.title = element_text(color = "black", size = 20),
        legend.text = element_text(color = "black", size = 20),
        legend.position = "bottom",
        panel.border = element_rect(color = "black", linewidth = 1)) +
  ggview::canvas(height = 12, width = 14)
