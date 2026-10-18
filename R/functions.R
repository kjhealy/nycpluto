#' Get a lazy table reference to PLUTO tax lots
#'
#' Returns a duckplyr-backed lazy data frame connected to the PLUTO
#' GeoParquet file bundled with this package: one row for each of the
#' 858,284 tax lots in New York City in PLUTO release 26v2 (August 2026),
#' with 97 attribute fields and the lot polygon from MapPLUTO.
#'
#' Use dplyr verbs to filter, select, and summarise, then call
#' [dplyr::collect()] to bring results into R memory. Collect only the
#' rows and columns you need: the polygons for all lots take over 1 GB in
#' memory. Use [nyc_pluto_to_sf()] to turn collected rows into an sf
#' object.
#'
#' @details
#' **Sources.** Attributes and polygons are from MapPLUTO 26v2, clipped to
#' the shoreline. The 1,597 lots that are in PLUTO but not in the clipped
#' MapPLUTO (`plutomapid` 2, 4, or 5: 1,378 lots not on the tax map and 219
#' lots wholly under water) come from the PLUTO CSV on NYC Open Data, with
#' fields that the CSV export reformats (leading zeros, Y/N flags) restored
#' to DCP's formats. Their `geometry` is `NA`.
#'
#' **Condominiums.** A condominium appears as one record for its billing
#' lot (lot 7501--7599), with unit, area, and value fields summed over its
#' unit lots. Individual unit lots (1001--6999) are not in PLUTO.
#'
#' **Changes.** DCP corrects some source values. `dcpedited == "1"` marks
#' lots with a corrected value; [nyc_pluto_changes_df] lists each change.
#'
#' **Not included.** The deprecated `sanborn` field, the empty `notes`
#' field, the source-data date fields (empty in the CSV export), and the
#' ESRI shape measures.
#'
#' @section Columns:
#' Column names are PLUTO's field names in lower case. Codes are as
#' published by DCP. Zero is the usual value for "not available" in area,
#' dimension, and year fields; see each field. The data frame has 98
#' columns:
#' \describe{
#'   \item{borough}{Borough: `"MN"`, `"BX"`, `"BK"`, `"QN"`, or `"SI"`
#'     (character). Marble Hill is `"MN"` and Rikers Island is `"BX"`, the
#'     boroughs they are legally in.}
#'   \item{block}{Tax block (integer).}
#'   \item{lot}{Tax lot (integer). Condominiums use the billing lot,
#'     7501--7599.}
#'   \item{cd}{Community district (integer): borough code followed by the
#'     district number, e.g. `101`, `412`. Joint interest areas (large parks
#'     and airports outside any district) are `164` Central Park, `226` Van
#'     Cortlandt Park, `227` Bronx Park, `228` Pelham Bay Park, `355`
#'     Prospect Park, `356`, `484`, and `595` Gateway National Recreation
#'     Area, `480` LaGuardia Airport, `481` Flushing Meadows Corona Park,
#'     `482` Forest Park, and `483` JFK Airport. Marble Hill is in districts
#'     `207`/`208` and Rikers Island in `401`, the districts that serve
#'     them.}
#'   \item{bct2020}{2020 census tract: borough code and six-digit tract,
#'     e.g. `"4062600"` (character).}
#'   \item{bctcb2020}{2020 census block: borough code, six-digit tract, and
#'     four-digit block (character).}
#'   \item{ct2010}{2010 census tract, e.g. `"203.01"`, `"23"`
#'     (character).}
#'   \item{cb2010}{2010 census block, four digits with an optional letter
#'     suffix (character).}
#'   \item{schooldist}{School district, two digits (character).}
#'   \item{council}{City council district, 1--51 (integer).}
#'   \item{zipcode}{A ZIP code valid for one of the lot's addresses
#'     (character). `NA` if the lot has no house number.}
#'   \item{firecomp}{Fire company: `E` (engine), `L` (ladder), or `Q`
#'     (squad) and a three-digit number, e.g. `"E005"` (character).}
#'   \item{policeprct}{Police precinct (integer).}
#'   \item{healthcenterdistrict}{Health center district (integer).}
#'   \item{healtharea}{Health area, with an implied decimal point after the
#'     first two digits (integer).}
#'   \item{sanitboro}{Borough code of the sanitation district (character).}
#'   \item{sanitdistrict}{Sanitation district, two digits (character).}
#'   \item{sanitsub}{Sanitation district subsection (character).}
#'   \item{address}{Address of the lot from DOF; the low house number when
#'     there is a range (character).}
#'   \item{zonedist1}{Zoning district covering the largest share of the
#'     lot, e.g. `"R6"`, `"C4-4A"`, `"M1-1"`, `"PARK"` (character).}
#'   \item{zonedist2,zonedist3,zonedist4}{Further zoning districts covering
#'     at least 10% of the lot, in order of share (character).}
#'   \item{overlay1,overlay2}{Commercial overlays (C1 or C2 districts within
#'     residential districts), in order of share (character).}
#'   \item{spdist1,spdist2,spdist3}{Special purpose districts covering at
#'     least 10% of the lot, in order of share, e.g. `"MiD"` (Midtown),
#'     `"DB"` (Downtown Brooklyn) (character). See appendix A of the PLUTO
#'     data dictionary.}
#'   \item{ltdheight}{Limited height district, e.g. `"LH-1"`
#'     (character).}
#'   \item{splitzone}{`"Y"` if the lot is split between zoning districts,
#'     commercial overlays, or special districts, otherwise `"N"`
#'     (character).}
#'   \item{bldgclass}{Building class (character). See
#'     [nyc_pluto_bldg_class_df].}
#'   \item{landuse}{Land use category, `"01"`--`"11"` (character). See
#'     [nyc_pluto_land_use_df].}
#'   \item{easements}{Number of easements on the lot (integer).}
#'   \item{ownertype}{Type of ownership: `"C"` city, `"M"` mixed city and
#'     private, `"O"` other public (authority, state, or federal), `"P"`
#'     private, `"X"` fully tax-exempt; `NA` unknown, usually private
#'     (character).}
#'   \item{ownername}{Owner name; names of public owners are normalized
#'     (character).}
#'   \item{lotarea}{Lot area in square feet (integer).}
#'   \item{bldgarea}{Total building floor area in square feet, gross except
#'     for condominiums, whose areas are net (integer). Zero means not
#'     available when `numbldgs > 0`, and not applicable otherwise.}
#'   \item{comarea,resarea,officearea,retailarea,garagearea,strgearea,factryarea,otherarea}{Floor
#'     area in square feet allocated to commercial, residential, office,
#'     retail, garage, storage, factory, and other uses (integer). Zero
#'     can mean not available or not applicable. Office through other areas
#'     are not available for one- to three-family buildings. The parts do
#'     not always sum to `bldgarea`.}
#'   \item{areasource}{Source of `bldgarea`: `"0"` not available, `"2"` DOF
#'     Property Tax System, `"4"` vacant lot with no buildings (area 0),
#'     `"5"` calculated from building dimensions and floors (primary
#'     building only), `"7"` DOF Mass Appraisal System (character).}
#'   \item{numbldgs}{Number of buildings on the lot (integer).}
#'   \item{numfloors}{Number of floors of the tallest building, including
#'     partial floors (double). `NA` with `numbldgs > 0` means not
#'     available.}
#'   \item{unitsres}{Number of residential units (integer).}
#'   \item{unitstotal}{Number of residential and non-residential units
#'     (integer).}
#'   \item{lotfront,lotdepth}{Lot frontage and depth in feet (double).}
#'   \item{bldgfront,bldgdepth}{Building frontage and depth in feet
#'     (double).}
#'   \item{ext}{Extension: `"E"` extension, `"G"` garage, `"EG"` both,
#'     `"N"` none; `NA` unknown (character).}
#'   \item{proxcode}{Proximity to neighbouring buildings: `"0"` not
#'     available, `"1"` detached, `"2"` semi-attached, `"3"` attached
#'     (character).}
#'   \item{irrlotcode}{`"Y"` if the lot is irregularly shaped, otherwise
#'     `"N"` (character).}
#'   \item{lottype}{Lot type: `"0"` unknown, `"1"` block assemblage, `"2"`
#'     waterfront, `"3"` corner, `"4"` through, `"5"` inside, `"6"`
#'     interior (no frontage), `"7"` island, `"8"` alley, `"9"` submerged
#'     (character).}
#'   \item{bsmtcode}{Basement: `"0"` none, `"1"` above-grade full, `"2"`
#'     below-grade full, `"3"` above-grade partial, `"4"` below-grade
#'     partial, `"5"` unknown (character).}
#'   \item{assessland}{Assessed land value in dollars (double).}
#'   \item{assesstot}{Assessed total value in dollars (double).}
#'   \item{exempttot}{Exempt total value in dollars (double).}
#'   \item{yearbuilt}{Year the building was completed (integer). Accurate
#'     to the decade, not always the year. Zero means unknown.}
#'   \item{yearalter1,yearalter2}{Years of the second most recent and most
#'     recent alterations (integer). Zero if none.}
#'   \item{histdist}{Name of the historic district the lot is in
#'     (character).}
#'   \item{landmark}{`"INDIVIDUAL LANDMARK"`, `"INTERIOR LANDMARK"`, or
#'     `"INDIVIDUAL AND INTERIOR LANDMARK"` (character).}
#'   \item{builtfar}{Built floor area ratio: `bldgarea / lotarea`
#'     (double).}
#'   \item{residfar,commfar,facilfar}{Maximum allowable residential,
#'     commercial, and community facility floor area ratios under the
#'     lot's zoning (double).}
#'   \item{borocode}{Borough code: 1 Manhattan, 2 Bronx, 3 Brooklyn, 4
#'     Queens, 5 Staten Island (integer).}
#'   \item{bbl}{Borough-block-lot, 10 digits (character). Unique.}
#'   \item{condono}{Condominium number, unique within a borough
#'     (integer).}
#'   \item{tract2010}{2010 census tract as four digits plus a two-digit
#'     suffix if any, e.g. `"020301"`, `"0023"` (character).}
#'   \item{xcoord,ycoord}{Approximate lot location in feet, EPSG:2263
#'     (integer).}
#'   \item{zonemap}{DCP zoning map number (character).}
#'   \item{zmcode}{`"Y"` if the lot is on the border of two or more zoning
#'     maps (character).}
#'   \item{taxmap}{DOF paper tax map volume (character). No longer
#'     updated.}
#'   \item{edesignum}{(E) designation number for environmental
#'     requirements (character).}
#'   \item{appbbl}{Apportionment BBL: the lot's BBL before a merger, split,
#'     or condominium conversion since 1984 (character).}
#'   \item{appdate}{Date of the apportionment (Date).}
#'   \item{plutomapid}{DCP's file indicator (character): `"1"` in PLUTO
#'     and both MapPLUTO versions; `"2"` in PLUTO only; `"3"` in both
#'     MapPLUTO versions but not PLUTO; `"4"` in PLUTO and the
#'     water-included MapPLUTO but not the clipped version (entirely under
#'     water); `"5"` in the water-included MapPLUTO only (under water). All
#'     five values occur in this release; lots with `"2"`, `"4"`, or `"5"`
#'     have no polygon.}
#'   \item{firm07_flag}{`"1"` if part of the lot is in the 1% annual chance
#'     floodplain in FEMA's 2007 Flood Insurance Rate Map (character).}
#'   \item{pfirm15_flag}{`"1"` if part of the lot is in the 1% annual
#'     chance floodplain in FEMA's 2015 Preliminary Flood Insurance Rate Map
#'     (character).}
#'   \item{version}{PLUTO release, `"26v2"` (character).}
#'   \item{dcpedited}{`"1"` if DCP changed any field value for the lot
#'     (character). See [nyc_pluto_changes_df].}
#'   \item{latitude,longitude}{Approximate lot location in decimal degrees,
#'     WGS84 (double).}
#'   \item{mihoption1,mihoption2,mihoption3,mihoption4}{`"1"` if Mandatory
#'     Inclusionary Housing option 1, 2, 3 (deep affordability), or 4
#'     (workforce) applies to the lot (character).}
#'   \item{trnstzone}{Transit zone, which governs residential parking
#'     requirements, e.g. `"Manhattan Core"`, `"Inner Transit Zone"`,
#'     `"Beyond the Greater Transit Zone"` (character).}
#'   \item{affresfar}{Maximum allowable residential floor area ratio for
#'     affordable housing (double).}
#'   \item{manufar}{Maximum allowable manufacturing floor area ratio
#'     (double).}
#'   \item{geometry}{Lot polygon, MultiPolygon in EPSG:2263, as WKB (raw
#'     vector, list column after collecting). `NA` for lots not in the
#'     clipped MapPLUTO.}
#' }
#'
#' @return A duckplyr data frame backed by the GeoParquet file.
#'
#' @source NYC Department of City Planning, PLUTO and MapPLUTO 26v2,
#'   <https://www.nyc.gov/content/planning/pages/resources/datasets/mappluto-pluto-change>;
#'   NYC Open Data, <https://data.cityofnewyork.us/d/64uk-42ks>.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#'
#' # Residential units by borough
#' nyc_pluto() |>
#'   summarise(units = sum(unitsres, na.rm = TRUE), .by = borough) |>
#'   collect()
#'
#' # Lot polygons for one block
#' nyc_pluto() |>
#'   filter(borough == "MN", block == 1376) |>
#'   collect() |>
#'   nyc_pluto_to_sf()
#' }
#'
#' @keywords functions
nyc_pluto <- function() {
  duckplyr::read_parquet_duckdb(nyc_pluto_path())
}


