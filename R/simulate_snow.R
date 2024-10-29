#' Simulate snow mass
#'
#' Simulate snow mass accumulation and melt based on Orth et al. (2013)
#' https://www.jstor.org/stable/24914341
#'
#' @param df A data frame containing columns for air temperature (deg. C),
#' precipitation in liquid form (rain, mm d-1), and precipitation in solid form
#' (snow water equivalents, mm d-1). The column names of the respective
#' variables are provided by the other arguments.
#' @param varnam_temp A character string specifying the variable name for air
#' temperature.
#' @param varnam_prec A character string specifying the variable name for rain.
#' @param varnam_snow A character string specifying the variable name for snow.
#'
#' @details Returns a data frame with two added columns: (1) \code{liquid_to_soil}
#' is the rain plus snow melt in mm d-1; (2) \code{snow_pool} is the snow mass
#' in water equivalents (mm) for each day.
#'
#' @export
#'
simulate_snow <- function(df, varnam_temp, varnam_prec, varnam_snow){

  temp <- df |> dplyr::pull(!!varnam_temp)
  prec <- df |> dplyr::pull(!!varnam_prec)
  snow <- df |> dplyr::pull(!!varnam_snow)

  ## fixed parameters
  temp_threshold <- 1.0
  maxmeltrate <- 1.0

  snow_pool <- 0
  liquid_to_soil <- rep(NA, length(prec))
  snow_pool_out <- rep(NA, length(prec))

  ## spinup 1 year
  for (doy in 1:365){
    if ( snow_pool > 0.0 && temp[doy] > temp_threshold ){
      melt  <- min( snow_pool, maxmeltrate * ( temp[doy] - temp_threshold ) )
    } else {
      melt <- 0.0
    }
    snow_pool <- snow_pool + snow[doy] - melt
  }

  ## transient forward
  for (doy in 1:length(prec)){
    if ( snow_pool > 0.0 && temp[doy] > temp_threshold ){
      melt  <- min( snow_pool, maxmeltrate * ( temp[doy] - temp_threshold ) )
    } else {
      melt <- 0.0
    }
    snow_pool <- snow_pool + snow[doy] - melt
    liquid_to_soil[doy] <- prec[doy] + melt
    snow_pool_out[doy] <- snow_pool
  }

  ## complement
  df$liquid_to_soil <- liquid_to_soil
  df$snow_pool <- snow_pool_out

  return(df)

}
