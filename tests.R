test_that("<5>Solution file exists and knits",{
  expect_true(file.exists("solution.Rmd"))
  suppressWarnings(expect_error(knitr::knit("solution.Rmd", quiet = TRUE, envir=globalenv()), NA))
})

test_that("<1> Data import", {
  expect_error(expect_equal(dim(raw_solar), c(82, 9139)),NA)
})

test_that("<2> Pivot and rename", {
  expect_error(expect_equal(nrow(solar), 241502) , NA)
  expect_error(expect_true(all(c("name", "id", "lon", "lat", "elev", "date", "irradiance") 
                               %in% names(solar))) , NA)
})

test_that("<2> Dallas summary data frame", {
  expect_error(expect_s3_class(solar$date, "Date"), NA)
  expect_error(expect_s3_class(solar$month, "factor"), NA)
  #expect_error( , NA)
  #expect_error( , NA)
  
})
