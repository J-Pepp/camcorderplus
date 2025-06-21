#' gg_history_resize
#'
#' Adaptation of camcorder::gg_resize_film that provides allows for altering the exported image size, overwriting previosuly saved settings. This function has been wholly adapted from package:camcorder, with only minor changes regarding package calls and reprinting the previous plot.
#'
#' @importFrom base match.arg
#'
#' @param width/height/units Plot size in units ("in", "cm", "mm", or "px"). If not supplied, uses the size of current graphics device.
#' @param dpi Plot resolution. Also accepts a string input: "retina" (320), "print" (300), or "screen" (72). Applies only to raster output types.
#'
#' @export

gg_history_resize <- function (height = NA, width = NA, units = NA, dpi = NA) {
  if (!is.na(height)) {
    camcorder:::GG_RECORDING_ENV$image_height <- height
  }
  if (!is.na(width)) {
    camcorder:::GG_RECORDING_ENV$image_width <- width
  }
  if (!is.na(units)) {
    units <- base::match.arg(units, choices = c("in", "cm", "mm",
                                          "px"))
    camcorder:::GG_RECORDING_ENV$image_units <- units
  }
  if (!is.na(dpi)) {
    camcorder:::GG_RECORDING_ENV$image_dpi <- dpi
  }
  #print(GG_RECORDING_ENV$last_plot)
  invisible()
}
