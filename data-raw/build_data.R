## Build data objects

# Remove all .rda files in data/ and regenerate them
fs::dir_ls(here::here("data"), glob = "*.rda") |> fs::file_delete()

# Build data objects
source(here::here("data-raw", "pluto.R"))
source(here::here("data-raw", "pluto_changes.R"))
source(here::here("data-raw", "lookups.R"))

# Concatenate _documentation/*.R files into R/data.R
doc_files <- fs::dir_ls(
  here::here("data-raw", "_documentation"),
  regexp = "[.]R$"
)

doc_content <- doc_files |>
  purrr::map(readLines) |>
  purrr::map(\(x) c(x, "")) |>
  unlist()

writeLines(
  doc_content,
  here::here("R", "data.R")
)
