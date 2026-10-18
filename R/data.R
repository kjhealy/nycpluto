#' PLUTO building classes
#'
#' Building class codes used in PLUTO, with their descriptions and land use
#' categories.
#'
#' @format ## `nyc_pluto_bldg_class_df`
#' A tibble with 225 rows and 4 columns:
#' \describe{
#'   \item{bldgclass}{Two-character building class code (character). Joins
#'     to `bldgclass` in [nyc_pluto()]. The first character is the general
#'     class: for example `A` one-family dwellings, `B` two-family, `C`
#'     walk-up apartments, `D` elevator apartments, `R` condominiums, `V`
#'     vacant land.}
#'   \item{description}{Description of the class (character).}
#'   \item{landuse}{Land use category the class is assigned to,
#'     `"01"`--`"11"` (character). See [nyc_pluto_land_use_df]. `NA` for
#'     unassigned classes.}
#'   \item{source}{Source of the code: `"DOF"` for Department of Finance
#'     building classes, `"DCP"` for classes the Department of City
#'     Planning adds in PLUTO (character).}
#' }
#' @details
#' DCP assigns its own classes to condominium billing lots whose units have
#' mixed classes: `RC` (mixed commercial), `RD` (mixed residential), `RM`
#' (residential and commercial), `RI` (commercial and industrial), `RX`
#' (residential, commercial, and industrial), and `RZ` (residential and
#' industrial). It also assigns `Q0` to vacant lots mapped as parks and
#' `QG` to vacant lots with community gardens.
#'
#' A few codes in PLUTO 26v2 are not defined in either dictionary: `CB`,
#' `CC`, `DB`, `DC`, `VC`, and `VG` (118 lots).
#'
#' @author Kieran Healy
#' @source NYC Department of Finance, Annualized Calendar Sales Update data
#'   dictionary, <https://data.cityofnewyork.us/d/w2pb-icbu>; NYC Department
#'   of City Planning, PLUTO data dictionary 26v2, appendices C and D.
"nyc_pluto_bldg_class_df"

#' PLUTO change file
#'
#' Corrections that the Department of City Planning (DCP) applies to source
#' agency values when building PLUTO. One row per lot and field changed.
#' The changes listed are those in effect in release 26v2, including
#' programmatic changes first made in earlier releases.
#'
#' @format ## `nyc_pluto_changes_df`
#' A tibble with 42,955 rows and 7 columns:
#' \describe{
#'   \item{bbl}{Borough-block-lot of the changed lot, 10 digits
#'     (character). Joins to `bbl` in [nyc_pluto()].}
#'   \item{field}{PLUTO field changed, e.g. `"yearbuilt"`, `"ownername"`,
#'     `"lotarea"` (character).}
#'   \item{old_value}{Original value from the source agency (character).}
#'   \item{new_value}{Value in PLUTO after the change (character).}
#'   \item{type}{Kind of change (integer). DCP's metadata does not define
#'     the codes; the reasons recorded with them indicate `1` programmatic
#'     changes (e.g. normalized owner names, zero lot areas), `2` research
#'     changes (e.g. LPC year built, Property Tax System errors), and `3`
#'     user-reported changes.}
#'   \item{reason}{Reason for the change, e.g. `"LPC year built"`,
#'     `"Normalized owner name"`, `"Zero lot area"`, `"PTS error - units"`
#'     (character).}
#'   \item{version}{For programmatic changes, the PLUTO release in which
#'     the change was introduced, e.g. `"20v1"` (character).}
#' }
#' @details
#' The most common changes are year built replaced by the Landmarks
#' Preservation Commission's date for about 26,000 buildings in historic
#' districts, normalized names of public owners, and zero lot areas
#' replaced by the area of the lot on the Digital Tax Map. Lots with any
#' change have `dcpedited == "1"` in [nyc_pluto()].
#'
#' @author Kieran Healy
#' @source NYC Open Data, PLUTO Change File,
#'   <https://data.cityofnewyork.us/d/qt5r-nqxp>
"nyc_pluto_changes_df"

#' PLUTO land use categories
#'
#' The 11 land use categories that the Department of City Planning assigns
#' to tax lots in PLUTO, with the building classes in each.
#'
#' @format ## `nyc_pluto_land_use_df`
#' A tibble with 11 rows and 3 columns:
#' \describe{
#'   \item{landuse}{Land use code, `"01"`--`"11"` (character). Joins to
#'     `landuse` in [nyc_pluto()].}
#'   \item{description}{Land use category, e.g.
#'     `"One & Two Family Buildings"`, `"Vacant Land"` (character).}
#'   \item{bldgclasses}{Building classes assigned to the category
#'     (character). A trailing `*` means every class with that first letter,
#'     e.g. `"A*"` is all one-family dwellings.}
#' }
#' @details
#' Building classes R0, RT, Y5, Z7, and Z9 are not assigned to a land use
#' category, so lots with those classes have no `landuse`.
#'
#' @author Kieran Healy
#' @source NYC Department of City Planning, PLUTO data dictionary 26v2,
#'   appendix D.
"nyc_pluto_land_use_df"
