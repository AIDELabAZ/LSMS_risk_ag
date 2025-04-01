# Load required libraries
# Uncomment if needed
# install.packages(c("tidyverse", "haven", "xtable"))

rm(list = ls())

library(tidyverse)
library(haven)
library(xtable)

# Step 1: Load the dataset
data <- read_dta("C:/Users/rbrnhm/OneDrive - University of Arizona/weather_and_agriculture/lsms_risk_ag_data/regression_data/nigeria/nga_complete_p.dta")

# Step 2: Check structure of data
glimpse(data)

# Step 3: Create relevant variables
data <- data %>%
  mutate(
    std_y = harvest_value_USD / plot_area_GPS,
    std_f = nitrogen_kg2 / plot_area_GPS,
    std_s = isp,
    std_y2 = std_y^2,
    std_y3 = std_y^3,
    std_f2 = std_f^2,
    std_s2 = std_s^2,
    std_fs = std_f * std_s
  )

# Step 3.5: Drop outliers where std_y > 700000
data <- data %>%
  filter(std_y <= 700000 | is.na(std_y))

# Step 4: Compute mean and standard deviation for selected variables across waves
summary_table <- data %>%
  group_by(wave) %>%
  summarise(
    hh_size_mean = mean(hh_size, na.rm = TRUE),
    hh_size_sd = sd(hh_size, na.rm = TRUE),
    std_y_mean = mean(std_y, na.rm = TRUE),
    std_y_sd = sd(std_y, na.rm = TRUE),
    std_f_mean = mean(std_f, na.rm = TRUE),
    std_f_sd = sd(std_f, na.rm = TRUE),
    std_s_mean = mean(std_s, na.rm = TRUE),
    std_s_sd = sd(std_s, na.rm = TRUE),
    hh_electricity_access_mean = mean(hh_electricity_access, na.rm = TRUE),
    hh_electricity_access_sd = sd(hh_electricity_access, na.rm = TRUE),
    dist_popcenter_mean = mean(dist_popcenter, na.rm = TRUE),
    dist_popcenter_sd = sd(dist_popcenter, na.rm = TRUE),
    dist_market_mean = mean(dist_market, na.rm = TRUE),
    dist_market_sd = sd(dist_market, na.rm = TRUE),
    dist_road_mean = mean(dist_road, na.rm = TRUE),
    dist_road_sd = sd(dist_road, na.rm = TRUE),
    maize_ea_p_mean = mean(maize_ea_p, na.rm = TRUE),
    maize_ea_p_sd = sd(maize_ea_p, na.rm = TRUE),
    extension_mean = mean(extension, na.rm = TRUE),
    extension_sd = sd(extension, na.rm = TRUE)
  )

# Step 5: Reshape table to make it horizontal
summary_table_long <- summary_table %>%
  pivot_longer(-wave, names_to = "Variable", values_to = "Value") %>%
  pivot_wider(names_from = "wave", values_from = "Value")

# Optional: Rename wave columns to include "Wave"
names(summary_table_long)[-1] <- paste0("Wave ", names(summary_table_long)[-1])

# Step 6: Convert to LaTeX format and export
latex_table <- xtable(summary_table_long, caption = "Descriptive Statistics Across Waves")

# Save LaTeX table
print(latex_table,
      file = "descriptive_statistics_nga.tex",
      include.rownames = FALSE,
      caption.placement = "top",
      tabular.environment = "tabular",
      floating = TRUE,
      sanitize.text.function = identity)

# Step 7: Check exported file (optional)
file.show("descriptive_statistics_nga.tex")


