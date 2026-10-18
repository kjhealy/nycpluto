# Convert collected PLUTO data to an sf object

Takes a data frame (typically from
[`nyc_pluto()`](https://kjhealy.github.io/nycpluto/reference/nyc_pluto.md)
after filtering and collecting) and converts it to an sf object, with
either the lot polygons or points at the lots' approximate locations.

## Usage

``` r
nyc_pluto_to_sf(df, geometry = c("polygon", "point"), crs = 2263)
```

## Arguments

- df:

  A data frame with a `geometry` column of WKB (for polygons) or
  `latitude` and `longitude` columns (for points).

- geometry:

  `"polygon"` (the default) for lot polygons, or `"point"` for points
  from `latitude` and `longitude`.

- crs:

  Target CRS. Default is EPSG:2263 (NAD83 / New York Long Island, ftUS).

## Value

An sf object. Rows without the requested geometry are dropped, with a
message.

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)

nyc_pluto() |>
  filter(borough == "BK", cd == 306) |>
  collect() |>
  nyc_pluto_to_sf()

nyc_pluto() |>
  filter(landuse == "03") |>
  select(bbl, unitsres, latitude, longitude) |>
  collect() |>
  nyc_pluto_to_sf(geometry = "point")
} # }
```
