
library(ggplot2)
library(dplyr)

camcorder::gg_record(device = "tiff")

set.seed(123)

# List of 10 ggplots stored in a named list
ggplots <- list(

  # 1. Scatterplot (mtcars)
  ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
    geom_point(size = 3) +
    scale_color_viridis_d() +
    theme_minimal(base_size = 14) +
    ggtitle("MTCars: MPG vs Weight"),

  # 2. Histogram (diamonds)
  ggplot(diamonds, aes(x = carat, fill = cut)) +
    geom_histogram(binwidth = 0.2, position = "dodge") +
    scale_fill_brewer(palette = "Set2") +
    theme_classic() +
    ggtitle("Diamonds: Carat Histogram"),

  # 3. Bar plot (Titanic)
  ggplot(as.data.frame(Titanic), aes(x = Class, y = Freq, fill = Survived)) +
    geom_col(position = "dodge") +
    scale_fill_brewer(palette = "Paired") +
    theme_light(base_size = 16) +
    ggtitle("Titanic: Class vs Survival"),

  # 4. Boxplot (ToothGrowth)
  ggplot(ToothGrowth, aes(x = dose, y = len, fill = supp)) +
    geom_boxplot() +
    scale_fill_viridis_d() +
    theme_bw() +
    ggtitle("ToothGrowth: Length by Dose"),

  # 5. Density plot (faithful)
  ggplot(faithful, aes(x = eruptions)) +
    geom_density(fill = "steelblue", alpha = 0.7) +
    theme_minimal() +
    ggtitle("Faithful: Eruption Density"),

  # 6. Line plot (economics)
  ggplot(economics, aes(x = date, y = unemploy)) +
    geom_line(color = "steelblue", linewidth = 1) +
    theme_classic(base_size = 15) +
    ggtitle("Economics: Unemployment Over Time"),

  # 7. Tile plot / heatmap (volcano)
  {
    volcano_df <- as.data.frame(as.table(volcano))
    ggplot(volcano_df, aes(x = Var1, y = Var2, fill = Freq)) +
      geom_tile() +
      scale_fill_viridis_c() +
      theme_void() +
      ggtitle("Volcano: Elevation Heatmap")
  },

  # 8. Violin plot (iris)
  ggplot(iris, aes(x = Species, y = Sepal.Width, fill = Species)) +
    geom_violin() +
    scale_fill_brewer(palette = "Pastel1") +
    theme_minimal(base_size = 12) +
    ggtitle("Iris: Sepal Width by Species"),

  # 9. Step plot (AirPassengers)
  {
    ap_df <- data.frame(date = time(AirPassengers), passengers = as.vector(AirPassengers))
    ggplot(ap_df, aes(x = date, y = passengers)) +
      geom_step(color = "darkred") +
      theme_minimal() +
      ggtitle("AirPassengers: Monthly Flights")
  },

  # 10. Area plot (CO2)
  {
    co2_df <- as.data.frame(CO2)
    co2_summary <- co2_df %>%
      group_by(conc) %>%
      dplyr::summarise(uptake = mean(uptake))
    ggplot(co2_summary, aes(x = conc, y = uptake)) +
      geom_area(fill = "skyblue") +
      theme_light() +
      ggtitle("CO2: Uptake by Concentration")
  }
)

# Optional: Preview one plot
# print(ggplots[[1]])

print(ggplots)

gg_history_export(create_export_folder = TRUE)
