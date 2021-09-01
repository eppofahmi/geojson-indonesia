library(sf)
library(jsonlite)
library(tidyverse)
library(leaflet)
library(rgdal)
library(rmapshaper)

# Province ----
## Geojson ----
province = readOGR("provinsi/all_maps_state_indo.geojson")

## Leaflet
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

# Cities ----
## Geojson ----
cities = readOGR("kota/all_maps_city_indo.geojson")

## Leaflet
pal = colorNumeric("viridis", cities$sample_value)

leaflet(cities) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 0.7,
              fillColor = ~pal(sample_value),
              label = ~paste0(name, ": ", prettyNum(sample_value, ","))) %>%
  addLegend("topright", pal = pal, values = ~sample_value,
            title = "Populasi (Ribu Jiwa)", 
            opacity = 0.5, na.label = "")
