
<!-- README.md is generated from README.Rmd. Please edit that file -->

# camcorderplus

<!-- badges: start -->

<!-- badges: end -->

The goal of camcorderplus is to provide an extension to the
functionality of {camcorder} by Ellis Hughes
(<doi:10.32614/CRAN.package.camcorder>).

NOTE: Accessing internal camcorder:::get_file_records(). Used because
there’s no exported equivalent at the time of writing (2025-06). May
break if camcorder changes internal API.

## Installation

You can install the development version of camcorderplus like so:

``` undefined
# install.packages("remotes")
remotes::install_github("J-Pepp/camcorderplus")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(camcorderplus)
library(ggplot2)
library(camcorder)

# Clean temp directory before use
unlink(file.path(tempdir(), "gg_history_export"), recursive = TRUE)

# Start recording
gg_record(device = "tiff", height = 10, width = 10, units = "cm")

# First plot
ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
  geom_point(size = 3) +
  scale_color_viridis_d() +
  theme_minimal(base_size = 14) +
  ggtitle("MTCars: MPG vs Weight")

# Resize recording dimensions
gg_history_resize(height = 4, width = 7, units = "in")

# Second plot
ggplot(as.data.frame(Titanic), aes(x = Class, y = Freq, fill = Survived)) +
  geom_col(position = "dodge") +
  scale_fill_brewer(palette = "Paired") +
  theme_light(base_size = 16) +
  ggtitle("Titanic: Class vs Survival")

# Export all recorded plots
gg_history_export(create_export_folder = TRUE)
#> `GG_RECORDING_ENV` obtained from {camcorder} and assigned to `camcorder_GG_RECORDING_ENV`
#> Warning in gg_history_export(create_export_folder = TRUE): As `export_folder`
#> has been left blank, an export folder may be created at
#> 'C:/Users/Jack/AppData/Local/Temp/RtmpMxjiTZ/gg_history_export'.
#> Warning in gg_history_export(create_export_folder = TRUE): Export destination
#> `C:\Users\Jack\AppData\Local\Temp\RtmpMxjiTZ/gg_history_export` is not a valid
#> directory, or does not exist.
#> Warning in gg_history_export(create_export_folder = TRUE): An export folder was
#> created at 'C:/Users/Jack/AppData/Local/Temp/RtmpMxjiTZ/gg_history_export'.
#> A copy of all exported images will be converted into png formart for inclusion in the powerpoint. 
#> All original quality images can be found in the final export folder, and/or zip file (if applicable).
#> All files moved successfully.
#> File Export Completed.
#> Files can be found in 'C:/Users/Jack/AppData/Local/Temp/RtmpMxjiTZ/C:/Users/Jack/AppData/Local/Temp/RtmpMxjiTZ/gg_history_export'
#> The export folder contains the following files:
#> 2025.06.21-22.32.11_exported_ggplots.pptx                    2025.06.21-22.32.11_exported_ggplots.tif.zip                
#> 2025_06_21_22_32_09.552606.tif                               2025_06_21_22_32_09.925369.tif
```

Images that were exported from the example above

![](man/figures/exported/2025_06_21_22_32_09.552606.tif)

![](man/figures/exported/2025_06_21_22_32_09.925369.tif)
