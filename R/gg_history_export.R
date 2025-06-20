#' gg_history_export
#'
#' Adaptation of camcorder::gg_playback that provides options to export in additional formats. This functions requires the use of camcorder::gg_record to generate the images for export.
#'
#' @importFrom ggplot2 ggplot aes geom_point
#' @importFrom dplyr filter mutate
#' @importFrom progress progress_bar
#' @importFrom utils packageVersion
#'
#' @param name The base name for export files.
#' @param export_device Image format to export (e.g., "png").
#' @param to_powerpoint Whether to export to PowerPoint.
#' @param to_zip Whether to zip exported files.
#' @param ppt_name Name of the PowerPoint file.
#' @param zip_name Name of the zip file.
#' @param export_folder Destination folder for exports.
#' @param create_export_folder Create the folder if it doesn't exist.
#' @param progress Show a progress bar.
#' @param stoprecording Stop recording after export?
#' @param regex_pattern Optional regex filter for plots.
#' @param ... Additional arguments passed to export functions.
#'
#' @export

gg_history_export <- function(name = NULL, export_device = c("png", "pdf", "jpeg", "bmp", "tiff", "emf", "svg", "eps", "ps"),
                              to_powerpoint = TRUE, to_zip = TRUE, ppt_name = NULL, zip_name = NULL, export_folder = NULL, create_export_folder = FALSE, progress = interactive(), stoprecording = FALSE, regex_pattern = "\\d{4}_\\d{2}_\\d{2}_\\d{2}_\\d{2}_\\d{2}\\.\\d+", ...) {

  #### Checks `camcorder` version ####
  if(packageVersion("camcorder") != "0.1.0") {warning("package:camcorderplus has not be tested on versions of camcorder except version '0.1.0'")}

  #### Check and create final export folder ####
  if (is.null(export_folder)) {
    export_folder <- base::file.path(camcorder:::GG_RECORDING_ENV$recording_dir, "gg_history_export")
    warning(sprintf("As `export_folder` has been left blank, an export folder may be created at '%s'.", gsub("\\\\", "/", base::file.path(camcorder:::GG_RECORDING_ENV$recording_dir, "gg_history_export"))))
  }

  if (!dir.exists(export_folder)) {
    warning(sprintf("Export destination `%s` is not a valid directory, or does not exist.", export_folder))
    if (create_export_folder) {
      dir.create(export_folder, recursive = TRUE)
      warning(sprintf("An export folder was created at '%s'.", gsub("\\\\", "/", base::file.path(camcorder:::GG_RECORDING_ENV$recording_dir, "gg_history_export"))))
    } else {
        stop(sprintf("Function stopped. Directory '%s' does not exist, and permission was not explicitly provided to create it, so there is no vaild folder for files to be saved to.", export_folder))
      }
  }

  #### Gets path to saved images ####
  records <- camcorder:::get_file_records(full_path = TRUE)
  if (length(records) == 0) {
    warning("No images recorded to playback.")
    invisible()
  }

  #### Creates a powerpoint if to_powerpoint = TRUE ####
  if (to_powerpoint == TRUE) {
    # Creates a temporary dir for storing pngs for the ppt
    ppt_png <- base::file.path(camcorder:::GG_RECORDING_ENV$recording_dir, "ppt_png")
    try(if(dir.exists(ppt_png)){unlink(ppt_png, recursive = TRUE)})
    dir.create(ppt_png)

    # Converts images into png using the same file name as gg_record originally writes using regex
    for (image_path in records) {
      image <- magick::image_read(path = image_path)
      image <- magick::image_write(image = image,
                                   path = base::file.path(ppt_png, paste0(regmatches(image_path, regexpr(regex_pattern, image_path)),
                                                                    ".png")) , format = "png")
    }

    # Gets ppt pngs file paths
    converted_images <- list.files(ppt_png)

    # Create a new PowerPoint
    ppt <- officer::read_pptx()

    # Get slide dimensions in inches
    slide_dims <- officer::slide_size(ppt)
    slide_width <- slide_dims$width
    slide_height <- slide_dims$height

    # Progress bar
    pb <- progress::progress_bar$new(format = "  Writing slide :current of :total [:bar] :percent eta: :eta",
                                     total = length(converted_images), clear = FALSE, width = 60)

    # Loop through images
    for (image_path in converted_images) {
      # Get image dimensions in pixels
      img_info <- magick::image_read(base::file.path(ppt_png, image_path))
      img_size <- magick::image_info(img_info)
      img_width_px <- img_size$width
      img_height_px <- img_size$height

      # Convert pixels to inches based on saved camcorder:::GG_RECORDING_ENV$image_dpi
      img_width_in <- img_width_px / camcorder:::GG_RECORDING_ENV$image_dpi
      img_height_in <- img_height_px / camcorder:::GG_RECORDING_ENV$image_dpi

      # Scale to fit the slide while preserving aspect ratio
      scale <- min(slide_width / img_width_in, slide_height / img_height_in)
      final_width <- img_width_in * scale
      final_height <- img_height_in * scale

      # Center the image
      left <- (slide_width - final_width) / 2
      top <- (slide_height - final_height) / 2

      # Add slide and insert image
      ppt <- officer::add_slide(ppt, layout = "Blank", master = "Office Theme")
      ppt <- officer::ph_with(ppt,
                     value = officer::external_img(base::file.path(ppt_png, image_path), width = final_width, height = final_height),
                     location = officer::ph_location(left = left, top = top, width = final_width, height = final_height))

      # Tick progress bar
      pb$tick()
      }

    #### Saves created powerpoint ####
    if (is.null(ppt_name)) {
      print(ppt, target = base::file.path(export_folder, paste0(format(Sys.time(), "%Y.%m.%d-%H.%M.%S"),
                                           "_exported_ggplots.pptx")))
    } else {
      print(ppt, target = base::file.path(export_folder, paste0(format(Sys.time(), "%Y%m%d"), "-", ppt_name,"_exported_ggplots.pptx")))
    }
  }

  #### Create a zip of all recorded images ####
  if (to_zip) {
    # Get full paths of matching files
    recording_dir <- camcorder:::GG_RECORDING_ENV$recording_dir
    files <- list.files(recording_dir, full.names = TRUE)
    recorded_files <- files[grepl(regex_pattern, basename(files))]

    #### Creates and saves zip file ####
    if (is.null(zip_name)) {
      zip::zip(files = recorded_files, zipfile =  base::file.path(export_folder, paste0(format(Sys.time(), "%Y.%m.%d-%H.%M.%S"),
                                                          "_exported_ggplots.", camcorder:::GG_RECORDING_ENV$device_ext, ".zip")), mode = "cherry-pick")
    } else {
      zip::zip(files = recorded_files, zipfile =  base::file.path(export_folder, paste0(format(Sys.time(), "%Y%m%d"), "-", ppt_name,"_exported_ggplots", camcorder:::GG_RECORDING_ENV$device_ext, ".zip")), mode = "cherry-pick")
    }
  }

  #### Move original copies to new storage location using previous regex pattern ####
  # Get full paths of matching files
  recording_dir <- camcorder:::GG_RECORDING_ENV$recording_dir
  files <- list.files(recording_dir, full.names = TRUE)
  recorded_files <- files[grepl(regex_pattern, basename(files))]

  # Move files to export folder
  dest_paths <- base::file.path(export_folder, basename(recorded_files))
  success <- file.rename(recorded_files, dest_paths)

  # Notify user
  if (all(success)) {
    message("All files moved successfully.")
  } else {
    warning("Some files could not be moved.")
  }

  message(sprintf("File Export Completed.\nFiles can be found in '%s'", gsub("\\\\", "/", base::file.path(camcorder:::GG_RECORDING_ENV$recording_dir, export_folder))))

  # Lists out all files present in export
  files <- list.files(export_folder)
  if (length(files) %% 2 == 1) files <- c(files, "")
  message("The export folder contains the following files:\n", paste(sprintf("%-60s %-60s", files[c(TRUE, FALSE)], files[c(FALSE, TRUE)]), collapse = "\n"))

  # Remove ptt_png folder
  unlink(ppt_png, recursive = TRUE)
}
