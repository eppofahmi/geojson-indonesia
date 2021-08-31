library(sf)
library(jsonlite)
library(tidyverse)
library(leaflet)
library(rgdal)
library(rmapshaper)

# per desa
desa_diy = st_read("rawdata/BATAS DESA DESEMBER 2019 DUKCAPIL DI YOGYAKARTA/BATAS_DESA_DESEMBER_2019_DUKCAPIL_DI_YOGYAKARTA.shp")
desa_diy = desa_diy %>% 
  select(OBJECT_ID, KODE_DESA, DESA, PROVINSI, KAB_KOTA, KECAMATAN, DESA_KELUR, JUMLAH_PEN, geometry)

colnames(desa_diy) = tolower(colnames(desa_diy))
desa_diy$desa = as.character(desa_diy$desa)
glimpse(desa_diy)

for (i in seq_along(1:nrow(desa_diy))) {
  print(i)
  peta = desa_diy[i, ]
  st_write(peta, paste0("desa/diy/", 
                        tolower(peta$kab_kota), "-",
                        tolower(peta$kecamatan), "-", 
                        tolower(peta$desa), 
                        ".geojson"))
}

# per dusun/dukuh