#' Get the file path to the PLUTO GeoParquet file
#'
#' Returns the path to the GeoParquet file bundled with this package.
#' Useful for direct access via arrow, DuckDB, or GDAL.
#'
#' @return A character string file path.
#'
#' @export
#'
#' @examples
#' nyc_pluto_path()
#'
#' @keywords functions
nyc_pluto_path <- function() {
  system.file(
    "extdata",
    "nyc_pluto.parquet",
    package = "nycpluto",
    mustWork = TRUE
  )
}


#' Convert collected PLUTO data to an sf object
#'
#' Takes a data frame (typically from [nyc_pluto()] after filtering and
#' collecting) and converts it to an sf object, with either the lot
#' polygons or points at the lots' approximate locations.
#'
#' @param df A data frame with a `geometry` column of WKB (for polygons) or
#'   `latitude` and `longitude` columns (for points).
#' @param geometry `"polygon"` (the default) for lot polygons, or `"point"`
#'   for points from `latitude` and `longitude`.
#' @param crs Target CRS. Default is EPSG:2263 (NAD83 / New York Long
#'   Island, ftUS).
#'
#' @return An sf object. Rows without the requested geometry are dropped,
#'   with a message.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#'
#' nyc_pluto() |>
#'   filter(borough == "BK", cd == 306) |>
#'   collect() |>
#'   nyc_pluto_to_sf()
#'
#' nyc_pluto() |>
#'   filter(landuse == "03") |>
#'   select(bbl, unitsres, latitude, longitude) |>
#'   collect() |>
#'   nyc_pluto_to_sf(geometry = "point")
#' }
#'
#' @keywords functions
nyc_pluto_to_sf <- function(df, geometry = c("polygon", "point"), crs = 2263) {
  geometry <- rlang::arg_match(geometry)
  if (!requireNamespace("sf", quietly = TRUE)) {
    cli::cli_abort(
      c(
        "{.pkg sf} is required for {.fn nyc_pluto_to_sf}.",
        "i" = "Install it with {.code install.packages(\"sf\")}."
      )
    )
  }
  if (geometry == "polygon") {
    polygons_to_sf(df, crs)
  } else {
    points_to_sf(df, crs)
  }
}

