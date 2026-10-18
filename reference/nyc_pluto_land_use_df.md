# PLUTO land use categories

The 11 land use categories that the Department of City Planning assigns
to tax lots in PLUTO, with the building classes in each.

## Usage

``` r
nyc_pluto_land_use_df
```

## Format

### `nyc_pluto_land_use_df`

A tibble with 11 rows and 3 columns:

- landuse:

  Land use code, `"01"`–`"11"` (character). Joins to `landuse` in
  [`nyc_pluto()`](https://kjhealy.github.io/nycpluto/reference/nyc_pluto.md).

- description:

  Land use category, e.g. `"One & Two Family Buildings"`,
  `"Vacant Land"` (character).

- bldgclasses:

  Building classes assigned to the category (character). A trailing `*`
  means every class with that first letter, e.g. `"A*"` is all
  one-family dwellings.

## Source

NYC Department of City Planning, PLUTO data dictionary 26v2, appendix D.

## Details

Building classes R0, RT, Y5, Z7, and Z9 are not assigned to a land use
category, so lots with those classes have no `landuse`.

## Author

Kieran Healy
