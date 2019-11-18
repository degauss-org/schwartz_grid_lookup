# lookup for schwartz spatiotemporal models

## geomarker data

- `01_convert_schwartz_data.R` downloads all RDS files from google drive and saves them locally as FST files; these are available in `s3://dropbox.grapph/schwartz/pm/`
- "grid" points found in `USGridSite.rds` (available at: `s3://dropbox.grapph/schwartz/pm/`); run `02_geohash_schwartz_grid.R` to create `schwartz_grid_geohashed.rds`
