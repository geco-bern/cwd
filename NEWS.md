# cwd (development version)
* Added back previously removed arguments:
  * argument `thresh_reset_absolute` (i.e. absolute threshold-based event re-setting, 
  same as previous `thresh_terminate_absolute`).
* Fix: bug where length of deficit instance included day after drop below 0mm
* Breaking change: instances terminated by `doy_reset` now always include last day (even if 
  it would have a drop). Result change is expected to be very limited (off-by 1 day at most). 
  Moreover, this is expected to be an edge case, given that `doy_reset` is expected to be set 
  outside of periods with strong deficits.

# cwd 3.0.2
* Fix: bug where deficit of last time step was uninitialised (zero).

# cwd 3.0.1

## Internal
* Refactored internal code for faster code execution (C++ instead of R).

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
