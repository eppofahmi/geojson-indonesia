library(tidyverse)
library(readxl)
library(rgdal)
library(tmap)
library(sf)
library(sp)
library(spatstat)  # Used for the dirichlet tessellation function
library(maptools)  # Used for conversion from SPDF to ppp
library(raster)    # Used to clip out thiessen polygons

jumlah_dusun = 22

# data desa 
dukuh0 = readOGR("desa/diy/bantul/bantul-pajangan-triwidadi.geojson")

# random point 
tes = spsample(dukuh0, n=jumlah_dusun, "random")
coords = tes@coords
x = coords[,1]
y = coords[,2]
coords = tibble(x, y)

rp = tibble(value = sample(100:1000, jumlah_dusun))
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

# Finally, we'll clip the tessellated  surface to the Texas boundaries
th.clp <- raster::intersect(dukuh0,th.spdf)
class(th.clp)

# Map the data
tm_shape(th.clp) + 
  tm_polygons(col="value", palette="RdBu", auto.palette.mapping=FALSE,
              title="Predicted precipitation \n(in inches)") +
  tm_legend(legend.outside=TRUE)

th.clp1 = st_as_sf(th.clp)
st_write(th.clp1, "tes-oto-dukuh.geojson")

