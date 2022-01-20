## execute all code in the solution file
try(knitr::knit(text=readLines('PS04_solution.Rmd')))

test_that("Data import", {
  expect_equal(dim(raw_solar), c(82, 9139))
})

test_that("Pivot and rename", {
  expect_equal(nrow(solar), 241502)
  expect_true(all(c("name", "id", "lon", "lat", "elev", "date", "irradiance") 
                  %in% names(solar)))
})

test_that("Dates",{
  expect_s3_class(solar$date, "Date")
  expect_s3_class(solar$month, "factor")
})