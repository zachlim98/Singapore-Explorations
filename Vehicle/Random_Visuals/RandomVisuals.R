library(tidyverse)
library(plotly)
library(ggplot2)
library(lubridate)
library(ggthemes)

distance_traveled <- read_csv("distance.csv")

g1 <- distance_traveled %>% 
  ggplot(aes(x=year, y=average_annual_mileage, fill=vehicle_type)) +
  geom_col() +
  facet_wrap(~vehicle_type) +
  theme_clean() +
  labs(title  = "Change in Average Mileage (2004-2016)",
       x = "Year", y = "Average Mileage (Annual)",
       fill = "Vehicle Type")

g1

fig <- ggplotly(g1, tooltip = c("year","average_annual_mileage"))

fig

pt_volume <- read_csv("public_volume.csv")

library(scales)

g2 <- pt_volume %>% 
  ggplot(aes(x=year, y=average_ridership, fill=type_of_public_transport)) +
  geom_col() +
  facet_wrap(~type_of_public_transport) +
  theme_clean() +
  scale_y_continuous(breaks = seq(0, 6000000, 500000), labels = scales::unit_format(unit = "M", scale = 1e-6)) +
  labs(title  = "Change in Public Transport Ridership (1995-2016)",
       x = "Year", y = "Ridership (Annual, in Millions)",
       fill = "Transport Type")

g2

employment_edu <- read_csv("employment.csv")

employment_sum <- employment_edu %>%
  group_by(edu_1) %>%
  summarise(mean = mean(employed))

employment_edu$employed <- gsub("-","0",employment_edu$employed)
employment_edu$employed <- as.numeric(employment_edu$employed)

g3 <- employment_edu %>%
  ggplot(aes(x=year, y=employed, fill=edu_1)) +
  geom_col() +
  facet_wrap(~edu_1)

g3

english <- read_csv("./psle/english.csv")
math <- read_csv("./psle/math.csv")
mt <- read_csv("./psle/mt.csv")
science <- read_csv("./psle/science.csv")

psle_scores <- inner_join(english, math, by=c("year","race")) %>%
  inner_join(., mt, by=c("year","race")) %>%
  inner_join(., science, by=c("year","race"))  %>% 
  rename(Year = year, Race = race,  
         English = percentage_psle_eng, 
         Math = percentage_psle_math, 
         MotherTongue = percentage_psle_mtl, 
         Science = percentage_psle_science)

psle_score_long <- psle_scores %>% 
  pivot_longer(cols=!(c("Year","Race")), names_to = "Subject", values_to = "Percentage")

g4 <- psle_score_long %>%
  filter(!Race=="Overall") %>%
  ggplot(aes(x=Year, y=Percentage, fill=Race)) +
  geom_col() + 
  coord_cartesian(ylim = c(50,100)) +
  facet_grid(Race~Subject) +
  theme_clean() +
  labs(title = "Percentage of Students Scoring Higher than 'C' in PSLE")

g4
