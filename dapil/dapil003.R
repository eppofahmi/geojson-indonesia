library(tidyverse)
library(tidytext)
library(readxl)
library(janitor)

dapil <- read_excel("dapil/dapil.xlsx")
dapil <- clean_names(dapil)
dapil <- dapil %>% 
  mutate(level = case_when(
    daerah_pemilihan == provinsi ~ "PROVINSI", 
    TRUE ~ "KAB/KOT"
  ))


dapil$provinsi = toupper(dapil$provinsi)
dapil$dapil = toupper(dapil$dapil)

glimpse(dapil)

dapil = dapil %>% 
  group_by(provinsi, dapil, level) %>% 
  unnest_tokens(daerah, daerah_pemilihan, token = stringr::str_split, pattern = ", ", to_lower = FALSE)
