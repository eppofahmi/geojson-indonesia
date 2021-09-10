library(spatstat)  # Used for the dirichlet tessellation function
library(maptools)  # Used for conversion from SPDF to ppp
library(raster)    # Used to clip out thiessen polygons
library(tidyverse)
library(readxl)
library(rgdal)
library(tmap)
library(sf)
library(sp)
library(janitor)

# daftar desa di peta ----
daftar_desa <- read_csv("desa/daftar_desa.csv", trim_ws = FALSE)
daftar_desa = clean_names(daftar_desa) 

daftar_desa = daftar_desa %>% 
  rename(kecamatan = kec)
glimpse(daftar_desa)

daftar_desa$desa = gsub("ngoro", "ngoro-oro", daftar_desa$desa)
daftar_desa$desa = gsub("catuharjo", "caturharjo", daftar_desa$desa)
daftar_desa$desa = gsub("sumberahayu", "sumberrahayu", daftar_desa$desa)
daftar_desa$desa = gsub("bangujiwo", "bangunjiwo", daftar_desa$desa)

# daftar dusun bantul ----
daftar_dusun = read_csv("desa/dusun_clean2.csv")
daftar_dusun = clean_names(daftar_dusun)
daftar_dusun = daftar_dusun %>% 
  select(pedukuhan = padukuhan, desa = kalurahan_kelurahan, kecamatan = kapanewon, kabkot = kabupaten)

daftar_dusun$desa = tolower(daftar_dusun$desa)
daftar_dusun$desa = gsub("[[:punct:]]", "", daftar_dusun$desa)
daftar_dusun$desa = gsub("kelurahan ", "", daftar_dusun$desa)
daftar_dusun$desa = gsub("ngorooro", "ngoro-oro", daftar_dusun$desa)
glimpse(daftar_dusun)

daftar_dusun$kecamatan = tolower(daftar_dusun$kecamatan)
daftar_dusun$kabkot = tolower(daftar_dusun$kabkot)

daftar_dusun1 = daftar_dusun %>% 
  left_join(daftar_desa)
glimpse(daftar_dusun1)

# poligon desa ----
df = daftar_dusun1 %>% 
  filter(!is.na(namafile)) %>% 
  count(namafile, kabkot, kecamatan, desa)

# generate random poligon ----
for (i in seq_along(1:nrow(df))) {
  nama_desa = df$desa[i]
  nama_file = df$namafile[i]
  jumlah_dusun = df$n[i]
  kabkot = df$kabkot[i]
  kec = df$kecamatan[i]
  
  if(kabkot == "bantul") {
    folder = "desa/diy/bantul/"
  } else if(kabkot == "gunungkidul") {
    folder = "desa/diy/gk/"
  } else if(kabkot == "kulon progo") {
    folder = "desa/diy/kp/"
  } else if(kabkot == "sleman"){
    folder = "desa/diy/sleman/"
  } else {
    folder = "desa/diy/kota/"
  }
  
  print(paste0("data ke-", i, " ", 'desa-', df$desa[i]))
  # data desa 
  dukuh0 = readOGR(paste0(folder, nama_file))
  
  # random point 
  tes = spsample(dukuh0, n=jumlah_dusun, "random")
  coords = tes@coords
  x = coords[,1]
  y = coords[,2]
  coords = tibble(x, y)
  
  rp = tibble(value = sample(100:150, jumlah_dusun))
  data <- rp[ , 1]
  crs <- CRS(as.character(NA))
  spdf <- SpatialPointsDataFrame(coords = coords,
                                 data = data, 
                                 proj4string = crs)
  
  spdf_x = st_as_sf(spdf)
  spdf@bbox <- dukuh0@bbox
  
  # Create a tessellated surface
  th  <-  as(dirichlet(as.ppp(spdf)), "SpatialPolygons")
  proj4string(th) <- proj4string(spdf)
  th.z <- over(th, spdf, fn=mean)
  th.spdf <- SpatialPolygonsDataFrame(th, th.z)
  
  # nama padukuhan
  df2 = daftar_dusun1 %>% 
    filter(kabkot == kabkot) %>% 
    filter(kecamatan == kec) %>% 
    filter(desa == nama_desa) %>% 
    select(pedukuhan)
  
  # Finally, we'll clip the tessellated  surface to the Texas boundaries
  th.clp <- raster::intersect(dukuh0,th.spdf)
  df3 = th.clp@data
  df3$pedukuhan = df2$pedukuhan
  th.clp@data = df3
  
  th.clp1 = st_as_sf(th.clp)
  if(kabkot == "bantul") {
    st_write(th.clp1, paste0("randompolygon_dusun/diy/bantul/", 
                             kabkot, "-", kec, "-", nama_desa, "-", ".geojson"))
  } else if(kabkot == "gunungkidul") {
    st_write(th.clp1, paste0("randompolygon_dusun/diy/gk/", 
                             kabkot, "-", kec, "-", nama_desa, "-", ".geojson"))
  } else if(kabkot == "kulon progo") {
    st_write(th.clp1, paste0("randompolygon_dusun/diy/kp/", 
                             kabkot, "-", kec, "-", nama_desa, "-",".geojson"))
  } else if(kabkot == "sleman"){
    st_write(th.clp1, paste0("randompolygon_dusun/diy/sleman/",
                             kabkot, "-", kec, "-", nama_desa, "-",".geojson"))
  } else {
    st_write(th.clp1, paste0("randompolygon_dusun/diy/kota/",
                             kabkot, "-", kec, "-", nama_desa, "-",".geojson"))
  }
}
