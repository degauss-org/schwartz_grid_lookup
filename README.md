# lookup for schwartz spatiotemporal models

## overview

- the red dot below is the query point
- its surrounding box is what is was geohashed to (precision = 6)
- neighborhing boxes are added
- schwartz "grid" points that are geohashed within these boxes are extracted
- points are projected to epsg 5072 and the index of the point closest to the query point is returned

![example_schwartz_lookup](example_schwartz_lookup.png)

## geomarker data

- `01_convert_schwartz_data.R` downloads all RDS files from google drive and saves them locally as FST files; these are available in `s3://dropbox.grapph/schwartz/pm/`
- "grid" points found in `USGridSite.rds` (available at: `s3://dropbox.grapph/schwartz/pm/`); run `02_geohash_schwartz_grid.R` to create `schwartz_grid_geohashed.rds`
