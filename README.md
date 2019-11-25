# lookup for schwartz spatiotemporal models

> given a lat/lon coordinate (soon to be an address), this code will return a `site_index`, which is an integer value specifying the nearest "grid point" for the Schwartz spatiotemporal pollutant models

## geohash lookup procedure

- the red dot below is the query point
- its surrounding box is what is was geohashed to (precision = 6)
- neighborhing boxes are added
- schwartz "grid" points that are geohashed within these boxes are extracted
- points are projected to epsg 5072 and the index of the point closest to the query point is returned

![example_schwartz_lookup](example_schwartz_lookup.png)

## geomarker data

- script relies on `schwartz_grid_geohashed.rds` (available at: `s3://grapph/schwartz/schwartz_grid_geohashed.rds`), which is generated by running `01_geohash_schwartz_grid.R`
on `USGridSite.rds` (available at: `s3://grapph/schwartz/USGridSite.rds`)
