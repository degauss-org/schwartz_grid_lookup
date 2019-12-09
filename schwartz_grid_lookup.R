#!/usr/local/bin/Rscript

library(dplyr)
library(tidyr)
library(sf)

doc <- '
Usage:
  schwartz_grid_lookup.R <filename>
'

opt <- docopt::docopt(doc)
## for testing
## opt <- docopt::docopt(doc, args = 'my_address_file_geocoded.csv')

raw_data <- readr::read_csv(opt$filename)

## prepare data for calculations
raw_data$.row <- seq_len(nrow(raw_data))

d <-
  raw_data %>%
  select(.row, lat, lon) %>%
  na.omit() %>%
  group_by(lat, lon) %>%
  nest(.rows = c(.row)) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326)

message('loading geohashed schwartz grid site indices...')
d_grid <- readRDS('/app/schwartz_grid_geohashed.rds')

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
    st_distance(query_point, nearby_points, by_element = TRUE) %>%
    which.min()
  nearby_points %>%
    slice(which_nearest) %>%
    pull('site_index')
}

## get_closest_grid_site_index(query_point = pluck(d$geometry, 1))

## apply across all rows to get site indices
message('finding closest schwartz grid site index for each point...')
d <- d %>%
  mutate(site_index = CB::mappp(d$geometry, get_closest_grid_site_index, parallel = TRUE)) %>%
  unnest(cols = c(site_index))

## merge back on .row after unnesting .rows into .row
d <- d %>%
  unnest(cols = c(.rows)) %>%
  st_drop_geometry()

out <- left_join(raw_data, d, by = '.row') %>% select(-.row)

out_file_name <- paste0(tools::file_path_sans_ext(opt$filename), '_schwartz_site_index.csv')

readr::write_csv(out, out_file_name)
