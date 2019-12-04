library(dplyr)
library(tidyr)
library(sf)

d_grid <- readRDS('schwartz_grid_geohashed.rds')

## setup test input data
raw_data <-
  tibble::tribble(
            ~id,         ~lon,        ~lat,
            809089L, -84.69127387, 39.24710734,
            813233L, -84.47798287, 39.12005904,
            814881L, -84.47123583,  39.2631309,
            814888L, -84.47123583,  39.2631309,
            799697L, -84.41741798, 39.18541228,
            799697L,      NA     , 39.18541228,
            799698L, -84.41395064, 39.18322447,
          )

## prepare data for calculations
raw_data$.row <- seq_len(nrow(raw_data))

d <-
  raw_data %>%
  select(.row, lat, lon) %>%
  na.omit() %>%
  group_by(lat, lon) %>%
  nest(.rows = c(.row)) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326)

## use the below code to generate illustrative map *while within the function environment*
## geohashTools::gh_to_sf(query_gh6_and_neighbors) %>%
##   mapview::mapview() +
##   mapview::mapview(query_point, color = 'red') +
##   mapview::mapview(nearby_points) +
##   mapview::mapview(nearby_points[nearby_points$site_index == nearest_site_index, 'geometry'], color = 'green')

get_closest_grid_site_index <- function(query_point) {
  query_point <- st_sfc(query_point, crs = 4326)
  query_gh6 <- lwgeom::st_geohash(query_point, precision = 6)
  query_gh6_and_neighbors <- geohashTools::gh_neighbors(query_gh6, self = TRUE)
  nearby_indices <- which(d_grid$gh6 %in% query_gh6_and_neighbors)
  nearby_points <- d_grid[nearby_indices, ]
  which_nearest <-
    st_nearest_feature(st_transform(query_point, 5072),
                       st_transform(nearby_points, 5072))
  nearby_points %>%
    slice(which_nearest) %>%
    pull('site_index')
}

## get_closest_grid_site_index(query_point = pluck(d$geometry, 1))

## apply across all rows to get site indices
d <- d %>%
  mutate(site_index = CB::mappp(d$geometry, get_closest_grid_site_index, parallel = TRUE)) %>%
  unnest(cols = c(site_index))

## merge back on .row after unnesting .rows into .row
d <- d %>%
  unnest(cols = c(.rows)) %>%
  st_drop_geometry()

out <- left_join(raw_data, d, by = '.row')
