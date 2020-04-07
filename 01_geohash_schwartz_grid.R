library(dplyr)
library(tidyr)
library(data.table)

# read in grid taking only the first 11,196,911 rows (grid centroids)
## the last 21,111 extra points are monitoring stations and can be discarded
d_grid <-
  readRDS('USGridSite.rds') %>%
  as_tibble() %>%
  rename(x = Lon, y = Lat) %>%
  slice(1:11196911) %>%
  sf::st_as_sf(coords = c('x', 'y'), crs = 4326)

## create geohash
d_grid <- d_grid %>%
 mutate(gh6 = lwgeom::st_geohash(d_grid, precision = 6))

## create site_index to use for lookup in date files
d_grid <- d_grid %>%
  mutate(site_index = seq_len(nrow(d_grid)))

## index on geohash column using data.table
d_grid_dt <- as.data.table(d_grid, key = 'gh6')

## export all for lookup in downstream code
qs::qsave(d_grid_dt, "schwartz_grid_geohashed.qs")

## save to S3
system2("aws", "s3 cp schwartz_grid_geohashed.qs s3://geomarker/schwartz/schwartz_grid_geohashed.qs")
