library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)
library(ggthemes)

sea_data <- read.csv("X:/GitHub/Singapore-explorations/Covid-viz/sea_data.csv")

sea_data_perc <- sea_data %>% group_by(location) %>%
  mutate(case_change = (total_cases/total_cases[1]- 1),
         death_change = (total_deaths/total_deaths[1]- 1)) 

sea_final <- sea_data_perc %>% select(c(date, location, 
                                        case_change, death_change))

colors <- c("Cases" = "#7ad2f6", "Deaths" = "#ee8f71")

plot <- ggplot(data=sea_data_perc, aes(x=as.Date(date, format = "%d/%m/%Y"))) + 
  theme_economist() + 
  geom_line(aes(y=case_change, color = "Cases"), size = 1.5) + 
  geom_line(aes(y=death_change, color = "Deaths"),  size = 1.5) +
  facet_wrap(~ location, ncol = 2, scales = "free") +
  scale_color_manual(values = colors) +
  scale_x_date(date_breaks = "months", date_labels = "%B") +
  scale_y_continuous(labels = percent) +
  labs(title = "Covid-19 Cases and Deaths, South-East Asia", 
       x="Date", 
       y="Percentage Change (since 01 Jan 2021)",
       color = "Legend",
       caption = "Source: ourworldindata.org") 

plot
