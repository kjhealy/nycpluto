# Get a lazy table reference to PLUTO tax lots

Returns a duckplyr-backed lazy data frame connected to the PLUTO
GeoParquet file bundled with this package: one row for each of the
858,284 tax lots in New York City in PLUTO release 26v2 (August 2026),
with 97 attribute fields and the lot polygon from MapPLUTO.

## Usage

``` r
nyc_pluto()
```

## Source

NYC Department of City Planning, PLUTO and MapPLUTO 26v2,
<https://www.nyc.gov/content/planning/pages/resources/datasets/mappluto-pluto-change>;
NYC Open Data, <https://data.cityofnewyork.us/d/64uk-42ks>.

## Value

A duckplyr data frame backed by the GeoParquet file.

## Details

Use dplyr verbs to filter, select, and summarise, then call
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)
to bring results into R memory. Collect only the rows and columns you
need: the polygons for all lots take over 1 GB in memory. Use
[`nyc_pluto_to_sf()`](https://kjhealy.github.io/nycpluto/reference/nyc_pluto_to_sf.md)
to turn collected rows into an sf object.

**Sources.** Attributes and polygons are from MapPLUTO 26v2, clipped to
the shoreline. The 1,597 lots that are in PLUTO but not in the clipped
MapPLUTO (`plutomapid` 2, 4, or 5: 1,378 lots not on the tax map and 219
lots wholly under water) come from the PLUTO CSV on NYC Open Data, with
fields that the CSV export reformats (leading zeros, Y/N flags) restored
to DCP's formats. Their `geometry` is `NA`.

**Condominiums.** A condominium appears as one record for its billing
lot (lot 7501–7599), with unit, area, and value fields summed over its
unit lots. Individual unit lots (1001–6999) are not in PLUTO.

**Changes.** DCP corrects some source values. `dcpedited == "1"` marks
lots with a corrected value;
[nyc_pluto_changes_df](https://kjhealy.github.io/nycpluto/reference/nyc_pluto_changes_df.md)
lists each change.

**Not included.** The deprecated `sanborn` field, the empty `notes`
field, the source-data date fields (empty in the CSV export), and the
ESRI shape measures.

## Columns

Column names are PLUTO's field names in lower case. Codes are as
published by DCP. Zero is the usual value for "not available" in area,
dimension, and year fields; see each field. The data frame has 98
columns:

- borough:

  Borough: `"MN"`, `"BX"`, `"BK"`, `"QN"`, or `"SI"` (character). Marble
  Hill is `"MN"` and Rikers Island is `"BX"`, the boroughs they are
  legally in.

- block:

  Tax block (integer).

- lot:

  Tax lot (integer). Condominiums use the billing lot, 7501–7599.

- cd:

  Community district (integer): borough code followed by the district
  number, e.g. `101`, `412`. Joint interest areas (large parks and
  airports outside any district) are `164` Central Park, `226` Van
  Cortlandt Park, `227` Bronx Park, `228` Pelham Bay Park, `355`
  Prospect Park, `356`, `484`, and `595` Gateway National Recreation
  Area, `480` LaGuardia Airport, `481` Flushing Meadows Corona Park,
  `482` Forest Park, and `483` JFK Airport. Marble Hill is in districts
  `207`/`208` and Rikers Island in `401`, the districts that serve them.

- bct2020:

  2020 census tract: borough code and six-digit tract, e.g. `"4062600"`
  (character).

- bctcb2020:

  2020 census block: borough code, six-digit tract, and four-digit block
  (character).

- ct2010:

  2010 census tract, e.g. `"203.01"`, `"23"` (character).

- cb2010:

  2010 census block, four digits with an optional letter suffix
  (character).

- schooldist:

  School district, two digits (character).

- council:

  City council district, 1–51 (integer).

- zipcode:

  A ZIP code valid for one of the lot's addresses (character). `NA` if
  the lot has no house number.

- firecomp:

  Fire company: `E` (engine), `L` (ladder), or `Q` (squad) and a
  three-digit number, e.g. `"E005"` (character).

- policeprct:

  Police precinct (integer).

- healthcenterdistrict:

  Health center district (integer).

- healtharea:

  Health area, with an implied decimal point after the first two digits
  (integer).

- sanitboro:

  Borough code of the sanitation district (character).

- sanitdistrict:

  Sanitation district, two digits (character).

- sanitsub:

  Sanitation district subsection (character).

- address:

  Address of the lot from DOF; the low house number when there is a
  range (character).

- zonedist1:

  Zoning district covering the largest share of the lot, e.g. `"R6"`,
  `"C4-4A"`, `"M1-1"`, `"PARK"` (character).

- zonedist2,zonedist3,zonedist4:

  Further zoning districts covering at least 10% of the lot, in order of
  share (character).

- overlay1,overlay2:

  Commercial overlays (C1 or C2 districts within residential districts),
  in order of share (character).

- spdist1,spdist2,spdist3:

  Special purpose districts covering at least 10% of the lot, in order
  of share, e.g. `"MiD"` (Midtown), `"DB"` (Downtown Brooklyn)
  (character). See appendix A of the PLUTO data dictionary.

- ltdheight:

  Limited height district, e.g. `"LH-1"` (character).

- splitzone:

  `"Y"` if the lot is split between zoning districts, commercial
  overlays, or special districts, otherwise `"N"` (character).

- bldgclass:

  Building class (character). See
  [nyc_pluto_bldg_class_df](https://kjhealy.github.io/nycpluto/reference/nyc_pluto_bldg_class_df.md).

- landuse:

  Land use category, `"01"`–`"11"` (character). See
  [nyc_pluto_land_use_df](https://kjhealy.github.io/nycpluto/reference/nyc_pluto_land_use_df.md).

- easements:

  Number of easements on the lot (integer).

- ownertype:

  Type of ownership: `"C"` city, `"M"` mixed city and private, `"O"`
  other public (authority, state, or federal), `"P"` private, `"X"`
  fully tax-exempt; `NA` unknown, usually private (character).

- ownername:

  Owner name; names of public owners are normalized (character).

- lotarea:

  Lot area in square feet (integer).

- bldgarea:

  Total building floor area in square feet, gross except for
  condominiums, whose areas are net (integer). Zero means not available
  when `numbldgs > 0`, and not applicable otherwise.

- comarea,resarea,officearea,retailarea,garagearea,strgearea,factryarea,otherarea:

  Floor area in square feet allocated to commercial, residential,
  office, retail, garage, storage, factory, and other uses (integer).
  Zero can mean not available or not applicable. Office through other
  areas are not available for one- to three-family buildings. The parts
  do not always sum to `bldgarea`.

- areasource:

  Source of `bldgarea`: `"0"` not available, `"2"` DOF Property Tax
  System, `"4"` vacant lot with no buildings (area 0), `"5"` calculated
  from building dimensions and floors (primary building only), `"7"` DOF
  Mass Appraisal System (character).

- numbldgs:

  Number of buildings on the lot (integer).

- numfloors:

  Number of floors of the tallest building, including partial floors
  (double). `NA` with `numbldgs > 0` means not available.

- unitsres:

  Number of residential units (integer).

- unitstotal:

  Number of residential and non-residential units (integer).

- lotfront,lotdepth:

  Lot frontage and depth in feet (double).

- bldgfront,bldgdepth:

  Building frontage and depth in feet (double).

- ext:

  Extension: `"E"` extension, `"G"` garage, `"EG"` both, `"N"` none;
  `NA` unknown (character).

- proxcode:

  Proximity to neighbouring buildings: `"0"` not available, `"1"`
  detached, `"2"` semi-attached, `"3"` attached (character).

- irrlotcode:

  `"Y"` if the lot is irregularly shaped, otherwise `"N"` (character).

- lottype:

  Lot type: `"0"` unknown, `"1"` block assemblage, `"2"` waterfront,
  `"3"` corner, `"4"` through, `"5"` inside, `"6"` interior (no
  frontage), `"7"` island, `"8"` alley, `"9"` submerged (character).

- bsmtcode:

  Basement: `"0"` none, `"1"` above-grade full, `"2"` below-grade full,
  `"3"` above-grade partial, `"4"` below-grade partial, `"5"` unknown
  (character).

- assessland:

  Assessed land value in dollars (double).

- assesstot:

  Assessed total value in dollars (double).

- exempttot:

  Exempt total value in dollars (double).

- yearbuilt:

  Year the building was completed (integer). Accurate to the decade, not
  always the year. Zero means unknown.

- yearalter1,yearalter2:

  Years of the second most recent and most recent alterations (integer).
  Zero if none.

- histdist:

  Name of the historic district the lot is in (character).

- landmark:

  `"INDIVIDUAL LANDMARK"`, `"INTERIOR LANDMARK"`, or
  `"INDIVIDUAL AND INTERIOR LANDMARK"` (character).

- builtfar:

  Built floor area ratio: `bldgarea / lotarea` (double).

- residfar,commfar,facilfar:

  Maximum allowable residential, commercial, and community facility
  floor area ratios under the lot's zoning (double).

- borocode:

  Borough code: 1 Manhattan, 2 Bronx, 3 Brooklyn, 4 Queens, 5 Staten
  Island (integer).

- bbl:

  Borough-block-lot, 10 digits (character). Unique.

- condono:

  Condominium number, unique within a borough (integer).

- tract2010:

  2010 census tract as four digits plus a two-digit suffix if any, e.g.
  `"020301"`, `"0023"` (character).

- xcoord,ycoord:

  Approximate lot location in feet, EPSG:2263 (integer).

- zonemap:

  DCP zoning map number (character).

- zmcode:

  `"Y"` if the lot is on the border of two or more zoning maps
  (character).

- taxmap:

  DOF paper tax map volume (character). No longer updated.

- edesignum:

  \(E\) designation number for environmental requirements (character).

- appbbl:

  Apportionment BBL: the lot's BBL before a merger, split, or
  condominium conversion since 1984 (character).

- appdate:

  Date of the apportionment (Date).

- plutomapid:

  DCP's file indicator (character): `"1"` in PLUTO and both MapPLUTO
  versions; `"2"` in PLUTO only; `"3"` in both MapPLUTO versions but not
  PLUTO; `"4"` in PLUTO and the water-included MapPLUTO but not the
  clipped version (entirely under water); `"5"` in the water-included
  MapPLUTO only (under water). All five values occur in this release;
  lots with `"2"`, `"4"`, or `"5"` have no polygon.

- firm07_flag:

  `"1"` if part of the lot is in the 1% annual chance floodplain in
  FEMA's 2007 Flood Insurance Rate Map (character).

- pfirm15_flag:

  `"1"` if part of the lot is in the 1% annual chance floodplain in
  FEMA's 2015 Preliminary Flood Insurance Rate Map (character).

- version:

  PLUTO release, `"26v2"` (character).

- dcpedited:

  `"1"` if DCP changed any field value for the lot (character). See
  [nyc_pluto_changes_df](https://kjhealy.github.io/nycpluto/reference/nyc_pluto_changes_df.md).

- latitude,longitude:

  Approximate lot location in decimal degrees, WGS84 (double).

- mihoption1,mihoption2,mihoption3,mihoption4:

  `"1"` if Mandatory Inclusionary Housing option 1, 2, 3 (deep
  affordability), or 4 (workforce) applies to the lot (character).

- trnstzone:

  Transit zone, which governs residential parking requirements, e.g.
  `"Manhattan Core"`, `"Inner Transit Zone"`,
  `"Beyond the Greater Transit Zone"` (character).

- affresfar:

  Maximum allowable residential floor area ratio for affordable housing
  (double).

- manufar:

  Maximum allowable manufacturing floor area ratio (double).

- geometry:

  Lot polygon, MultiPolygon in EPSG:2263, as WKB (raw vector, list
  column after collecting). `NA` for lots not in the clipped MapPLUTO.

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)

# Residential units by borough
nyc_pluto() |>
  summarise(units = sum(unitsres, na.rm = TRUE), .by = borough) |>
  collect()

# Lot polygons for one block
nyc_pluto() |>
  filter(borough == "MN", block == 1376) |>
  collect() |>
  nyc_pluto_to_sf()
} # }
```
