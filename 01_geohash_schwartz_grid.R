library(dplyr)
library(tidyr)
library(data.table)

# download and read in latest grid file from jeff/heike
system2("aws", "s3 cp s3://geomarker/schwartz/USGrid_Sites_1km_20200618.csv USGrid_Sites_1km_20200618.csv")

# read in grid centroids
d_grid <-
  readr::read_csv('USGrid_Sites_1km_20200618.csv', col_types = "cdd") %>%
  sf::st_as_sf(coords = c('lon', 'lat'), crs = 4326)

## geohash
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
