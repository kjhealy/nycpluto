## nyc_pluto — PLUTO tax lots with MapPLUTO polygons, written to GeoParquet
##
## MapPLUTO (file geodatabase) is the primary source: it keeps DCP's field
## formats. The Open Data CSV export drops leading zeros and rewrites some
## flags, so it is used only for the lots MapPLUTO lacks (lots in PLUTO but
## not on the shoreline-clipped map), after repairing those fields. The
## repairs are checked against MapPLUTO for every lot in both files.
##
## Requires the DuckDB spatial extension at build time.

source(here::here("data-raw", "_source.R"))

out_parquet <- here("inst", "extdata", "nyc_pluto.parquet")
fs::dir_create(here("inst", "extdata"))

# MapPLUTO fields not carried into the package: the row ID, the deprecated
# Sanborn map number (unreliable per the data dictionary), the empty notes
# field, and ESRI shape measures.
drop_fields <- c(
  "objectid",
  "sanborn",
  "notes",
  "shape_leng",
  "shape_length",
  "shape_area"
)

# CSV field names that differ from MapPLUTO's (lowercased) names.
csv_names <- c(
  block = "Tax block",
  lot = "Tax lot",
  cd = "community board",
  ct2010 = "census tract 2010",
  council = "council district",
  zipcode = "postcode",
  mihoption1 = "mihopt1",
  mihoption2 = "mihopt2",
  mihoption3 = "mihopt3",
  mihoption4 = "mihopt4",
  trnstzone = "transitzone",
  manufar = "mnffar",
  bbl = "BBL"
)

# Expressions that replace a plain cast, by output column.
gdb_overrides <- c(
  zipcode = "LPAD(CAST(\"ZipCode\" AS VARCHAR), 5, '0')",
  bbl = "CAST(CAST(\"BBL\" AS BIGINT) AS VARCHAR)",
  appbbl = "NULLIF(CAST(CAST(\"APPBBL\" AS BIGINT) AS VARCHAR), '0')",
  appdate = "CAST(TRY_STRPTIME(\"APPDate\", '%m/%d/%Y') AS DATE)",
  address = "NULLIF(TRIM(\"Address\"), '')"
)

