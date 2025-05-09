# schwartz_grid_lookup

**🛑 _Archived_ 🛑 The cloud files used in this degauss container are not available. Please find newer estimates on SEDAC.**

> given a lat/lon coordinate, this DeGAUSS container returns a `site_index` and a `sitecode`, which are values specifying the nearest "grid" centroid point for the Schwartz spatiotemporal pollutant models

[![Docker Build Status](https://img.shields.io/docker/automated/degauss/schwartz_grid_lookup)](https://hub.docker.com/repository/docker/degauss/schwartz_grid_lookup/tags)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/degauss-org/schwartz_grid_lookup)](https://github.com/degauss-org/schwartz_grid_lookup/releases)

## DeGAUSS example call

```sh
docker run --rm -v $PWD:/tmp degauss/schwartz_grid_lookup:0.4.1 my_address_file_geocoded.csv
```

## geomarker methods

- the red dot below is the query point
- its surrounding box is what is was geohashed to (precision = 6)
- h2 geohashes are used to quickly determine nearby points; this also provides an index to download and extract spatiotemporal exposure estimates (see more details here: https://s2geometry.io/)
- neighboring boxes are added
- schwartz "grid" points that are geohashed within these boxes are extracted
- the index of the point closest to the query point, based on the great circle distance, is returned (highlighted in green)

![example_schwartz_lookup](example_schwartz_lookup.png)

## geomarker data

- script relies on `s3://geomarker/schwartz/schwartz_grid_geohashed.qs`, which is made by running `01_geohash_schwartz_grid.R` on `s3://geomarker/schwartz/USGrid_Sites_1km_20200618.csv`
