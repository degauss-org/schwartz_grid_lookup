library(tidyverse)
library(sf)

d_grid <- readRDS('schwartz_grid_geohashed.rds')

## setup test input data
d_locs <-
  tibble::tribble(
            ~id,         ~lon,        ~lat,    ~ start_date,
            809089L, -84.69127387, 39.24710734, '2014-06-04',
            813233L, -84.47798287, 39.12005904, '2012-12-04',
            814881L, -84.47123583,  39.2631309, '2006-08-15',
            799697L, -84.41741798, 39.18541228, '2001-01-28',
            799698L, -84.41395064, 39.18322447, '2006-08-11',
          ) %>%
  mutate(start_date = as.Date(start_date)) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326) %>%
  mutate(end_date = start_date + 30)

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

## outputs list of pm values for site index, start and end dates
read_dates_for_an_index <- function(site_index, start_date, end_date) {
  dates <- seq.Date(from = as.Date(start_date),
                    to = as.Date(end_date),
                    by = 1)
  dates_file_names <- paste0('./pm_fst/', dates, '.fst')
  map_dbl(dates_file_names, ~ fst::read_fst(path = .,
                                            columns = 'pm',
                                            from = site_index,
                                            to = site_index)$pm)
}

read_dates_for_a_grid(site_index = 9616130,
                      start_date = '2014-12-14',
                      end_date = '2014-12-31')

d_locs <- d_locs %>%
  mutate(pm = pmap(list(site_index, start_date, end_date), read_dates_for_a_grid))


##### try one using aws s3 (only for 2000 - 2001 right now)

