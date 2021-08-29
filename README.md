## Geojson-indonesia
This is a repo to store and sometimes update geojson file that contains any state and cities in Indonesia

## How to use?
1. You have to download the geojson files 
2. Plot as usual 
3. I also put sample value for plotting example

## Province
```
library(sf)
library(leaflet)

province = readOGR("province/all_maps_state_indo.geojson")

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
```

## Cities
```
library(sf)
library(leaflet)
cities = readOGR("cities/all_maps_city_indo.geojson")
pal = colorNumeric("viridis", cities$sample_value)

leaflet(cities) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 0.7,
              fillColor = ~pal(sample_value),
              label = ~paste0(name, ": ", prettyNum(sample_value, ","))) %>%
  addLegend("topright", pal = pal, values = ~sample_value,
            title = "Populasi (Ribu Jiwa)", 
            opacity = 0.5, na.label = "")
```

## Data

1. Province - contains of 34 state multipolygon
2. Cities - contains of 514 cities/regency multipolygon

## Additional Tools

I use [geojson.io](https://geojson.io) to create some additional geometry and this very helpful [website](https://www.indonesia-geospasial.com/p/sitemap.html) that post some `shapefile` file.
