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

glimpse(dapil)

