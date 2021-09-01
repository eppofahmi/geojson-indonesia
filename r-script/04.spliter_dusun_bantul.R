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
  filter(kabkot == 'bantul')

rm(daftar_desa)
glimpse(daftar_desa_bantul)

daftar_desa_bantul = daftar_desa_bantul %>% 
  dplyr::select(desa, namafile)

# daftar dusun bantul 
daftar_dusun_bantul <- read_excel("rawdata/daftar-dusun-bantul.xlsx")
daftar_dusun_bantul$desa = tolower(daftar_dusun_bantul$desa)

daftar_dusun_bantul1 = daftar_dusun_bantul %>% 
  left_join(daftar_desa_bantul)
glimpse(daftar_dusun_bantul1)

daftar_dusun_bantul1 = daftar_dusun_bantul1 %>% 
  count(namafile, kecamatan, desa)

# poligon desa
df = daftar_dusun_bantul1 %>% 
  filter(!is.na(namafile))

# generate random poligon
for (i in seq_along(1:nrow(df))) {
  nama_desa = df$desa[i]
  nama_file = df$namafile[i]
  jumlah_dusun = df$n[i]
  folder = "desa/diy/bantul/"
  
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
  
  # The dirichlet function does not carry over projection information
  # requiring that this information be added manually
  proj4string(th) <- proj4string(spdf)
  
  # The tessellated surface does not store attribute information
  # from the point data layer. We'll use the over() function (from the sp
  # package) to join the point attributes to the tesselated surface via
  # a spatial join. The over() function creates a dataframe that will need to
  # be added to the `th` object thus creating a SpatialPolygonsDataFrame object
  th.z <- over(th, spdf, fn=mean)
  th.spdf <- SpatialPolygonsDataFrame(th, th.z)
  
  # nama padukuhan
  df2 = daftar_dusun_bantul %>% 
    filter(desa == nama_desa) %>% 
    select(1)
  
  # Finally, we'll clip the tessellated  surface to the Texas boundaries
  th.clp <- raster::intersect(dukuh0,th.spdf)
  df3 = th.clp@data
  df3$pedukuhan = df2$pedukuhan
  th.clp@data = df3
  
  th.clp1 = st_as_sf(th.clp)
  st_write(th.clp1, paste0("randompolygon_dusun/diy/bantul/", 
                           tolower(daftar_dusun_bantul1$kecamatan[i]), "-", 
                           daftar_dusun_bantul1$desa[i], 
                           ".geojson"))
  }
