library(tidyverse)
library(sf)

d_grid <- readRDS('schwartz_grid_geohashed.rds')

## setup test input data
d_locs <-
  tibble::tribble(
            ~id,         ~lon,        ~lat,
            809089L, -84.69127387, 39.24710734,
            813233L, -84.47798287, 39.12005904,
            814881L, -84.47123583,  39.2631309,
            799697L, -84.41741798, 39.18541228,
            799698L, -84.41395064, 39.18322447,
          ) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326) %>%

## create a row index on the input data
d_locs$.row <- 1:nrow(d_locs)

## takes row index (for d_locs) and outputs nearest site index
get_closest_grid_site_index <- function(.row_index) {
  query_point <- d_locs[d_locs$.row == .row_index, ]
  query_gh6 <- lwgeom::st_geohash(query_point, precision = 6)
  query_gh6_and_neighbors <- geohashTools::gh_neighbors(query_gh6, self = TRUE)
  nearby_indices <- which(d_grid$gh6 %in% query_gh6_and_neighbors)
  nearby_points <- d_grid[nearby_indices, ]
  nearest_site_index <-
    st_join(st_transform(query_point, 5072),
            st_transform(nearby_points, 5072),
            join = st_nearest_feature) %>%
    pull('site_index')
  return(nearest_site_index)
}

## use the below code to generate illustrative map *while within the function environment*
## geohashTools::gh_to_sf(query_gh6_and_neighbors) %>%
##   mapview::mapview() +
##   mapview::mapview(query_point, color = 'red') +
##   mapview::mapview(nearby_points) +
##   mapview::mapview(nearby_points[nearby_points$site_index == nearest_site_index, 'geometry'], color = 'green')

## get_closest_grid_site_index(3)
## map_dbl(d_locs$.row, get_closest_grid_site_index)

## apply across all rows to get site indices
d_locs <- d_locs %>%
  mutate(site_index = CB::mappp(d_locs$.row, get_closest_grid_site_index)) %>%
  unnest(cols = c(site_index))
