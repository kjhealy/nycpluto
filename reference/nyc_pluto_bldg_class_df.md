# PLUTO building classes

Building class codes used in PLUTO, with their descriptions and land use
categories.

## Usage

``` r
nyc_pluto_bldg_class_df
```

## Format

### `nyc_pluto_bldg_class_df`

A tibble with 225 rows and 4 columns:

- bldgclass:

  Two-character building class code (character). Joins to `bldgclass` in
  [`nyc_pluto()`](https://kjhealy.github.io/nycpluto/reference/nyc_pluto.md).
  The first character is the general class: for example `A` one-family
  dwellings, `B` two-family, `C` walk-up apartments, `D` elevator
  apartments, `R` condominiums, `V` vacant land.

- description:

  Description of the class (character).

- landuse:

  Land use category the class is assigned to, `"01"`–`"11"` (character).
  See
  [nyc_pluto_land_use_df](https://kjhealy.github.io/nycpluto/reference/nyc_pluto_land_use_df.md).
  `NA` for unassigned classes.

- source:

  Source of the code: `"DOF"` for Department of Finance building
  classes, `"DCP"` for classes the Department of City Planning adds in
  PLUTO (character).

## Source

NYC Department of Finance, Annualized Calendar Sales Update data
dictionary, <https://data.cityofnewyork.us/d/w2pb-icbu>; NYC Department
of City Planning, PLUTO data dictionary 26v2, appendices C and D.

## Details

DCP assigns its own classes to condominium billing lots whose units have
mixed classes: `RC` (mixed commercial), `RD` (mixed residential), `RM`
(residential and commercial), `RI` (commercial and industrial), `RX`
(residential, commercial, and industrial), and `RZ` (residential and
industrial). It also assigns `Q0` to vacant lots mapped as parks and
`QG` to vacant lots with community gardens.

A few codes in PLUTO 26v2 are not defined in either dictionary: `CB`,
`CC`, `DB`, `DC`, `VC`, and `VG` (118 lots).

## Author

Kieran Healy
