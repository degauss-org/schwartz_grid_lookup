library(tidyverse)
library(sf)

d_grid <-
  readRDS('USGridSite.rds') %>%
  as_tibble() %>%
  rename(x = Lon, y = Lat) %>%
  ## filter(x > -126 & x < -67,
  ##        y > 24 & y < 50) %>%
  sf::st_as_sf(coords = c('x', 'y'), crs=4326)

# 11,218,022 rows
# SiteCode is a character made up of numbers, 12 digits long
# bounding box for US in lat/lon would be ((-126, 24) - (-67, 50))

## create geohash
d_grid <-
 d_grid %>%
  mutate(geohash = lwgeom::st_geohash(d_grid, precision = 6))

## there are some duplicates in here!?; e.g.,
## SiteCode              geometry geohash
## * <chr>              <POINT [°]> <chr>  
## 1 060730001 (-117.0591 32.63123) 9muc8k2
## 2 060730001 (-117.0591 32.63123) 9muc8k2
## 3 060730001 (-117.0591 32.63123) 9muc8k2
## 4 CQ093CARB (-117.0592 32.63139) 9muc8k2

## grid_dups <- select(d_grid, geometry) %>% duplicated()
## d_grid <- filter(d_grid, !grid_dups)

## create site_index to use for lookup in date files
d_grid <-
  d_grid %>%
  mutate(site_index = 1:nrow(d_grid))

date_files <-
  list.files('pm_fst', pattern = '.fst', full.names = TRUE)

read_date_for_a_grid <- function(date_file, site_index) {
  fst::read_fst(path = date_file,
                columns = 'pm',
                from = site_index,
                to = site_index) %>%
    .$pm
}

read_date_for_a_grid(date_files[[5232]], site_index = 9391659)

read_all_dates_for_a_grid <- function(site_index){
  map_dbl(date_files, read_date_for_a_grid, site_index = site_index)
}

read_all_dates_for_a_grid(site_index = 9391659)


substr(d_grid$geohash, 1, 4) %>%
  n_distinct()

## this would have to be done 17,472 times (for that many 4 char geohash files)

substr(d_grid$geohash, 1, 5) %>%
  n_distinct()
## 972 times with 3 chars
## 526,882 times with 5 chars

dir.create('schwartz_grid_pm')

system.time({
d_toy_grid <-
  d_grid %>%
  filter(substr(geohash, 1, 5) == 'dng00')

d_toy_grid <-
  d_toy_grid %>%
  mutate(pm = CB::mappp(site_index, read_all_dates_for_a_grid,
                        parallel = TRUE))


## if a geohash is duplicated, then the duplicates will be called:
## xxxxxx.1, xxxxxx.2, xxxxxx.3, etc...
bind_cols(d_toy_grid$pm) %>%
  set_names(make.names(d_toy_grid$geohash, unique = TRUE)) %>%
  fst::write_fst(path = paste0('./schwartz_grid_pm/', 'dng00', '.fst'),
                 compress = 100)
})

## no no no, ... this takes waaay too much compute time
