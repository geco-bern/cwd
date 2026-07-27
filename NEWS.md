# cwd 3.0.0

* Reworked and simplified cwd:
  * argument `thresh_terminate` removed (i.e. threshold-based event re-setting)
  * argumed `do_surplus` added
* Clarified error message when partial year is run. simulate_snow() requires at least 365
  days (due to snowpack spinup), but allows for partial last year.

# cwd 2.0

* Add `thresh_terminate_absolute` and `doy_reset` as arguments to `cwd()`
* Add `pet()` and `simulate_snow()`, `calc_sat_slope`, and `calc_psychro()`, and `calc_enthalpy_vap()`and `calc_density_h2o()`
* requires R (>= 4.1.0) (since use of e.g. pipe |> in some places)

# cwd 1.0

* Initial version
