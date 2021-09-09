library(sf)
library(jsonlite)
library(tidyverse)
library(leaflet)
library(rgdal)
library(rmapshaper)
library(readxl)

# dapil provinsi ----
dapil_prov <- read_excel("dapil/dapil.xlsx", 
                         sheet = "dapilprov")
dapil_prov$provinsi = toupper(dapil_prov$provinsi)
dapil_prov$provinsi = gsub("BANGKA BELITUNG", "KEPULAUAN BANGKA BELITUNG", dapil_prov$provinsi)
dapil_prov = dapil_prov %>% 
  rename(name = provinsi)
glimpse(dapil_prov)

# geojson
geo_prov = readOGR("provinsi/all_maps_state_indo.geojson")
# geo_prov1 = st_as_sf(geo_prov)
df1 = geo_prov@data
glimpse(df1)

nodata = dapil_prov %>% 
  filter(!name %in% df1$name)
df2 = df1 %>% 
  left_join(dapil_prov)

geo_prov@data = df2
geo_prov1 = st_as_sf(geo_prov)
geo_prov1 = geo_prov1 %>% 
  filter(!is.na(dapil))

st_write(geo_prov1, "dapil/dapil_prov.geojson")

# dapil kabkot ----
geo_kabkot = readOGR("kota/all_maps_city_indo.geojson")
geo_kabkot1 = st_as_sf(geo_kabkot)
daftarkabkot = geo_kabkot@data
daftarkabkot$prov_name = gsub("Nanggroe Aceh Darussalam", "ACEH", daftarkabkot$prov_name)

dapil_kabkot <- read_excel("dapil/dapil.xlsx", 
                           sheet = "dapilkabkot")

dapil_kabkot$kabkot = toupper(dapil_kabkot$kabkot)
dapil_kabkot$provinsi = toupper(dapil_kabkot$provinsi)

dapil_kabkot$kabkot = gsub("KABUPATEN ", "", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("KAB. ", "", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("[[:punct:]]", "", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("MARIAH", "MERIAH", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("BADAGAI", "BEDAGAI", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("TEBANG", "TEBING", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("LABUHANBATU", "LABUHAN BATU", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("LABUHAN BATU II", "LABUHAN BATU SELATAN", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("SIDEMPUAN", "KOTA PADANG SIDEMPUAN", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("GUNUNGSTOLI", "GUNUNGSITOLI", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("NIAS  UTARA", "NIAS UTARA", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("BATUBARA", "BATU BARA", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("PEMATANGSIANTAR", "PEMATANG SIANTAR", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("PEMATANGSIANTAR", "PEMATANG SIANTAR", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("TANJUNGBALAI", "TANJUNG BALAI", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("BINJA", "BINJAI", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("LIMAPULUH KOTO", "LIMA PULUH KOTA", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("BUKIT TINGGI", "BUKITTINGGI", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("BANYUASIN", "BANYU ASIN", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("MUARAENIM ULU SELATAN", "MUARA ENIM", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("PENUKAL ABAB", "PENUKAL ABAB LEMATANG ILIR", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("TULUNGBAWANG BARAT", "TULANG BAWANG BARAT", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("TULUNGBAWANG", "TULANGBAWANG", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("PADENGLANG", "PANDEGLANG", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("GROBONGAN", "GROBOGAN", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("SUKAHARJO", "SUKOHARJO", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("PUWOREJO", "PURWOREJO", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("PROBALINGGO", "PROBOLINGGO", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("NGANJUNG", "NGANJUK", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("KUBU RAYAH", "KUBU RAYA", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("KOTABARU", "KOTA BARU", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("BANJARBARU", "BANJAR BARU", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("SELAYAR", "KEPULAUAN SELAYAR", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("MAKASSAR", "KOTA MAKASSAR", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("PAREPARE", "PARE-PARE", dapil_kabkot$kabkot)
dapil_kabkot$kabkot = gsub("PASARAWAN", "PESAWARAN", dapil_kabkot$kabkot)

dapil_kabkot = dapil_kabkot %>% 
  mutate(kabkot = case_when(
    provinsi == toupper("Nusa Tenggara Timur") & kabkot == "DAYA" ~ "SUMBA BARAT DAYA", 
    TRUE~kabkot
  ))

dapil_kabkot = dapil_kabkot %>% 
  filter(kabkot != "LEMATANG ILIR")

# nama kota yang tidak ada dipeta
geo_kabkot2 = dapil_kabkot %>%
  filter(!kabkot %in% daftarkabkot$name)

dapil_kabkot = dapil_kabkot %>% 
  select(prov_name = provinsi, name = kabkot, dapil)

dapil_kabkot = dapil_kabkot %>% 
  filter(!duplicated(name))

hasildapil = daftarkabkot %>% 
  left_join(dapil_kabkot)


# final geojson
geo_kabkot@data = hasildapil
geo_kabkot3 = st_as_sf(geo_kabkot)
glimpse(geo_kabkot3)

geo_kabkot3 = geo_kabkot3 %>% 
  filter(!is.na(dapil))
st_write(geo_kabkot3, "dapil/dapil_kabkot.geojson")
