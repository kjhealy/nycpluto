test_that("nyc_pluto_path returns a valid file path", {
  path <- nyc_pluto_path()
  expect_type(path, "character")
  expect_true(file.exists(path))
  expect_match(path, "\\.parquet$")
})

test_that("nyc_pluto has the expected columns", {
  df <- nyc_pluto()
  expect_true(inherits(df, "data.frame"))
  expect_length(names(df), 98)
  expect_true(all(
    c("bbl", "borough", "bldgclass", "landuse", "unitsres", "geometry") %in%
      names(df)
  ))
})

test_that("bbl is unique and land use codes keep leading zeros", {
  checks <- nyc_pluto() |>
    dplyr::summarise(n = dplyr::n(), n_bbl = dplyr::n_distinct(bbl)) |>
    dplyr::collect()
  expect_equal(checks$n, checks$n_bbl)

  landuse <- nyc_pluto() |>
    dplyr::count(landuse) |>
    dplyr::collect()
  expect_true(all(nchar(stats::na.omit(landuse$landuse)) == 2))
})

test_that("nyc_pluto_to_sf returns polygons", {
  skip_if_not_installed("sf")
  lots <- nyc_pluto() |>
    dplyr::filter(borough == "MN", block == 1L) |>
    dplyr::collect()
  result <- suppressMessages(nyc_pluto_to_sf(lots))
  expect_s3_class(result, "sf")
  expect_true(all(sf::st_geometry_type(result) == "MULTIPOLYGON"))
  expect_equal(sf::st_crs(result)$epsg, 2263)
})

test_that("nyc_pluto_to_sf drops lots without polygons, with a message", {
  skip_if_not_installed("sf")
  lots <- nyc_pluto() |>
    dplyr::filter(plutomapid == "2") |>
    utils::head(3) |>
    dplyr::collect()
  expect_message(result <- nyc_pluto_to_sf(lots), "Dropped 3 lots")
  expect_equal(nrow(result), 0)
})

test_that("nyc_pluto_to_sf returns points", {
  skip_if_not_installed("sf")
  df <- data.frame(
    bbl = c("1", "2"),
    latitude = c(40.7128, NA),
    longitude = c(-74.0060, NA)
  )
  expect_message(result <- nyc_pluto_to_sf(df, geometry = "point"), "1 lot")
  expect_equal(nrow(result), 1)
  expect_true(all(sf::st_geometry_type(result) == "POINT"))
})

test_that("nyc_pluto_to_sf errors without the needed columns", {
  skip_if_not_installed("sf")
  df <- data.frame(bbl = "1")
  expect_error(nyc_pluto_to_sf(df), "geometry")
  expect_error(nyc_pluto_to_sf(df, geometry = "point"), "latitude")
})

test_that("land use lookup agrees with PLUTO", {
  lots <- nyc_pluto() |>
    dplyr::count(bldgclass, landuse) |>
    dplyr::collect()
  checked <- lots |>
    dplyr::inner_join(
      nyc_pluto_bldg_class_df,
      by = "bldgclass",
      suffix = c("", "_lookup")
    )
  expect_equal(checked$landuse, checked$landuse_lookup)
})