csv_overrides <- c(
  zipcode = "LPAD(postcode, 5, '0')",
  bbl = "CAST(TRY_CAST(TRY_CAST(\"BBL\" AS DOUBLE) AS BIGINT) AS VARCHAR)",
  appbbl = "NULLIF(CAST(TRY_CAST(TRY_CAST(appbbl AS DOUBLE) AS BIGINT) AS VARCHAR), '0')",
  appdate = "CAST(TRY_STRPTIME(appdate, '%m/%d/%Y') AS DATE)",
  address = "NULLIF(TRIM(address), '')",
  landuse = "LPAD(landuse, 2, '0')",
  schooldist = "LPAD(schooldist, 2, '0')",
  sanitdistrict = "LPAD(sanitdistrict, 2, '0')",
  # "170.1" -> "170.10"
  ct2010 = "CASE WHEN \"census tract 2010\" LIKE '%.%'
    THEN SPLIT_PART(\"census tract 2010\", '.', 1) || '.' ||
      RPAD(SPLIT_PART(\"census tract 2010\", '.', 2), 2, '0')
    ELSE \"census tract 2010\" END",
  # Tract 170.10 -> "017010"; tract 40 -> "0040"
  tract2010 = "CASE WHEN \"census tract 2010\" LIKE '%.%'
    THEN LPAD(SPLIT_PART(\"census tract 2010\", '.', 1), 4, '0') ||
      RPAD(SPLIT_PART(\"census tract 2010\", '.', 2), 2, '0')
    ELSE LPAD(\"census tract 2010\", 4, '0') END",
  # Block number padded to four digits, keeping any letter suffix
  cb2010 = "LPAD(REGEXP_EXTRACT(cb2010, '^[0-9]+'), 4, '0') ||
    REGEXP_EXTRACT(cb2010, '[A-Z]*$')",
  splitzone = "CASE splitzone WHEN 'true' THEN 'Y' WHEN 'false' THEN 'N' END",
  irrlotcode = "CASE irrlotcode WHEN 'true' THEN 'Y' WHEN 'false' THEN 'N' END",
  zmcode = "CASE zmcode WHEN 'true' THEN 'Y' END",
  mihoption1 = "CASE mihopt1 WHEN 'true' THEN '1' END",
  mihoption2 = "CASE mihopt2 WHEN 'true' THEN '1' END",
  mihoption3 = "CASE mihopt3 WHEN 'true' THEN '1' END",
  mihoption4 = "CASE mihopt4 WHEN 'true' THEN '1' END"
)

output_types <- c(
  zipcode = "VARCHAR",
  bbl = "VARCHAR",
  appbbl = "VARCHAR",
  appdate = "DATE"
)

# -- Load sources ------------------------------------------------------------
con <- dbConnect(duckdb())
dbExecute(con, "INSTALL spatial")
dbExecute(con, "LOAD spatial")

dbExecute(
  con,
  paste0(
    "CREATE TABLE gdb AS SELECT * FROM ST_Read('",
    mappluto_gdb,
    "')"
  )
)
dbExecute(
  con,
  paste0(
    "CREATE TABLE csv AS SELECT * FROM read_csv('",
    pluto_csv,
    "', all_varchar = true)"
  )
)

# -- Column specification, in MapPLUTO field order ---------------------------
quote_id <- function(x) paste0("\"", x, "\"")

spec <- dbGetQuery(con, "DESCRIBE gdb") |>
  as_tibble() |>
  transmute(gdb_field = column_name, gdb_type = column_type) |>
  mutate(name = tolower(gdb_field)) |>
  filter(!name %in% drop_fields, !str_starts(gdb_type, "GEOMETRY")) |>
  mutate(
    csv_field = coalesce(unname(csv_names[name]), name),
    type = coalesce(unname(output_types[name]), gdb_type),
    gdb_expr = coalesce(
      unname(gdb_overrides[name]),
      paste0("CAST(", quote_id(gdb_field), " AS ", type, ")")
    ),
    csv_expr = coalesce(
      unname(csv_overrides[name]),
      paste0("TRY_CAST(", quote_id(csv_field), " AS ", type, ")")
    ),
    gdb_sql = paste0("CAST(", gdb_expr, " AS ", type, ") AS ", name),
    csv_sql = paste0("CAST(", csv_expr, " AS ", type, ") AS ", name)
  )

missing_csv <- setdiff(spec$csv_field, dbListFields(con, "csv"))
if (length(missing_csv) > 0) {
  cli::cli_abort("CSV is missing field{?s} {.field {missing_csv}}.")
}

dbExecute(
  con,
  paste0(
    "CREATE TABLE lots_gdb AS SELECT ",
    paste(spec$gdb_sql, collapse = ",\n  "),
    ", Shape AS geometry FROM gdb"
  )
)
dbExecute(
  con,
  paste0(
    "CREATE TABLE lots_csv AS SELECT ",
    paste(spec$csv_sql, collapse = ",\n  "),
    " FROM csv"
  )
)

# -- Check the CSV repairs against MapPLUTO ----------------------------------
mismatches <- spec$name |>
  map(\(col) {
    dbGetQuery(
      con,
      paste0(
        "SELECT '",
        col,
        "' AS col, COUNT(*) AS n FROM lots_csv c JOIN lots_gdb g USING (bbl)
         WHERE c.",
        col,
        " IS DISTINCT FROM g.",
        col
      )
    )
  }) |>
  list_rbind() |>
  filter(n > 0)

message("CSV vs MapPLUTO mismatches after repair:")
print(mismatches)

# -- Combine and write -------------------------------------------------------
dbExecute(
  con,
  "
  CREATE TABLE nyc_pluto AS
  SELECT * FROM lots_gdb
  UNION ALL BY NAME
  SELECT * FROM lots_csv WHERE bbl NOT IN (SELECT bbl FROM lots_gdb)
  ORDER BY bbl
"
)

dbExecute(
  con,
  paste0(
    "COPY nyc_pluto TO '",
    out_parquet,
    "' (FORMAT PARQUET, COMPRESSION ZSTD)"
  )
)

dbGetQuery(
  con,
  "
  SELECT
    COUNT(*) AS n,
    COUNT(DISTINCT bbl) AS n_bbl,
    COUNT(*) FILTER (WHERE geometry IS NULL) AS no_polygon,
    COUNT(*) FILTER (WHERE latitude IS NULL) AS no_xy
  FROM nyc_pluto
"
) |>
  print()

dbDisconnect(con, shutdown = TRUE)
