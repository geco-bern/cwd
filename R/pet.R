#' Priestley-Taylor potential evapotranspiration
#'
#' Calculates the potential evapotranspiration using the implementation by
#' Davis et al (2017), based on Priestley & Taylor (1972)
#'
#' @param netrad Net radiation (W m-2)
#' @param tc Air temperature in degrees Celsius
#' @param patm Atmospheric pressure (Pa)
#' @param return_df A logical specifying whether to return a data frame with a
#' single column containing potential evapotranspiration. Defaults to \code{FALSE}
#'
#' @details Potential evapotranspiration (mm s-1)
#'
#' @references
#' Davis, T. W., Prentice, I. C., Stocker, B. D., Thomas, R. T., Whitley, R. J.,
#' Wang, H., Evans, B. J., Gallego-Sala, A. V., Sykes, M. T., & Cramer, W.
#' (2017). Simple process-led algorithms for simulating habitats (SPLASH v.1.0):
#' Robust indices of radiation, evapotranspiration and plant-available moisture.
#' Geoscientific Model Development, 10(2), 689–708.
#' https://doi.org/10.5194/gmd-10-689-2017
#'
#' Priestley, C. H. B., & Taylor, R. J. (1972). On the Assessment of Surface
#' Heat Flux and Evaporation Using Large-Scale Parameters. Monthly Weather
#' Review, 100(2), 81–92. https://doi.org/10.1175/1520-0493
#'
#'
#' @export
#'
pet <- function(netrad, tc, patm, return_df = FALSE){

  par_splash <- list(
		kTkelvin = 273.15,  # freezing point in K (= 0 deg C)
		kTo = 298.15,       # base temperature, K (from P-model)
		kR  = 8.31446262,   # universal gas constant, J/mol/K (Allen, 1973)
		kMv = 18.02,        # molecular weight of water vapor, g/mol (Tsilingiris, 2008)
		kMa = 28.963,       # molecular weight of dry air, g/mol (Tsilingiris, 2008) XXX this was in SPLASH (WITH 1E-3 IN EQUATION) XXX
		kfFEC = 2.04,       # from flux to energy conversion, umol/J (Meek et al., 1984)
		kPo = 101325,       # standard atmosphere, Pa (Allen, 1973)
		kL  = 0.0065,       # temperature lapse rate, K/m (Cavcar, 2000)
		kG  = 9.80665,      # gravitational acceleration, m/s^2 (Allen, 1973)
		k_karman = 0.41,    # Von Karman constant; from bigleaf R package
		eps = 9.999e-6,     # numerical imprecision allowed in mass conservation tests
		cp = 1004.834,      # specific heat of air for constant pressure (J K-1 kg-1); from bigleaf R package
		Rd = 287.0586,      # gas constant of dry air (J kg-1 K-1) (Foken 2008 p. 245; from bigleaf R package)
		alpha = 1.26        # Priestly-Taylor coefficient, = 1 + omega, with omega being the entrainment factor, Eq. (22) in Davis et al.
		)

  sat_slope <- calc_sat_slope(tc)
  lv <- calc_enthalpy_vap(tc)
  pw <- calc_density_h2o(tc, patm)
  gamma <- calc_psychro(tc, patm, par_splash)
  econ <- sat_slope / (lv * pw * (sat_slope + gamma))  # units: m3 J−1

  # equilibrium evapotranspiration in mm s-1
  eet <- netrad * econ * 1000

  # Priestley-Taylor potential evapotranspiration
  pet <- par_splash$alpha * eet

  if (return_df){
    return(tibble(pet = pet))
  } else {
    return(pet)
  }

}

calc_patm <- function( elv, par ){
  #----------------------------------------------------------------
  # Calculates atmospheric pressure for a given elevation, assuming
  # standard atmosphere at sea level (kPo)
  # Ref:      Allen et al. (1998)
  # This function is copied from SPLASH
  #----------------------------------------------------------------
  # use md_params_core, only: kPo, kL, kTo, kG, kMa, kR

  # # arguments
  # real, intent(in) :: elv # elevation above sea level, m

  # # function return value
  # real ::  patm ! atmospheric pressure (Pa)

  patm <- par$kPo * (1.0 - par$kL * elv / par$kTo) ^ (par$kG * par$kMa * 1.e-3 / (par$kR * par$kL))

  return(patm)

}


calc_sat_slope <- function( tc ){
  #----------------------------------------------------------------
  # Calculates the slope of the sat pressure temp curve, Pa/K
  # Ref:      Eq. 13, Allen et al. (1998)
  #----------------------------------------------------------------
  # # arguments
  # real, intent(in) :: tc # air temperature, degrees C

  # # function return value
  # real :: sat_slope  # slope of the sat pressure temp curve, Pa/K

  sat_slope <- (17.269)*(237.3)*(610.78)*(exp(tc*17.269/(tc + 237.3))/((tc + 237.3)^2))

	return( sat_slope )

}

calc_psychro <- function( tc, press, par_splash ){
  #----------------------------------------------------------------
  # Calculates the psychrometric constant for a given temperature and pressure
  # Ref: Allen et al. (1998); Tsilingiris (2008)
  #----------------------------------------------------------------
  # # arguments
  # real, intent(in) :: tc     # air temperature, degrees C
  # real, intent(in) :: press  # atmospheric pressure, Pa

  # # local variables
  # real :: lv  # latent heat of vaporization (J/kg)
  # real :: cp

  # # function return value
  # real :: psychro  # psychrometric constant, Pa/K

  # # local variables
  # real :: my_tc    # adjusted temperature to avoid numerical blow-up

  # Adopted temperature adjustment from SPLASH, Python version
  my_tc <- tc

	my_tc <- ifelse(tc > 100, 100, ifelse(tc < 0, 0, tc))

  # Calculate the specific heat capacity of water, J/kg/K
  # Eq. 47, Tsilingiris (2008)
  cp <- 1.0e3*(1.0045714270
			    + 2.050632750e-3  *my_tc
				  - 1.631537093e-4  *my_tc*my_tc
				  + 6.212300300e-6  *my_tc*my_tc*my_tc
				  - 8.830478888e-8  *my_tc*my_tc*my_tc*my_tc
				  + 5.071307038e-10 *my_tc*my_tc*my_tc*my_tc*my_tc
          )

  # Calculate latent heat of vaporization, J/kg
  lv <- calc_enthalpy_vap(tc)

  # Calculate psychrometric constant, Pa/K
  # Eq. 8, Allen et al. (1998)
  psychro <- cp * par_splash$kMa * press / (par_splash$kMv * lv)

  return(psychro)

}


