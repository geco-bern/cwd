# cwd: Cumulative water deficit algorithm.

The function `cwd::cwd()` derives time series of the cumulative water deficit (CWD), given time series of
the daily soil water balance (infiltration minus evapotranspiration). CWD "events"
are identified as periods of consecutive days where the CWD is positive (a water deficit).
CWD is set to zero after rain has reduced the CWD by a user-defined fraction, relative to
maximum CWD attained during the same event.

## Reference

Please cite the published paper and the code as:

### Published paper

Stocker, B.D., Tumber-Davila, S.J., Konings, A.G., Anderson, M.B., Hain, C. and Jackson, R.B.: Global patterns of water storage in the rooting zones of vegetation, *Nature Geoscience*, https://www.nature.com/articles/s41561-023-01125-2, 2023

### Code 

Benjamin Stocker. (2021). cwd v1.0: R package for cumulative water deficit calculation (v1.0). Zenodo. https://doi.org/10.5281/zenodo.5359053

## Installation

In R:
```r
devtools::install_github("computationales/cwd")
```

## Build website (internal)

Set the package template as the override template to use when rendering
a package documentation using `pkgdown`

``` r
template <- list(package = "gecotemplate")
pkgdown::build_site(devel = FALSE, override = list(template = template))
```

Everything else can be configured as usual via the `_pkgdown.yml` file
as described in the pkgdown documentation.

Alternatively, set the template in \_pkgdown.yml.

``` yaml
template:
  package: gecotemplate
```

### Mathjax

if you want to use Mathjax you’ll need to specify it in the `pkgdown`
config file like so: 

``` yaml
template:
  params:
    mathjax: true
```
