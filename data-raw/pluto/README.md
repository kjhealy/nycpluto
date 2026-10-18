# PLUTO and MapPLUTO

Raw data for an `nycpluto` package: the NYC Department of City Planning's
(DCP) Primary Land Use Tax Lot Output, one record per tax lot with more than
100 fields on land use, buildings, zoning, ownership, and assessed value,
plus MapPLUTO, the same records with lot polygons.

Release **26v2** (August 2026). Staged 2026-10-18 by `download-pluto.R`;
every file is listed, with source and size, in `download-log.csv`.

## Relation to `nychomes`

`nychomes` was built from the PLUTO CSV staged in
`data-to-be-packaged/homes/data/opendata/pluto.csv`. That file is **copied**
here, not moved: the homes staging folder and the `nychomes` build are
unchanged. Both copies are release 26v2.

## Contents

```
pluto/
├── README.md
├── download-pluto.R              stages everything below (already run)
├── download-log.csv
├── data/
│   ├── pluto_26v2.csv            PLUTO, no geometry (copy from ../homes)
│   ├── nyc_mappluto_26v2_fgdb.zip
│   ├── mappluto_26v2/            the zip, unpacked
│   │   ├── MapPLUTO26v2.gdb/
│   │   ├── pluto_datadictionary.pdf
│   │   └── pluto_readme.pdf
│   └── pluto_change_file.csv
└── docs/
    ├── pluto_datadictionary.pdf
    ├── pluto_readme.pdf
    ├── pluto_opendata_metadata.json
    └── pluto_change_file_metadata.json
```

## Files

### `data/pluto_26v2.csv` — PLUTO

- Source: NYC Open Data `64uk-42ks` (current release, updated quarterly).
- 858,284 rows, one per tax lot; 108 columns.
- Includes latitude/longitude (lot centroid) but no lot polygons.
- Column names are a mix of styles (`borough`, `Tax block`, `Tax lot`,
  `census tract 2010`, `bldgclass`, `BBL`); standardise to snake_case.
- `BBL` is the 10-digit borough-block-lot key used across NYC data. Read it
  as character (it overflows integers and some tools write it in
  scientific notation).

### `data/mappluto_26v2/MapPLUTO26v2.gdb` — MapPLUTO

- Source: DCP BYTES of the BIG APPLE,
  `https://s-media.nyc.gov/agencies/dcp/assets/files/zip/data-tools/bytes/mappluto/nyc_mappluto_26v2_fgdb.zip`.
- One layer, `MapPLUTO_26v2_clipped`: 856,687 MULTIPOLYGON features, 102
  fields, EPSG:2263 (NAD83 / New York Long Island, US feet). Read with
  `sf::st_read()` (GDAL OpenFileGDB driver).
- Shoreline clipped: lots end at the shoreline. DCP also publishes an
  unclipped ("water included") version and shapefile versions (with field
  names cut to 10 characters); not staged.
- Field names are CamelCase (`BldgClass`, `UnitsRes`, `YearBuilt`). Most
  match the CSV fields case-insensitively; the rest differ in name only:

  | CSV | MapPLUTO |
  |---|---|
  | `Tax block`, `Tax lot` | `Block`, `Lot` |
  | `community board` | `CD` |
  | `census tract 2010` | `CT2010` |
  | `council district` | `Council` |
  | `postcode` | `ZipCode` |
  | `mihopt1`-`mihopt4` | `MIHOption1`-`MIHOption4` |
  | `transitzone` | `TrnstZone` |
  | `mnffar` | `ManuFAR` |

  The CSV also has source-data dates (`basempdate`, `dcasdate`,
  `edesigdate`, `landmkdate`, `masdate`, `polidate`, `rpaddate`,
  `zoningdate`) and a `geom` text column that MapPLUTO lacks; MapPLUTO
  adds `Shape_Leng`, `Shape_Length`, `Shape_Area`.
- About 1,600 fewer features than CSV rows: lots without a mapped polygon.
- Polygons are detailed; at 856k features the full object is large (well
  over 1 GB in memory). Consider storing as GeoParquet and reading lazily,
  as `nychomes` does for sales, rather than as a `LazyData` `.rda`.
- The zip also contains the release's data dictionary and readme (same as
  `docs/`).

### `data/pluto_change_file.csv` — PLUTO Change File

- Source: NYC Open Data `qt5r-nqxp`.
- 42,955 rows: DCP's corrections to source agency values for this release,
  one row per lot and field changed.
- Columns: `BBL`, `field`, `old_value`, `new_value`, `type`, `reason`,
  `version`.

## Notes for packaging

- **Versions.** PLUTO is released several times a year (`YYvN`); every
  release since 2002 is on the DCP site. This folder stages one release.
  Recording `version` on every object would make later updates or a
  multi-release history straightforward.
- **Lots change.** PLUTO describes current lots. Merged, split, or
  renumbered lots break joins to historic data (about 3% of pre-2016 sales
  in `nychomes`).
- **Condos.** A condominium appears as one billing lot (lot 75xx) with
  building-wide totals; individual unit lots (1001-6999) are not in PLUTO.
  `APPBBL` / `APPDate` give the apportionment (prior) BBL. The Property
  Address Directory (`data-to-be-packaged/pad`) maps unit lots to billing
  lots.
- **Codes.** Land use, building class, zoning, ownership type, and others
  are coded; decode tables are in `docs/pluto_datadictionary.pdf`.
- **Possible objects:** `nyc_pluto_df` (all fields, no geometry),
  `nyc_mappluto_sf` (polygons with a core set of fields, or all), decode
  tables for land use and building class, and `nyc_pluto_changes_df`.
