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