polygons_to_sf <- function(df, crs) {
  if (!"geometry" %in% names(df)) {
    cli::cli_abort(
      c(
        "{.arg df} must have a {.field geometry} column.",
        "i" = "Keep {.field geometry} when selecting columns, or use
          {.code geometry = \"point\"}."
      )
    )
  }
  has_geom <- !vapply(df$geometry, is.null, logical(1))
  report_dropped(sum(!has_geom), "polygon")
  df <- df[has_geom, ]
  wkb <- structure(df$geometry, class = "WKB")
  df$geometry <- sf::st_as_sfc(wkb, crs = 2263)
  sf::st_as_sf(df, sf_column_name = "geometry") |>
    sf::st_transform(crs = crs)
}

points_to_sf <- function(df, crs) {
  missing_cols <- setdiff(c("latitude", "longitude"), names(df))
  if (length(missing_cols) > 0) {
    cli::cli_abort("{.arg df} must have column{?s} {.field {missing_cols}}.")
  }
  df$geometry <- NULL
  has_xy <- !is.na(df$latitude) & !is.na(df$longitude)
  report_dropped(sum(!has_xy), "location")
  sf::st_as_sf(
    df[has_xy, ],
    coords = c("longitude", "latitude"),
    crs = 4326
  ) |>
    sf::st_transform(crs = crs)
}

report_dropped <- function(n, what) {
  if (n > 0) {
    cli::cli_inform("Dropped {n} lot{?s} with no {what}.")
  }
}
