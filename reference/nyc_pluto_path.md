# Get the file path to the PLUTO GeoParquet file

Returns the path to the GeoParquet file bundled with this package.
Useful for direct access via arrow, DuckDB, or GDAL.

## Usage

``` r
nyc_pluto_path()
```

## Value

A character string file path.

## Examples

``` r
nyc_pluto_path()
#> [1] "/home/runner/work/_temp/Library/nycpluto/extdata/nyc_pluto.parquet"
```
