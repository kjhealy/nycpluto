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
