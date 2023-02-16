[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5359053.svg)](https://doi.org/10.5281/zenodo.5359053)

# The cumulative water deficit algorithm

## Context

> The rooting-zone water-storage capacity—the amount of water accessible to plants—controls the sensitivity of land–atmosphere exchange of water and carbon during dry periods. How the rooting-zone water-storage capacity varies spatially is largely unknown and not directly observable. Here we estimate rooting-zone water-storage capacity globally from the relationship between remotely sensed vegetation activity, measured by combining evapotranspiration, sun-induced fluorescence and radiation estimates, and the cumulative water deficit calculated from daily time series of precipitation and evapotranspiration. Our findings indicate plant-available water stores that exceed the storage capacity of 2-m-deep soils across 37% of Earth’s vegetated surface. We find that biome-level variations of rooting-zone water-storage capacities correlate with observed rooting-zone depth distributions and reflect the influence of hydroclimate, as measured by the magnitude of annual cumulative water-deficit extremes. Smaller-scale variations are linked to topography and land use. Our findings document large spatial variations in the effective root-zone water-storage capacity and illustrate a tight link among the climatology of water deficits, rooting depth of vegetation and its sensitivity to water stress.

The function included in this R package `cwd::cwd()` derives time series of the cumulative water deficit (CWD), given time series of the daily soil water balance (infiltration minus evapotranspiration). CWD "events" are identified as periods of consecutive days where the CWD is positive (a water deficit). CWD is set to zero after rain has reduced the CWD by a user-defined fraction, relative to maximum CWD attained during the same event.

## Reference

Please cite the published paper and the code as:

> Stocker, B.D., Tumber-Davila, S.J., Konings, A.G., Anderson, M.B., Hain, C. and Jackson, R.B.: Global patterns of water storage in the rooting zones of vegetation, *Nature Geoscience*, https://www.nature.com/articles/s41561-023-01125-2, 2023

> Benjamin Stocker. (2021). cwd v1.0: R package for cumulative water deficit calculation (v1.0). Zenodo. https://doi.org/10.5281/zenodo.5359053

## Installation

To install and load the `cwd` package using the latest release run the following command in your R terminal: 
```r
if(!require(devtools)){install.packages(devtools)}
devtools::install_github("geco-bern/cwd")
library(cwd)

