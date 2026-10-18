# Shared code and objects
library(devtools)
library(tidyverse)
library(here)
library(sf)
library(janitor)
library(readxl)
library(DBI)
library(duckdb)

pluto_version <- "26v2"

rawpath <- here("data-raw", "pluto", "data")
pluto_csv <- here(rawpath, paste0("pluto_", pluto_version, ".csv"))
mappluto_gdb <- here(
  rawpath,
  paste0("mappluto_", pluto_version),
  paste0("MapPLUTO", pluto_version, ".gdb")
)
change_csv <- here(rawpath, "pluto_change_file.csv")
dof_dictionary_xlsx <- here(
  "data-raw",
  "dof",
  "annualized_sales_geocoded_Annualized_Calendar_Sales_Update_Data_Dictionary.xlsx"
)
