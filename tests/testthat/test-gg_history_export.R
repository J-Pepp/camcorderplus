test_that("gg_history_export completes successfully", {
  result <- capture.output(source("gg_history_export_test_script.R"))

  output_files <- list.files(file.path(tempdir(), "gg_history_export"), full.names = TRUE)

  expect_true(any(grepl("\\.tif$", output_files)), info = "Missing .tif file")
  expect_true(any(grepl("\\.pptx$", output_files)), info = "Missing .pptx file")
  expect_true(any(grepl("\\.zip$", output_files)), info = "Missing .zip file")

  unlink(file.path(tempdir(), "gg_history_export"), recursive = TRUE)
})
