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
