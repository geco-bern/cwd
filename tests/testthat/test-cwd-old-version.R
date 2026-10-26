# # Reproduction against cwd commit 5878604b06e162786e6ad146220574061736b8b3.
# # Run with that commit installed in the active R library, e.g. Rscript this-file.R.
# # This is the current reset test with only the argument name changed.
# #
# # Changes with current behavior (tested by tests/test-cwd.R) are marked by `NOTE CHANGE`
# #   - off-by 1 changes: about including or not the last day of an instance
# #   - off-by 2 changes: `len` of instances were shorter by 2 days (or 1 day in the case of doy_reset)
# #   - no change: max deficit recorded is the same
# #
# library(testthat)
# devtools::install_github("geco-bern/cwd@5878604b06e162786e6ad146220574061736b8b3", upgrade = "never")
# library(cwd)
#
#
# test_that("cwd resets methods give reasonable results", {
#   testthat::skip_if_not(packageVersion("cwd") == '2.0.0.9000')
#
#   df <- data.frame(
#     date = as.Date("2001-01-01") + 0:(40-1),
#     #  buildup to 100 mm CWD over 10 days, drop by 150 over 30 days
#     wbal = c(-10, -10, -10, -10, -10, -10, -10, -10, -10, -10,
#              5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5)
#   )
#
#   out_reset_0mm     <- cwd(df, varname_wbal = "wbal", varname_date = "date", thresh_drop = 0, doy_reset = 999)
#   out_reset_doy8    <- cwd(df, varname_wbal = "wbal", varname_date = "date", thresh_drop = 0, doy_reset = 8)
#   out_reset_abs10mm <- cwd(df, varname_wbal = "wbal", varname_date = "date", thresh_drop = 0, thresh_terminate_absolute = 10)
#   out_reset_abs20mm <- cwd(df, varname_wbal = "wbal", varname_date = "date", thresh_drop = 0, thresh_terminate_absolute = 20)
#
#   # single event: 10 days buildup + 2 days drop for 10mm   OR 4 days drop for 20mm
#   expect_equal(out_reset_0mm$df$deficit,
#                c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 95, 90, 85, 80, 75,  70, 65, 60, 55, 50, 45, 40, 35, 30, 25, 20, 15, 10, 5,
#                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
#   expect_equal(out_reset_abs10mm$df$deficit,
#                c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 95, 0, # NOTE CHANGE: 0 instead of 90,
#                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
#   expect_equal(out_reset_abs20mm$df$deficit,
#                c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 95, 90, 85, 0, # NOTE CHANGE: 0 instead of 80,
#                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
#   # two events: one from the beginning up to 80mm, then doy_reset, then one event starting on day 9 after reset
#   expect_equal(out_reset_doy8$df$deficit,
#                c(10, 20, 30, 40, 50, 60, 70, 0, # NOTE CHANGE: 0 instead of 80,
#                  10, 20, 15, 10, 5,
#                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
#
#   # check instance identifications:
#   expect_equal(out_reset_0mm$df$iinst,
#                c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, NA, # NOTE CHANGE: NA instead of 1,
#                  NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)) # dput(out_reset_0mm$df$iinst)
#   expect_equal(out_reset_abs10mm$df$iinst,
#                c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, NA, # NOTE CHANGE: NA instead of 1,
#                  NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
#                  NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)) # dput(out_reset_abs10mm$df$iinst)
#   expect_equal(out_reset_abs20mm$df$iinst,
#                c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, NA, # NOTE CHANGE: NA instead of 1,
#                  NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
#                  NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)) # dput(out_reset_abs20mm$df$iinst)
#   expect_equal(out_reset_doy8$df$iinst,
#                c(1, 1, 1, 1, 1, 1, 1, NA, # NOTE CHANGE: NA instead of 1,
#                  2, 2, 2, 2, 2, NA, # NOTE CHANGE: NA instead of 2,
#                  NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
#                  NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)) # dput(out_reset_doy8$df$iinst)
#
#   expect_equal(out_reset_0mm$inst$idx_start,         1)
#   expect_equal(out_reset_abs10mm$inst$idx_start,     1)
#   expect_equal(out_reset_abs20mm$inst$idx_start,     1)
#   expect_equal(out_reset_doy8$inst$idx_start,      c(1,9)) # two events: one on day 9 after reset
#
#   expect_equal(out_reset_0mm$inst$len,             28) # NOTE CHANGE: instead of 30) # 10 days buildup + 20 days drop for 100mm (+ 1 day)
#   expect_equal(out_reset_abs10mm$inst$len,         10) # NOTE CHANGE: instead of 12) # 10 days buildup + 2 days drop for 10mm
#   expect_equal(out_reset_abs20mm$inst$len,         12) # NOTE CHANGE: instead of 14) # 10 days buildup + 4 days drop for 20mm
#   expect_equal(out_reset_doy8$inst$len,        c(7,4)) # NOTE CHANGE: instead of c(8,6))# 2nd event: 2 days buildup to 20mm + 4 days drop for 20mm (to be below 0)
#
#   expect_equal(out_reset_0mm$inst$deficit,     100)
#   expect_equal(out_reset_abs10mm$inst$deficit, 100)
#   expect_equal(out_reset_abs20mm$inst$deficit, 100)
#   expect_equal(out_reset_doy8$inst$deficit,    c(80,20))
# })
