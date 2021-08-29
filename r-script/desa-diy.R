library(sf)
library(jsonlite)
library(tidyverse)
library(leaflet)
library(rgdal)
library(rmapshaper)

desa_diy = st_read("rawdata/BATAS DESA DESEMBER 2019 DUKCAPIL DI YOGYAKARTA/BATAS_DESA_DESEMBER_2019_DUKCAPIL_DI_YOGYAKARTA.shp")
desa_diy = desa_diy %>% 
  select(OBJECT_ID, KODE_DESA, DESA, PROVINSI, KAB_KOTA, KECAMATAN, DESA_KELUR, JUMLAH_PEN, geometry)

colnames(desa_diy) = tolower(colnames(desa_diy))
desa_diy$desa = as.character(desa_diy$desa)
glimpse(desa_diy)

st_write(desa_diy, "desa/desa_diy.geojson")

# Kalurahan trimurti - srandakan - bantul
trimurti = desa_diy %>% 
  filter(desa == "TRIMURTI")
st_write(trimurti, "geojson-test/trimurti.geojson")

# dusun trimurti 
dusun_trimurti = readOGR("geojson-test/dusun-trimurti.geojson")
dusun_trimurti = st_as_sf(dusun_trimurti)
dusun_trimurti$dusun = toupper(dusun_trimurti$dusun)
dusun_trimurti$sample_value = sample(10:100, nrow(dusun_trimurti))
glimpse(dusun_trimurti)

st_write(dusun_trimurti, "geojson-test/bantul/trimurti-srandakan-bantul.geojson")

# tes hasil 
dusun = readOGR("geojson-test/bantul/trimurti-srandakan-bantul.geojson")

## Leaflet
pal = colorNumeric("viridis", dusun$sample_value)

leaflet(dusun) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 0.7,
              fillColor = ~pal(sample_value),
              label = ~paste0(dusun, ": ", prettyNum(sample_value, ","))) %>%
  addLegend("topright", pal = pal, values = ~sample_value,
            title = "Populasi (Ribu Jiwa)", 
            opacity = 0.5, na.label = "")
