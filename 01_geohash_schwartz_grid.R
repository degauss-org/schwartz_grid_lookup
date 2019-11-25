library(tidyverse)
library(sf)

d_grid <-
  readRDS('USGridSite.rds') %>%
  as_tibble() %>%
  rename(x = Lon, y = Lat) %>%
  ## filter(x > -126 & x < -67,
  ##        y > 24 & y < 50) %>%
  sf::st_as_sf(coords = c('x', 'y'), crs = 4326)

# 11,218,022 rows
# SiteCode is a character made up of numbers, 12 digits long
# bounding box for US in lat/lon would be ((-126, 24) - (-67, 50))

## create geohash
d_grid <- d_grid %>%
 mutate(gh5 = lwgeom::st_geohash(d_grid, precision = 5))

## create site_index to use for lookup in date files
d_grid <- d_grid %>%
  mutate(site_index = 1:nrow(d_grid))

## export all for lookup in downstream code
saveRDS(d_grid, 'schwartz_grid_geohashed.rds')
