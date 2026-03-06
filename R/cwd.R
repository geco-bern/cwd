#' Cumulative water deficit
#'
#' Derives time series of the cumulative water deficit (CWD), given time series of
#' the daily soil water balance (infiltration minus evapotranspiration). CWD "events"
#' are identified as periods of consecutive days where the CWD is positive (a water deficit).
#' CWD is set to zero after rain has reduced the CWD by a user-defined fraction, relative to
#' maximum CWD attained during the same event.
#'
#' @param df a data frame that contains the variable named according to argument \code{varname_wbal}
#' @param varname_wbal name of the variable representing the daily soil water balance (infiltration minus evapotranspiration)
#' @param varname_date name of the variable representing information about the date (format irrelevant)
#' @param thresh_drop Level, relative to the CWD maximum of the same event, after which all data
#' during the remainder of the event is set to missing values. This is to avoid interpreting data
#' after rain events but before full compensation of CWD. Defaults to 0.9.
#' @param doy_reset Day-of-year (integer) when deficit is to be reset to zero each year. Defaults to
#' \code{NA} (not considered). If \code{doy_reset} is set to a non-NA value, it overrides event termination
#' criteria given by \code{thresh_terminate} or \code{thresh_terminate_absolute}.
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
  do_surplus = FALSE
) {

  # create day-of-year column
  df$doy <- as.integer(format(df[[varname_date]], "%j"))

  inst <- tibble()
  idx <- 0
  iinst <- 1
  idx_max_deficit <- 0

  df <- df |>
    ungroup() |>
    mutate(
      iinst = NA,
      dday = NA,
      deficit = 0,
      iinst_surplus = NA,
      dday_surplus = NA,
      surplus = 0
    )

  ## Cumulate deficit ----------------------------------------------------------
  # search all dates
  while (idx <= (nrow(df) - 1)) {

    # increment row index for data frame df
    idx <- idx + 1

    # if the water balance (prec - et) is negative, start accumulating deficit
    # cumulative negative water balances (deficits)
    if (df[[varname_wbal]][idx] < 0) {
      dday <- 0
      deficit <- 0
      max_deficit <- 0
      iidx <- idx
      found_dropday <- FALSE

      while (
        # avoid going over row length
        iidx <= (nrow(df) - 1) &&

        # Ensure deficit is positive
        (deficit >= 0)

      ) {

        # update
        dday <- dday + 1
        deficit <- deficit - df[[varname_wbal]][iidx]

        # Immediately stop if deficit falls below zero
        if (deficit < 0) {
          break # Exit the loop if deficit is no longer positive
        }

        # record the maximum deficit attained in this event
        if (deficit > max_deficit) {
          # deficit continues increasing
          max_deficit <- deficit
          idx_max_deficit <- iidx
          found_dropday <- FALSE
        }

        # record the day when deficit falls below (thresh_drop) times the current maximum deficit
        if (deficit < (max_deficit * thresh_drop) && !found_dropday) {
          iidx_drop <- iidx
          found_dropday <- TRUE
        }

        # once deficit has fallen below threshold, all subsequent dates are dropped (dday set to NA)
        if (found_dropday) {
          df$iinst[iidx] <- NA
          df$dday[iidx] <- NA
        } else {
          df$iinst[iidx] <- iinst
          df$dday[iidx] <- dday
          iidx_drop <- iidx
        }

        df$deficit[iidx] <- deficit

        # stop accumulating on re-set day
        if (!is.na(doy_reset)){
          if (df$doy[iidx] == doy_reset) {
            if (!found_dropday){
              iidx_drop <- idx
            }
            break
          }
        }

        iidx <- iidx + 1
      }

      # record instance
      this_inst <- data.frame(
        idx_start = idx,
        len = iidx_drop - idx,
        iinst = iinst,
        date_start = df[[varname_date]][idx],
        date_end = df[[varname_date]][iidx_drop - 1],
        max_deficit = max_deficit,
        idx_max_deficit = idx_max_deficit
      )

      inst <- rbind(inst, this_inst)

      # update
      iinst <- iinst + 1
      dday <- 0
      idx <- iidx
    }
  }

  ## Cumulate surplus ----------------------------------------------------------
  if (do_surplus){
    inst_surplus <- tibble()
    idx <- 0
    iinst <- 1
    idx_max_surplus <- 0

    # retain largest deficit events by year
    # inst_ann <- inst |>
    #   # take only annual maxima
    #   mutate(year = lubridate::year(date_start)) |>
    #   group_by(year) |>
    #   filter(max_deficit == max(max_deficit, na.rm = TRUE)) |>
    #   ungroup()

    # faster option for the same as above
    year <- as.POSIXlt(inst$date_start)$year
    jdx <- tapply(
      seq_len(nrow(inst)),
      year,
      \(i) i[which.max(inst$max_deficit[i])]
      )

    inst_ann <- inst[unlist(jdx), ]

    # search all dates
    while (idx <= (nrow(df) - 1)) {

      # increment row index for data frame df
      idx <- idx + 1

      # if the water balance (prec - et) is positive, start accumulating surplus
      if (df[[varname_wbal]][idx] > 0) {
        dday <- 0
        surplus <- 0
        max_surplus <- 0
        iidx <- idx
        found_dropday <- FALSE
        idx_start <- idx

        while (
          # avoid going over row length
          iidx <= (nrow(df) - 1) &&

          # Ensure surplus is positive
          (surplus >= 0)

        ) {

          # update
          dday <- dday + 1
          surplus <- surplus + df[[varname_wbal]][iidx]

          # Immediately stop if surplus falls below zero
          if (surplus < 0) {
            idx_end <- iidx
            break # Exit the loop if surplus is no longer positive
          }

          # record the maximum surplus attained in this event
          if (surplus > max_surplus) {
            # surplus continues increasing
            max_surplus <- surplus
            idx_max_surplus <- iidx
          }

          df$iinst_surplus[iidx] <- iinst
          df$dday_surplus[iidx] <- dday
          df$surplus[iidx] <- surplus

          # stop accumulating when max deficit of preceding deficit event was attained
          tmp <- inst_ann |>
            # identify preceding deficit event
            filter(idx_max_deficit <= iidx) |>
            tail(1)

          if (nrow(tmp) > 0){
            # get day (index) when maximum deficit was attained
            idx_max_deficit <- tmp |>
              pull(idx_max_deficit)

            # exit surplus accumulation
            if (iidx == idx_max_deficit){
              idx_end <- iidx
              break
            }
          }

          iidx <- iidx + 1
        }

        # record instance
        this_inst <- data.frame(
          idx_start = idx,
          len = idx_end - idx,
          iinst = iinst,
          date_start = df[[varname_date]][idx_start],
          date_end = df[[varname_date]][idx_end],
          max_surplus = max_surplus,
          idx_max_surplus = idx_max_surplus
        )

        inst_surplus <- rbind(inst_surplus, this_inst)

        # update
        iinst <- iinst + 1
        dday <- 0
        idx <- iidx
      }
    }
    return(
      list(
        inst = inst,
        df = df,
        inst_surplus = inst_surplus
      )
    )
  } else {
    return(
      list(
        inst = inst,
        df = df
      )
    )
  }

}
