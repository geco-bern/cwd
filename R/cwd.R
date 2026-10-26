#' Cumulative water deficit
#'
#' Derives time series of the cumulative water deficit (CWD), given time series of
#' the daily soil water balance (infiltration minus evapotranspiration). CWD "events"
#' are identified as periods of consecutive days where the CWD is positive (a water deficit).
#' An event is stopped and CWD is reset to zero in these cases: 
#' a) on a specified day-of-year (`doy_reset`), or after rain has reduced the 
#' CWD b) to 0mm (always active), after rain has reduced the CWD c) to a user-defined 
#' absolute threshold below the maximum CWD attained during the event (`thresh_reset_absolute`).
#'
#' @param df a data frame that contains the variable named according to argument \code{varname_wbal}
#' @param varname_wbal name of the variable representing the daily soil water balance (infiltration minus evapotranspiration)
#' @param varname_date name of the variable representing information about the date (format irrelevant)
#' @param thresh_drop Level, relative to the CWD maximum of the same event, after which all data
#' during the remainder of the event is set to missing values. This is to avoid interpreting data
#' after rain events but before full compensation of CWD. Defaults to 0.9.
#' @param doy_reset Day-of-year (integer) when CWD is to be reset to zero each year. Defaults to
#' \code{NA} (not considered).
#' @param thresh_reset_absolute Amount by which CWD must fall below the maximum CWD attained during
#' the event to reset it to zero. Units are the same as \code{varname_wbal}. Defaults to \code{NA}
#' (not considered).
#' @param do_surplus A logical specifying whether the cumulative surplus should be calculated.
#' Defaults to \code{FALSE}.
#'
#' @details A list of two data frames (tibbles). \code{inst} contains information about CWD "events".
#' Each row corresponds to one event. An event is defined as a period of consecutive days where the
#' CWD is positive (a water deficit) and has the following columns:
#'
#' \code{idx_start}: row number of \code{df} of which the date corresponds to the start of the event
#' \code{len}: length of the event, quantified as number of rows in \code{df} corresponding to the event
#' \code{iinst}: event number
#' \code{date_start}: starting date of the event, formatted as \code{varname_date} in \code{df}.
#' \code{date_end}: end date of the event, formatted as \code{varname_date} in \code{df}.
#' \code{deficit}: maximum CWD recorded during this event. Units correspond to units of \code{varname_wbal}
#' in \code{df}.
#'
#' @export
#'
cwd <- function(
  df,
  varname_wbal,
  varname_date,
  thresh_drop = 0.0,
  doy_reset = NA,
  thresh_reset_absolute = NA,
  do_surplus = FALSE
) {
  # Keep data-frame and date handling in R so the public API and column classes
  # remain unchanged. The computational event scans are performed in C++.
  df$doy <- as.integer(format(df[[varname_date]], "%j"))
  df <- df |>
    dplyr::ungroup() |>
    dplyr::mutate(
      iinst = NA,
      dday = NA,
      deficit = 0,
      iinst_surplus = NA,
      dday_surplus = NA,
      surplus = 0
    )

  core <- cwd_deficit_cpp(
    as.numeric(df[[varname_wbal]]),
    df$doy,
    thresh_drop,
    doy_reset,
    thresh_reset_absolute
  )
  df$iinst <- core$iinst
  df$dday <- core$dday
  df$deficit <- core$deficit

  events <- core$events
  if (nrow(events) == 0L) {
    inst <- tibble::tibble()
  } else {
    inst <- data.frame(
      idx_start = as.numeric(events$idx_start),
      len = as.numeric(events$len),
      iinst = as.numeric(events$iinst),
      date_start = df[[varname_date]][events$idx_start],
      date_end = df[[varname_date]][events$date_end_idx],
      max_deficit = events$max_deficit,
      idx_max_deficit = as.numeric(events$idx_max_deficit)
    )
  }

  if (do_surplus) {
    year <- as.POSIXlt(inst$date_start)$year
    jdx <- tapply(
      seq_len(nrow(inst)),
      year,
      \(i) i[which.max(inst$max_deficit[i])]
      )
    inst_ann <- inst[unlist(jdx), ]
    surplus_core <- cwd_surplus_cpp(
      as.numeric(df[[varname_wbal]]),
      inst_ann$idx_max_deficit
    )
    df$iinst_surplus <- surplus_core$iinst_surplus
    df$dday_surplus <- surplus_core$dday_surplus
    df$surplus <- surplus_core$surplus

    surplus_events <- surplus_core$events
    if (nrow(surplus_events) == 0L) {
      inst_surplus <- tibble::tibble()
    } else {
      inst_surplus <- data.frame(
        idx_start = as.numeric(surplus_events$idx_start),
        len = as.numeric(surplus_events$len),
        iinst = as.numeric(surplus_events$iinst),
        date_start = df[[varname_date]][surplus_events$idx_start],
        date_end = df[[varname_date]][surplus_events$idx_end],
        max_surplus = surplus_events$max_surplus,
        idx_max_surplus = as.numeric(surplus_events$idx_max_surplus)
      )
    }

    return(list(inst = inst, df = df, inst_surplus = inst_surplus))
  }

  list(inst = inst, df = df)
}
