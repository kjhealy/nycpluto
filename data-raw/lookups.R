## nyc_pluto_land_use_df, nyc_pluto_bldg_class_df — code lookup tables
##
## Land use categories and their building classes are from Appendix D of
## the PLUTO data dictionary. Building class descriptions are from the DOF
## sales data dictionary, plus the classes DCP adds in PLUTO (Appendix C).

source(here::here("data-raw", "_source.R"))

# -- Land use categories (Appendix D) ----------------------------------------
# A trailing "*" means every building class with that first letter.
nyc_pluto_land_use_df <- tribble(
  ~landuse , ~description                               , ~bldgclasses                                                                                                           ,
  "01"     , "One & Two Family Buildings"               , "A*,B*,Z0"                                                                                                             ,
  "02"     , "Multi-Family Walk-Up Buildings"           , "C0,C1,C2,C3,C4,C5,C6,C8,C9,CM,R1,R2,R3,R6"                                                                            ,
  "03"     , "Multi-Family Elevator Buildings"          , "D0,D1,D2,D3,D4,D5,D8,D9,H6,H7,R4,RD"                                                                                  ,
  "04"     , "Mixed Residential & Commercial Buildings" , "C7,D6,D7,K4,O8,R8,R9,RM,RR,RX,RZ,S*"                                                                                  ,
  "05"     , "Commercial & Office Buildings"            , "G8,GU,GW,H1,H2,H3,H4,H5,H9,HB,HH,HR,HS,J*,K1,K2,K3,K5,K6,K7,K8,K9,O1,O2,O3,O4,O5,O6,O7,O9,P1,R5,R7,RB,RC,RH,RI,RK,RS" ,
  "06"     , "Industrial & Manufacturing"               , "E*,F*,L*,RW"                                                                                                          ,
  "07"     , "Transportation & Utility"                 , "G2,G3,G4,G5,G9,T*,U*,Y6,Y7,Y8,Y9"                                                                                     ,
  "08"     , "Public Facilities & Institutions"         , "H8,I*,M*,N*,P2,P3,P5,P7,P8,P9,RA,W*,Y1,Y2,Y3,Y4,Z1,Z3,Z4,Z5"                                                          ,
  "09"     , "Open Space & Outdoor Recreation"          , "P4,P6,Q*,Z8"                                                                                                          ,
  "10"     , "Parking Facilities"                       , "G0,G1,G6,G7,RG,RP,Z2"                                                                                                 ,
  "11"     , "Vacant Land"                              , "V*"
)

# -- Building classes --------------------------------------------------------
# DOF lists a few codes twice; keep the first description. (Its second G9
# entry is the description of GW, which DCP's list supplies below.)
dof_classes <- read_excel(
  dof_dictionary_xlsx,
  sheet = "Building Classification Codes"
) |>
  clean_names() |>
  transmute(
    bldgclass = str_squish(building_code),
    description = str_to_sentence(str_squish(description)),
    source = "DOF"
  ) |>
  filter(!is.na(bldgclass)) |>
  distinct(bldgclass, .keep_all = TRUE)

# Classes in PLUTO's Appendix C that are not in the DOF dictionary,
# including the condominium classes DCP creates for billing lots.
dcp_classes <- tribble(
  ~bldgclass , ~description                                                   ,
  "GW"       , "Car wash or lubritorium facility"                             ,
  "Q0"       , "Open space"                                                   ,
  "QG"       , "Community gardens"                                            ,
  "RC"       , "Condo; commercial building (mixed commercial unit classes)"   ,
  "RD"       , "Condo; residential building (mixed residential unit classes)" ,
  "RI"       , "Condo; mixed warehouse/factory/industrial and commercial"     ,
  "RM"       , "Condo; mixed residential and commercial"                      ,
  "RX"       , "Condo; mixed residential, commercial, and industrial"         ,
  "RZ"       , "Condo; mixed residential and warehouse"
) |>
  mutate(source = "DCP")

land_use_rules <- nyc_pluto_land_use_df |>
  select(landuse, bldgclasses) |>
  separate_longer_delim(bldgclasses, ",") |>
  mutate(
    prefix = str_detect(bldgclasses, "\\*$"),
    code = str_remove(bldgclasses, "\\*$")
  )

assign_land_use <- function(bldgclass) {
  exact <- land_use_rules |>
    filter(!prefix)
  wild <- land_use_rules |>
    filter(prefix)
  out <- exact$landuse[match(bldgclass, exact$code)]
  by_letter <- wild$landuse[match(str_sub(bldgclass, 1, 1), wild$code)]
  coalesce(out, by_letter)
}

nyc_pluto_bldg_class_df <- bind_rows(
  dof_classes |>
    filter(!bldgclass %in% dcp_classes$bldgclass),
  dcp_classes
) |>
  mutate(
    landuse = assign_land_use(bldgclass),
    .after = description
  ) |>
  arrange(bldgclass)

nyc_pluto_land_use_df <- nyc_pluto_land_use_df |>
  mutate(bldgclasses = str_replace_all(bldgclasses, ",", ", "))

usethis::use_data(
  nyc_pluto_land_use_df,
  nyc_pluto_bldg_class_df,
  overwrite = TRUE,
  compress = "xz"
)
