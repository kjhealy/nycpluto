## nyc_pluto_changes_df — PLUTO change file, NYC Open Data qt5r-nqxp

source(here::here("data-raw", "_source.R"))

nyc_pluto_changes_df <- read_csv(
  change_csv,
  col_types = cols(.default = col_character())
) |>
  clean_names() |>
  mutate(
    bbl = as.character(as.numeric(bbl)),
    type = as.integer(type),
    reason = str_squish(str_replace_all(reason, "–", "-"))
  ) |>
  arrange(bbl, field, version)

usethis::use_data(nyc_pluto_changes_df, overwrite = TRUE, compress = "xz")
