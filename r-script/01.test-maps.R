library(sf)
library(jsonlite)
library(tidyverse)
library(leaflet)
library(rgdal)
library(rmapshaper)

# Province ----
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
cities = readOGR("kota/all_kabkota_ind.geojson")

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


# Dapil -----
dapil = readOGR("dapil/all_maps_dapil.geojson")

## Leaflet
pal = colorNumeric("viridis", dapil$sample_value)

leaflet(dapil) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 0.7,
              fillColor = ~pal(sample_value),
              label = ~paste0(dapil, ": ", prettyNum(sample_value, ","))) %>%
  addLegend("topright", pal = pal, values = ~sample_value,
            title = "Populasi (Ribu Jiwa)", 
            opacity = 0.5, na.label = "")

# dusun -----
dusun = readOGR("randompolygon_dusun/diy/bantul/pajangan-guwosari.geojson")

## Leaflet
pal = colorNumeric("viridis", dusun$value)

leaflet(dusun) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 0.7,
              fillColor = ~pal(value),
              label = ~paste0(pedukuhan, ": ", prettyNum(value, ","))) %>%
  addLegend("topright", pal = pal, values = ~value,
            title = "Populasi (Ribu Jiwa)", 
            opacity = 0.5, na.label = "")
