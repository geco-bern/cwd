test_that("calc_density_h2o and calc_enthalpy_vap return stable physical values", {
  expect_equal(calc_density_h2o(20, 101325), 999.8911, tolerance = 1e-4) # kg/m3
  expect_equal(calc_enthalpy_vap(20), 2453175, tolerance = 0.5)          # J/kg
  expect_true(calc_enthalpy_vap(10) > calc_enthalpy_vap(20))             # J/kg
  expect_true(calc_enthalpy_vap(20) > calc_enthalpy_vap(30))             # J/kg
})

test_that("pet returns expected values in vector and data frame form", {
  out_vec <- pet(netrad = c(100, 200),     # W/m2 ==> mm/s
                 tc = c(20, 25),           # degC ==> mm/s
                 patm = c(101325, 95000)   # Pa   ==> mm/s
  ) # mm/s
  out_df <- pet(netrad = c(100, 200),     # W/m2 ==> mm/s
                tc = c(20, 25),           # degC ==> mm/s
                patm = c(101325, 95000),  # Pa   ==> mm/s
                return_df = TRUE
  ) # mm/s

  expected_pet <- c(3.5021398371492e-05, 7.70934386055099e-05) # mm/s

  expect_s3_class(out_df, "tbl_df")
  expect_named(out_df, "pet")
  expect_lt(max(abs(out_df$pet - expected_pet)), 1e-12)
  expect_lt(max(abs(out_vec - expected_pet)), 1e-12)
})

test_that("simulate_snow conserves a simple snow accumulation and melt sequence", {
  df <- tibble::tibble(
    temp = c(rep(-5, 180), rep(3, 185)),
    rain = c(rep(0, 200), rep(1, 165)),
    snow = c(rep(2, 180), rep(0, 185))
  )

  out <- simulate_snow(df, "temp", "rain", "snow")
  # ggplot(out |> mutate(doy = 1:n()), aes(x=doy, y=temp)) + geom_point()
  # ggplot(out |> mutate(doy = 1:n()), aes(x=doy, y=rain)) + geom_point()
  # ggplot(out |> mutate(doy = 1:n()), aes(x=doy, y=snow)) + geom_point()
  # ggplot(out |> mutate(doy = 1:n()), aes(x=doy, y=snow_pool)) + geom_point()

  expect_named(out, c("temp", "rain", "snow", "liquid_to_soil", "snow_pool"))
  expect_equal(out$snow_pool[1], 2)
  expect_equal(out$liquid_to_soil[181], 2)
  expect_equal(tail(out$snow_pool, 6), rep(0,6))
  expect_equal(sum(out$liquid_to_soil), 525)
})

