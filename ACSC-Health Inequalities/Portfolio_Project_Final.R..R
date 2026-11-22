#install.packages("tidyverse")
#install.packages("readxl")
#install.packages("janitor")
#install.packages("PHEindicatormethods")
#install.packages("gglot2")

library(tidyverse)
library(readxl)
library(janitor)
library(PHEindicatormethods)
library(ggplot2)
#data <- read_excel(file.choose())
head(data)
dim(data)
names(data)
glimpse(data)
save.image("portfolio_project1.RData")
data <- clean_names(data)
names(data)
unique (data$breakdown)
unique (data$level)
unique (data$period_of_coverage)
deprivation_data <- data %>%
    filter (breakdown == "2019 Deprivation decile") 
deprivation_data <- deprivation_data %>%
    mutate(year = as.numeric(str_extract(period_of_coverage, "\\d{4}")))
deprivation_data <- deprivation_data %>%
    mutate(level = factor(level,
                          levels = c("1","2", "3","4","5",
                                     "6", "7","8","9","10")))
ggplot(deprivation_data,
       aes(x = year,
           y = indicator_value,
           colour = level,
           group = level)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_colour_brewer(palette ="RdYlGn",
                      direction = -1,
                      name = "Deprivation\nDecile\n(1=Most\nDeprived)")+
  labs(
    title = "Emergency Admissions for Ambulatory Care Sensitive Conditions",
    subtitle = "By Deprivation Decile, England 2003-2023",
    x = "Year",
    y = "Admission Rate per 100,000 population",
    caption = "Source: NHS Outcomes Framework| Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size =12, colour = "grey40"),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )



regional_data <- data %>%
  filter(breakdown == "Region") %>%
  filter(!is.na(indicator_value))

ggplot(regional_data, 
       aes(x = reorder(level, indicator_value), 
           y = indicator_value,
           fill = indicator_value)) +
  geom_col() +
  coord_flip() +
  scale_fill_gradient(low = "#AED6F1", high = "#1B4F72",
                      name = "Admission Rate") +
  labs(
    title = "Emergency ACSC Admissions by Region",
    subtitle = "Age-standardised admission rates per 100,000 population",
    x = "Region",
    y = "Admission Rate per 100,000",
    caption = "Source: NHS Outcomes Framework | Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "none"
  )

ggsave("Chart2_Regional_Trends.png",width = 12, height = 7, dpi = 300)

# ============================================
# CHART 3 — GENDER DIFFERENCES OVER TIME
# ============================================

gender_data <- data %>%
  filter(breakdown == "Gender") %>%
  filter(level %in% c("Male", "Female")) %>%
  mutate(year = as.numeric(str_extract(period_of_coverage, "\\d{4}"))) %>%
  filter(!is.na(indicator_value))

ggplot(gender_data,
       aes(x = year,
           y = indicator_value,
           colour = level,
           group = level)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 2.5) +
  scale_colour_manual(values = c("Female" = "#E74C3C", 
                                 "Male" = "#1B6CA8"),
                      name = "Gender") +
  labs(
    title = "ACSC Emergency Admissions by Gender",
    subtitle = "Trends over time, England 2003-2023",
    x = "Year",
    y = "Admission Rate per 100,000",
    caption = "Source: NHS Outcomes Framework | Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  )

ggsave("Chart3_Gender_Trends.png", width = 12, height = 7, dpi = 300)

# ============================================
# CHART 4 — AGE GROUP VARIATION
# ============================================

age_data <- data %>%
  filter(breakdown == "Age") %>%
  filter(!is.na(indicator_value)) %>%
  mutate(year = as.numeric(str_extract(period_of_coverage, "\\d{4}")))

ggplot(age_data,
       aes(x = year,
           y = indicator_value,
           colour = level,
           group = level)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_colour_brewer(palette = "Set2", name = "Age Group") +
  labs(
    title = "ACSC Emergency Admissions by Age Group",
    subtitle = "Trends over time, England 2003-2023",
    x = "Year",
    y = "Admission Rate per 100,000",
    caption = "Source: NHS Outcomes Framework | Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  )

ggsave("Chart4_Age_Demographics.png", width = 12, height = 7, dpi = 300)

# ============================================
# CHART 5 — COVID PERIOD COMPARISON
# ============================================

covid_data <- data %>%
  filter(breakdown == "England") %>%
  mutate(year = as.numeric(str_extract(period_of_coverage, "\\d{4}"))) %>%
  filter(!is.na(indicator_value)) %>%
  mutate(period = case_when(
    year < 2020 ~ "Pre-COVID (2003-2019)",
    year == 2020 | year == 2021 ~ "COVID Period (2020-2021)",
    year > 2021 ~ "Post-COVID (2022-2023)"
  ))

ggplot(covid_data,
       aes(x = year,
           y = indicator_value,
           colour = period,
           group = 1)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 3) +
  geom_vline(xintercept = 2020, linetype = "dashed", 
             colour = "red", linewidth = 1) +
  geom_vline(xintercept = 2022, linetype = "dashed",
             colour = "darkgreen", linewidth = 1) +
  annotate("text", x = 2020.2, y = max(covid_data$indicator_value, na.rm=TRUE),
           label = "COVID\nstart", colour = "red", size = 3.5, hjust = 0) +
  scale_colour_manual(values = c(
    "Pre-COVID (2003-2019)" = "#1B6CA8",
    "COVID Period (2020-2021)" = "#E74C3C",
    "Post-COVID (2022-2023)" = "#27AE60"
  ), name = "Period") +
  labs(
    title = "Impact of COVID-19 on ACSC Emergency Admissions",
    subtitle = "England 2003-2023 with COVID period highlighted",
    x = "Year",
    y = "Admission Rate per 100,000",
    caption = "Source: NHS Outcomes Framework | Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  )

ggsave("Chart5_COVID_Comparison.png", width = 12, height = 7, dpi = 300)

# ============================================
# CHART 6 — INEQUALITY GAP OVER TIME
# ============================================

gap_data <- deprivation_data %>%
  group_by(year) %>%
  summarise(
    most_deprived = indicator_value[level == "1"],
    least_deprived = indicator_value[level == "10"],
    gap = most_deprived - least_deprived
  ) %>%
  filter(!is.na(gap))

ggplot(gap_data, aes(x = year, y = gap)) +
  geom_line(linewidth = 1.5, colour = "#E74C3C") +
  geom_point(size = 3, colour = "#E74C3C") +
  geom_ribbon(aes(ymin = 0, ymax = gap), 
              fill = "#E74C3C", alpha = 0.2) +
  geom_smooth(method = "lm", se = FALSE, 
              colour = "#1B6CA8", linetype = "dashed") +
  labs(
    title = "Inequality Gap in ACSC Emergency Admissions",
    subtitle = "Difference between most (Decile 1) and least (Decile 10) deprived areas",
    x = "Year",
    y = "Inequality Gap (admission rate per 100,000)",
    caption = "Source: NHS Outcomes Framework | Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(colour = "grey40")
  )

ggsave("Chart6_Inequality_Gap.png", width = 12, height = 7, dpi = 300)

# ============================================
# CHART 7 — 2015 vs 2019 DEPRIVATION COMPARISON
# ============================================

dep_comparison <- data %>%
  filter(breakdown %in% c("2015 Deprivation decile", 
                          "2019 Deprivation decile")) %>%
  filter(!is.na(indicator_value)) %>%
  mutate(level = factor(level, 
                        levels = c("1","2","3","4","5",
                                   "6","7","8","9","10")))

ggplot(dep_comparison,
       aes(x = level,
           y = indicator_value,
           fill = breakdown)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c(
    "2015 Deprivation decile" = "#AED6F1",
    "2019 Deprivation decile" = "#1B4F72"
  ), name = "Deprivation\nMeasure") +
  labs(
    title = "ACSC Admissions: 2015 vs 2019 Deprivation Decile Comparison",
    subtitle = "How the deprivation picture changed between measurements",
    x = "Deprivation Decile (1 = Most Deprived)",
    y = "Admission Rate per 100,000",
    caption = "Source: NHS Outcomes Framework | Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "right"
  )+

ggsave("Chart7_Deprivation_Comparison.png", width = 12, height = 7, dpi = 300)

# ============================================
# SAVE ALL WORK
# ============================================
save.image("Project 1 - ACSC Inequalities/Portfolio_Project1_Complete.RData")
region_names <- c(
  "E12000001" = "North East",
  "E12000002" = "North West", 
  "E12000003" = "Yorkshire",
  "E12000004" = "East Midlands",
  "E12000005" = "West Midlands",
  "E12000006" = "East of England",
  "E12000007" = "London",
  "E12000008" = "South East",
  "E12000009" = "South West"
)

regional_data <- data %>%
  filter(breakdown == "Region") %>%
  filter(!is.na(indicator_value)) %>%
  mutate(region_name = recode(level, !!!region_names))

ggplot(regional_data,
       aes(x = reorder(region_name, indicator_value),
           y = indicator_value,
           fill = indicator_value)) +
  geom_col() +
  coord_flip() +
  scale_fill_gradient(low = "#AED6F1", high = "#1B4F72",
                      name = "Admission Rate") +
  labs(
    title = "Emergency ACSC Admissions by Region",
    subtitle = "Age-standardised admission rates per 100,000 population",
    x = "Region",
    y = "Admission Rate per 100,000",
    caption = "Source: NHS Outcomes Framework | Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        legend.position = "none")

ggsave("Chart2_Regional_Variation.png",
       width = 12, height = 7, dpi = 300)

# FIX CHART 6 - Inequality gap full time series
gap_data <- data %>%
  filter(breakdown %in% c("2015 Deprivation decile", "2019 Deprivation decile"),
         level %in% c("1","10")) %>%
  mutate(year= as.numeric(str_extract(period_of_coverage, "\\d{4}")),
         classification = breakdown) %>%
  select(classification, year, level, indicator_value) %>%
  tidyr::pivot_wider(names_from = level, values_from = indicator_value,
                     names_prefix = "decile_") %>%
  mutate(gap = decile_1 - decile_10) %>%
  arrange(classification, year)

print(gap_data, n = Inf)
write.csv(gap_data, "gap_data.csv", row.names = FALSE)

ggplot(gap_data, aes(x = year, y = gap)) +
  geom_line(linewidth = 1.5, colour = "#E74C3C") +
  geom_point(size = 3, colour = "#E74C3C") +
  geom_ribbon(aes(ymin = 0, ymax = gap),
              fill = "#E74C3C", alpha = 0.2) +
  geom_smooth(method = "lm", se = FALSE,
              colour = "#1B6CA8", linetype = "dashed",
              linewidth = 1) +
  scale_x_continuous(breaks = seq(2003, 2023, by = 2)) +
  labs(
    title = "Inequality Gap in ACSC Emergency Admissions",
    subtitle = "Difference between most and least deprived areas, England 2003-2023",
    x = "Year",
    y = "Inequality Gap (admissions per 100,000)",
    caption = "Source: NHS Outcomes Framework | Analysis: Jemilat Azeez MPH"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(colour = "grey40"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("Chart6_Inequality_Gap.png",
       width = 12, height = 7, dpi = 300)

save.image("C:/Users/azeez/Documents/Public Health Portfolio/Project 1 - ACSC Inequalities/Portfolio_Project1_Complete.RData")
print("Project 1 Complete! All 7 charts saved!")

write.csv(data, "full_data.csv",
          row.names = FALSE)
write.csv(deprivation_data, "deprivation_data.csv",
          row.names = FALSE)
write.csv(regional_data, "regional_data.csv",
          row.names = FALSE)
write.csv(gender_data, "gender_data.csv",
          row.names = FALSE)
write.csv(gap_data, "gap_data.csv",
          row.names = FALSE)
print("All CSV files exported for po

list.files(pattern = "full_data")
library(tidyverse)
data <- read_csv("full_data.csv")
dim(data)

gap_data <- data %>%
  filter(breakdown %in% c("2015 Deprivation decile", "2019 Deprivation decile"),
         level %in% c("1", "10")) %>%
  mutate(year = as.numeric(str_extract(period_of_coverage, "\\d{4}")),
         classification = breakdown) %>%
  select(classification, year, level, indicator_value) %>%
  pivot_wider(names_from = level, values_from = indicator_value,
              names_prefix = "decile_") %>%
  mutate(gap = decile_1 - decile_10) %>%
  arrange(classification, year)
print(gap_data, n = Inf)
write.csv(gap_data, "gap_data.csv", row.names = FALSE)
dep2015 <- data %>% filter(breakdown == "2015 Deprivation decile") %>%
  mutate(year = as.numeric(str_extract(period_of_coverage, "\\d{4}")),
         level = factor(level, levels = as.character(1:10)))
write.csv(dep2015, "dep2015_data.csv", row.names = FALSE)
ggplot(dep2015, aes(year, indicator_value, colour = level, group = level)) +
  geom_line() + geom_point() +
  labs(title = "ACSC admissions by deprivation decile (2015 classification)",
       x = "Year", y = "Rate per 100,000", colour = "Decile (1 = most deprived)") +
  theme_minimal()
ggsave("Chart1b_Deprivation_2015.png", width = 12, height = 7, dpi = 300)

 print(gap_data, n = Inf)
 write.csv(gap_data, "gap_data.csv", row.names = FALSE)
 
 ggplot(gap_data, aes(year,gap,colour = classification)) +
 geom_line() + geom_point() +
 labs(title = "Absolute gap (decile 1 minus decile 10)",
     x = "Year (start of period)", y = "Gap per 100,000",
      colour = "Classification" ) + theme_minimal()
      ggsave("Chart6b_Gap_by_classification.png", width = 12, height = 7, dpi = 300)









  
                                     