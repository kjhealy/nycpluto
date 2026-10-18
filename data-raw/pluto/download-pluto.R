## Stage raw data for a PLUTO package.
##
## - Copies the PLUTO CSV and its docs from ../homes (staged for nychomes),
##   leaving the originals untouched.
## - Downloads MapPLUTO 26v2 (tax lot polygons, shoreline clipped, file
##   geodatabase) from NYC Department of City Planning (DCP).
## - Downloads the PLUTO Change File (NYC Open Data qt5r-nqxp) and its
##   metadata.
##
## Records every file in download-log.csv.
## Run from this folder: R --quiet -f download-pluto.R

library(tidyverse)
library(here)

root <- here::here()
homes <- file.path(dirname(root), "homes")
user_agent <- "Mozilla/5.0 (nycpluto data download)"
pluto_version <- "26v2"

dir.create(file.path(root, "data"), showWarnings = FALSE)
dir.create(file.path(root, "docs"), showWarnings = FALSE)

## Copy PLUTO from the homes staging folder -----------------------------------

copies <- tribble(
  ~from                                 , ~to                                 ,
  "data/opendata/pluto.csv"             , "data/pluto_26v2.csv"               ,
  "docs/pluto_metadata.json"            , "docs/pluto_opendata_metadata.json" ,
  "docs/pluto_pluto_datadictionary.pdf" , "docs/pluto_datadictionary.pdf"     ,
  "docs/pluto_pluto_readme.pdf"         , "docs/pluto_readme.pdf"
) |>
  mutate(
    from = file.path(homes, from),
    to = file.path(root, to)
  )

copy_log <- copies |>
  pmap(\(from, to) {
    ok <- file.copy(from, to, overwrite = TRUE)
    tibble(
      source = "copied from data-to-be-packaged/homes",
      url = from,
      file = str_remove(to, paste0("^", root, "/")),
      status = if (ok) "ok" else "copy failed",
      bytes = file.size(to),
      downloaded = Sys.time()
    )
  }) |>
  bind_rows()

## Downloads ------------------------------------------------------------------

dcp_base <- "https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes"
opendata_base <- "https://data.cityofnewyork.us"

downloads <- tribble(
  ~source                                                                    , ~url , ~dest ,
  "DCP MapPLUTO"                                                             ,
  paste0(dcp_base, "/mappluto/nyc_mappluto_", pluto_version, "_fgdb.zip")    ,
  paste0("data/nyc_mappluto_", pluto_version, "_fgdb.zip")                   ,
  "NYC Open Data qt5r-nqxp"                                                  ,
  paste0(opendata_base, "/api/views/qt5r-nqxp/rows.csv?accessType=DOWNLOAD") ,
  "data/pluto_change_file.csv"                                               ,
  "NYC Open Data qt5r-nqxp"                                                  ,
  paste0(opendata_base, "/api/views/qt5r-nqxp.json")                         ,
  "docs/pluto_change_file_metadata.json"
) |>
  mutate(dest = file.path(root, dest))

fetch <- function(source, url, dest) {
  status <- tryCatch(
    {
      download.file(
        url,
        dest,
        mode = "wb",
        quiet = TRUE,
        method = "libcurl",
        headers = c("User-Agent" = user_agent)
      )
      "ok"
    },
    error = \(e) conditionMessage(e)
  )
  tibble(
    source = source,
    url = url,
    file = str_remove(dest, paste0("^", root, "/")),
    status = status,
    bytes = if (file.exists(dest)) file.size(dest) else NA_real_,
    downloaded = Sys.time()
  )
}

options(timeout = 3600)

download_log <- downloads |>
  pmap(fetch) |>
  bind_rows()

## Unzip MapPLUTO into its own folder.
unzip(
  file.path(root, "data", paste0("nyc_mappluto_", pluto_version, "_fgdb.zip")),
  exdir = file.path(root, "data", paste0("mappluto_", pluto_version))
)

log <- bind_rows(copy_log, download_log)
write_csv(log, file.path(root, "download-log.csv"))
print(select(log, file, status, bytes), n = Inf)
