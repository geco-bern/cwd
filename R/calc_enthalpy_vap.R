#' Enthalpy of vaporisation
#'
#' Calculates the enthalpy of vaporisation for converting a mass (flux) into an
#' energy (flux). The enthalpy of vaporization refers to the amount of heat
#' required to change a substance from liquid to vapor at constant pressure. It
#' includes both the internal energy required to overcome intermolecular forces
#' within the liquid and the work done against the surrounding atmosphere.
#' Enthalpy of vaporization and latent heat of vaporization are often used
#' interchangeably, but there is a subtle difference between them. Latent heat
#' of vaporization, on the other hand, specifically refers to the heat required
#' to change a unit mass of a substance from liquid to vapor at its boiling
#' point at constant temperature. It represents the energy needed to overcome
#' intermolecular forces alone.
#'
#' @param tc Air temperature in degrees Celsius
#'
#' @details Returns the enthalpy of vaporisation (J/kg)
#'
#' @references
#' Henderson-Sellers (1984)
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
calc_enthalpy_vap <- function( tc ){
  #----------------------------------------------------------------
  # Calculates the enthalpy of vaporization, J/kg
  # Ref:      Eq. 8, Henderson-Sellers (1984)
  #----------------------------------------------------------------
  # # arguments
  # real, intent(in) :: tc # air temperature, degrees C

  # # function return value
  # real ::  enthalpy_vap # enthalpy of vaporization, J/kg

  enthalpy_vap <- 1.91846e6*((tc + 273.15)/(tc + 273.15 - 33.91))^2

  return( enthalpy_vap )

}
