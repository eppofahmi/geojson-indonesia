library(spatstat)  # Used for the dirichlet tessellation function
library(maptools)  # Used for conversion from SPDF to ppp
library(raster)    # Used to clip out thiessen polygons
library(tidyverse)
library(readxl)
library(rgdal)
library(tmap)
library(sf)
library(sp)

# daftar desa 
daftar_desa <- read_csv("desa/daftar_desa.csv", 
                        trim_ws = FALSE)

daftar_desa_bantul = daftar_desa %>% 
  filter(kabkot == 'sleman')

rm(daftar_desa)
glimpse(daftar_desa_bantul)

daftar_desa_bantul = daftar_desa_bantul %>% 
  dplyr::select(desa, namafile)

# dukuh sleman
dukuh_sleman <- read_excel("desa/Nama-Padukuhan-se-Kab.Sleman-Resmi-2001.xlsx")
dukuh_sleman <- dukuh_sleman[5:nrow(dukuh_sleman), c(2, 4, 6)]
colnames(dukuh_sleman) = c("kecamatan", "desa", "pedukuhan")

dukuh_sleman[1,2] = "DESA"

for (i in seq_along(1:nrow(dukuh_sleman))) {
  print(i)
  # kecamatan
  if(is.na(dukuh_sleman$kecamatan[i])){
    dukuh_sleman$kecamatan[i] = dukuh_sleman$kecamatan[i-1]
  } else {
    dukuh_sleman$kecamatan[i] = dukuh_sleman$kecamatan[i]
  }
  # desa
  if(is.na(dukuh_sleman$desa[i])){
    dukuh_sleman$desa[i] = dukuh_sleman$desa[i-1]
  } else {
    dukuh_sleman$desa[i] = dukuh_sleman$desa[i]
  }
}

dukuh_sleman = dukuh_sleman %>% 
  filter(!is.na(pedukuhan) | str_detect(pedukuhan, toupper('pedukuhan'))) %>% 
  filter(desa != "desa")

dukuh_sleman$kecamatan = tolower(dukuh_sleman$kecamatan)
dukuh_sleman$desa = tolower(dukuh_sleman$desa)
dukuh_sleman$pedukuhan = tolower(dukuh_sleman$pedukuhan)
dukuh_sleman$desa = gsub("titromartani", "tirtomartani", dukuh_sleman$desa)
dukuh_sleman$desa = gsub("sumberejo", "sumberrejo", dukuh_sleman$desa)

dukuh_sleman2 = dukuh_sleman %>% 
  count(kecamatan, desa)

# tes = dukuh_sleman2 %>% 
#   filter(!desa %in% daftar_desa_bantul$desa)

# poligon desa
df = daftar_desa_bantul %>% 
  left_join(dukuh_sleman2)

# generate random poligon
for (i in seq_along(1:nrow(df))) {
  nama_desa = df$desa[i]
  nama_file = df$namafile[i]
  jumlah_dusun = df$n[i]
  folder = "desa/diy/sleman/"
  
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
  df2 = dukuh_sleman %>% 
    dplyr::filter(desa == nama_desa) %>% 
    dplyr::select(pedukuhan)
  
  # Finally, we'll clip the tessellated  surface to the Texas boundaries
  th.clp <- raster::intersect(dukuh0,th.spdf)
  df3 = th.clp@data
  df3$pedukuhan = df2$pedukuhan
  th.clp@data = df3
  
  th.clp1 = st_as_sf(th.clp)
  st_write(th.clp1, paste0("randompolygon_dusun/diy/sleman/", 
                           tolower(df$kecamatan[i]), "-", 
                           df$desa[i], 
                           ".geojson"))
}
