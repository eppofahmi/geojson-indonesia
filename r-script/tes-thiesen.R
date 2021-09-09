library(tidyverse)
library(readxl)
library(rgdal)
library(tmap)
library(sf)
library(sp)
library(spatstat)  # Used for the dirichlet tessellation function
library(maptools)  # Used for conversion from SPDF to ppp
library(raster)    # Used to clip out thiessen polygons

tesmap = readOGR("trimurti-srandakan-bantul.geojson")
tesmap = st_as_sf(tesmap)


pal = colorNumeric("viridis", province$sample_value)

leaflet(province) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 0.7,
              fillColor = ~pal(sample_value),
              label = ~paste0(name, ": ", prettyNum(sample_value, ","))
  ) %>%
  addLegend("topright", pal = pal, values = ~sample_value,
            title = "Populasi (Ribu Jiwa)", 
            opacity = 0.5, na.label = "")