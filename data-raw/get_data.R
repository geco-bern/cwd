library(readr)
library(dplyr)
library(here)

# get fluxnet data for CH-Lae site
df_CH_LAE <- readr::read_csv(paste0(here::here(), "/inst/extdata/FLX_CH-Lae_FLUXDATAKIT_FULLSET_DD_2004_2014_2-3.csv")) |>
  select(TIMESTAMP, P_F, TA_F_MDS, PA_F, LE_F_MDS, NETRAD) |>
  filter(year(TIMESTAMP) > 2004)

saveRDS(df, file = paste0(here(), "/data/df_ch-lae.rds"))

# get fluxnet data for FR-Pue site
df_FR_PUE <- readr::read_csv(paste0(here::here(), "/inst/extdata/FLX_FR-Pue_FLUXDATAKIT_FULLSET_DD_2000_2014_2-3.csv")) |>
  select(TIMESTAMP, P_F, TA_F_MDS, PA_F, LE_F_MDS, SW_IN_F_MDS, LW_IN_F_MDS, NETRAD)


saveRDS(df, file = paste0(here(), "/data/df_fr-pue.rds"))

# get fluxnet data for FR-Pue site
df_US_VAR <- read_csv("~/data_2/FluxDataKit/v3.4/zenodo_upload/fluxnet/FLX_US-Var_FLUXDATAKIT_FULLSET_DD_2000_2021_2-3.csv") |>
  select(TIMESTAMP, P_F, TA_F_MDS, PA_F, LE_F_MDS, SW_IN_F_MDS, LW_IN_F_MDS, NETRAD)


saveRDS(df_US_VAR, file = paste0(here(), "/data/df_US-Var.rds"))

# usethis::use_data(df_FR_PUE, internal = TRUE)
# saveRDS(df_FR_PUE, file = paste0(here::here(), "/data/df_fr-pue.rds"))

# usethis::use_data(df_CH_LAE, internal = TRUE)
# saveRDS(df_CH_LAE, file = paste0(here::here(), "/data/df_ch-lae.rds"))

usethis::use_data(df_CH_LAE, df_FR_PUE, df_US_VAR, internal = TRUE, overwrite = TRUE)
# this saves all data sets internally to "./R/sysdata.rda"
# to be used as: cwd:::df_CH_LAE, and cwd:::df_FR_PUE
