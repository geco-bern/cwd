library(readr)
library(dplyr)
library(here)
library(lubridate)

# get fluxnet data for CH-Lae site
df <- read_csv(paste0(here(), "/inst/extdata/FLX_CH-Lae_FLUXDATAKIT_FULLSET_DD_2004_2014_2-3.csv")) |>
  select(TIMESTAMP, P_F, TA_F_MDS, PA_F, LE_F_MDS, NETRAD) |>
  filter(year(TIMESTAMP) > 2004)

saveRDS(df, file = paste0(here(), "/data/df_ch-lae.rds"))


# get fluxnet data for FR-Pue site
df <- read_csv(paste0(here(), "/inst/extdata/FLX_FR-Pue_FLUXDATAKIT_FULLSET_DD_2000_2014_2-3.csv")) |>
  select(TIMESTAMP, P_F, TA_F_MDS, PA_F, LE_F_MDS, SW_IN_F_MDS, LW_IN_F_MDS, NETRAD)

# visdat::vis_miss(df)

saveRDS(df, file = paste0(here(), "/data/df_fr-pue.rds"))
