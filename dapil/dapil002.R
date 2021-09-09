library(sf)
library(jsonlite)
library(tidyverse)
library(leaflet)
library(rgdal)
library(rmapshaper)
library(readxl)

dapil = jsonlite::read_json("dapil/dapil_fix.json", simplifyVector = TRUE)
provinsi = readOGR("dapil/dapil_prov.geojson")
kabkot = readOGR("dapil/dapil_kabkot.geojson")

# data prov
df1 = provinsi@data
df1 = df1 %>% 
  select(id = province_id, name, dapil, sample_value)

df1$id = as.character(df1$id)
glimpse(df1)

# data kabkot
df2 = kabkot@data
df2 = df2 %>% 
  mutate(id = paste0(province_id, kabkot_id)) %>% 
  select(id, name, dapil, sample_value)
glimpse(df2)

# insert data to maps
provinsi@data = df1
kabkot@data = df2

# combine maps
geo_prov = st_as_sf(provinsi)
glimpse(geo_prov)

geo_kabkot = st_as_sf(kabkot)
glimpse(geo_kabkot)

# join maps 
all_maps = bind_rows(geo_prov, geo_kabkot)
glimpse(all_maps)
st_write(all_maps, "dapil/all_maps_dapil.geojson")
