#' Density of water
#'
#' Calculates the density of water at a given temperature and pressure. Adopted
#' from implementation by Davis et al. (2017).
#'
#' @param tc Air temperature (degrees Celsius)
#' @param patm Atmospheric pressure (Pa)
#'
#' @details Returns the density of water (kg m-3)
#'
#' @references
#' Chen et al. (1977)
#'
#' Davis, T. W., Prentice, I. C., Stocker, B. D., Thomas, R. T., Whitley, R. J.,
#' Wang, H., Evans, B. J., Gallego-Sala, A. V., Sykes, M. T., & Cramer, W.
#' (2017). Simple process-led algorithms for simulating habitats (SPLASH v.1.0):
#' Robust indices of radiation, evapotranspiration and plant-available moisture.
#' Geoscientific Model Development, 10(2), 689–708.
#' https://doi.org/10.5194/gmd-10-689-2017
#'
#' @export
#'
calc_density_h2o <- function(tc, patm){
  #----------------------------------------------------------------
  # Calculates density of water at a given temperature and pressure
  # Ref: Chen et al. (1977)
  #----------------------------------------------------------------

  # # local variables
  # real :: po, ko, ca, cb
  # real :: pbar               # atmospheric pressure (bar)

  # Calculate density at 1 atm:
  po <- 0.99983952
  + 6.788260e-5  *tc
  - 9.08659e-6   *tc*tc
  + 1.022130e-7  *tc*tc*tc
  - 1.35439e-9   *tc*tc*tc*tc
  + 1.471150e-11 *tc*tc*tc*tc*tc
  - 1.11663e-13  *tc*tc*tc*tc*tc*tc
  + 5.044070e-16 *tc*tc*tc*tc*tc*tc*tc
  - 1.00659e-18  *tc*tc*tc*tc*tc*tc*tc*tc

  # Calculate bulk modulus at 1 atm:
  ko <- 19652.17
  + 148.1830   *tc
  - 2.29995    *tc*tc
  + 0.01281    *tc*tc*tc
  - 4.91564e-5 *tc*tc*tc*tc
  + 1.035530e-7*tc*tc*tc*tc*tc

  # Calculate temperature dependent coefficients:
  ca <- 3.26138
  + 5.223e-4  *tc
  + 1.324e-4  *tc*tc
  - 7.655e-7  *tc*tc*tc
  + 8.584e-10 *tc*tc*tc*tc

  cb <- 7.2061e-5
  - 5.8948e-6  *tc
  + 8.69900e-8 *tc*tc
  - 1.0100e-9  *tc*tc*tc
  + 4.3220e-12 *tc*tc*tc*tc

  # Convert atmospheric pressure to bar (1 bar <- 100000 Pa)
  pbar <- (1.0e-5)*patm

  density_h2o <- 1000.0*po*(ko + ca*pbar + cb*pbar^2.0)/(ko + ca*pbar + cb*pbar^2.0 - pbar)

  return(density_h2o)

}
