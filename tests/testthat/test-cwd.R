test_that("cwd accumulates deficits on a simple synthetic series", {
  df <- data.frame(
    date = as.Date("2001-01-01") + 0:3,
    wbal = c(-2, -3, 2, 3)
  )

  out <- cwd(
    df,
    varname_wbal = "wbal",
    varname_date = "date",
    thresh_drop = 0
  )
  # ggplot(out$df, aes(x=doy, y=wbal)) + geom_point()
  # ggplot(out$df, aes(x=doy, y=deficit)) + geom_point()

  expect_named(out, c("inst", "df"))
  expect_equal(nrow(out$inst), 1)
  expect_equal(out$inst$idx_start, 1)
  expect_equal(out$inst$len, 2)
  expect_equal(out$inst$max_deficit, 5)
  expect_equal(out$df$deficit, c(2, 5, 3, 0))
  expect_equal(out$df$iinst, c(1, 1, 1, NA))
  expect_equal(out$df$dday, c(1, 2, 3, NA))
})

test_that("cwd reproduces the bundled vignette workflow", {
  df <- cwd:::df_CH_LAE
  df <- dplyr::mutate(df, PA_F = 1e3 * PA_F)

  le_to_et <- function(le, tc, patm) {
    1000 * 60 * 60 * 24 * le /
      (cwd::calc_enthalpy_vap(tc) * cwd::calc_density_h2o(tc, patm))
  }

  df <- df |>
    dplyr::mutate(
      et = le_to_et(LE_F_MDS, TA_F_MDS, PA_F),
      prec = ifelse(TA_F_MDS < 0, 0, P_F),
      snow = ifelse(TA_F_MDS < 0, P_F, 0)
    )

  df <- simulate_snow(
    df,
    varnam_prec = "prec",
    varnam_snow = "snow",
    varnam_temp = "TA_F_MDS"
  )

  df <- dplyr::mutate(df, wbal = liquid_to_soil - et)

  out <- cwd(
    df,
    varname_wbal = "wbal",
    varname_date = "TIMESTAMP",
    thresh_drop = 0
  )
  # ggplot(out$df, aes(x=doy, y=wbal)) + geom_point()
  # ggplot(out$df, aes(x=doy, y=deficit)) + geom_point()

  expect_equal(nrow(out$inst), 200)
  expect_equal(sum(!is.na(out$df$iinst)), 2949)
  expect_equal(max(out$df$deficit, na.rm = TRUE), 153.6691, tolerance = 1e-4)
  expect_equal(as.character(out$inst$date_start[which.max(out$inst$max_deficit)]), "2009-05-16")
})




test_that("cwd is possible for partial year (with at least one full year for snow spinup)", {
  df <- cwd:::df_CH_LAE
  df <- dplyr::mutate(df, PA_F = 1e3 * PA_F)

  le_to_et <- function(le, tc, patm) {
    1000 * 60 * 60 * 24 * le /
      (cwd::calc_enthalpy_vap(tc) * cwd::calc_density_h2o(tc, patm))
  }

  df <- df |>
    dplyr::mutate(
      et = le_to_et(LE_F_MDS, TA_F_MDS, PA_F),
      prec = ifelse(TA_F_MDS < 0, 0, P_F),
      snow = ifelse(TA_F_MDS < 0, P_F, 0)
    )

  df_half_year <- df |> dplyr::slice(1:(365*0.5))
  df_one_and_half_year <- df |> dplyr::slice(1:(365*1.5))

  # check only partial year gives error message
  testthat::expect_error(regexp = "At least one full year of data",
    simulate_snow(
      df_half_year,
      varnam_prec = "prec",
      varnam_snow = "snow",
      varnam_temp = "TA_F_MDS"
    )
  )

  # check partial year works if at least on full year
  df_one_and_half_year <- simulate_snow(
    df_one_and_half_year,
    varnam_prec = "prec",
    varnam_snow = "snow",
    varnam_temp = "TA_F_MDS"
  )

  df_one_and_half_year <- dplyr::mutate(df_one_and_half_year, wbal = liquid_to_soil - et)

  out <- cwd(
    df_one_and_half_year,
    varname_wbal = "wbal",
    varname_date = "TIMESTAMP",
    thresh_drop = 0
  )
  # ggplot(out$df, aes(x=doy, y=wbal)) + geom_point()
  # ggplot(out$df |> dplyr::mutate(year = as.factor(lubridate::year(TIMESTAMP))),
  #        aes(x=doy, y=deficit, color = year)) + geom_point()

  expect_equal(nrow(out$inst), 24)
  expect_equal(sum(!is.na(out$df$iinst)), 434)
  expect_equal(max(out$df$deficit, na.rm = TRUE), 76.58413, tolerance = 1e-4)
  expect_equal(as.character(out$inst$date_start[which.max(out$inst$max_deficit)]), "2005-05-24")
})
