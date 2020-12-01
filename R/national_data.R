library(tidyverse)
library(stringr)
library(ggplot2)

## Parse the Raw Case Numbers
cases_raw <- file("raw_data/aap_summary_of_child_cases_416_1112.txt", open = "r")
cases_raw <- readLines(cases_raw)

# remove hashtags
cases_raw <- str_remove(cases_raw, "#")

# parse by "" delimiter
# line 29 and 31 have different number of locations, thus we will parse separately
cases = read.table(text = cases_raw[c(1:28,30)], sep = "" )
cases29 = read.table(text = cases_raw[29], sep = "" )
cases31 = read.table(text = cases_raw[31], sep = "" )

cases <- as.data.frame(cases)
cases29 <- as.data.frame(cases29)
cases31 <- as.data.frame(cases31)

cases <- cases %>% unite("Locations", V2:V8)
cases29 <- cases29 %>% unite("Locations", V2:V7)
cases31 <- cases31 %>% unite("Locations", V2:V6)

# add header
header <- c("Date", "Locations", "Cumulative_All_Ages", "Cumulative_Child",
            "Perc_Children_Total", "per_100k_children")

colnames(cases) <- header
colnames(cases29) <- header
colnames(cases31) <- header


# bind
cases <- rbind(cases, cases29, cases31)
rm(cases29)
rm(cases31)

# arrange by date
cases$Date <- as.POSIXct(cases$Date, format = "%m/%d/%y")
cases <- cases %>% arrange(Date)

cases$Cumulative_All_Ages <- as.numeric(as.character(gsub(",", "", cases$Cumulative_All_Ages)))
cases$Cumulative_Child <- as.numeric(as.character(gsub(",", "", cases$Cumulative_Child)))
cases$Perc_Children_Total <- as.numeric(as.character(gsub("%", "", cases$Perc_Children_Total)))

## Parse Hospitalizations
hosp_raw <- file("raw_data/aap_summary_of_child_hospitalizations_521_1112.txt", open = "r")
hosp_raw <- readLines(hosp_raw)

# remove hashtags
hosp_raw <- str_remove(hosp_raw, "#")

# parse by "" delimiter
hosp = read.table(text = hosp_raw, sep = "" )
hosp <- as.data.frame(hosp)

# concat location columns
hosp <- hosp %>% unite("Locations", V2:V5)

#Add header
colnames(hosp) <- header
colnames(hosp)[6] <- "Hosp_Rate" # number of child hospitalizations /# number of child cases

# arrange by date
hosp$Date <- as.POSIXct(hosp$Date, format = "%m/%d/%y")
hosp <- hosp %>% arrange(Date)

hosp$Cumulative_All_Ages <- as.numeric(as.character(gsub(",", "", hosp$Cumulative_All_Ages)))
hosp$Cumulative_Child <- as.numeric(as.character(gsub(",", "", hosp$Cumulative_Child)))
hosp$Perc_Children_Total <- as.numeric(as.character(gsub("%", "", hosp$Perc_Children_Total)))
hosp$Hosp_Rate <- as.numeric(as.character(gsub("%", "", hosp$Hosp_Rate)))


## Parse Mortality
death_raw <- file("raw_data/aap_summary_of_child_mortality_521_1112.txt", open = "r")
death_raw <- readLines(death_raw)

# remove hashtags
death_raw <- str_remove(death_raw, "#")

# parse by "" delimiter
death = read.table(text = death_raw, sep = "" )
death <- as.data.frame(death)

# concat location columns
death <- death %>% unite("Locations", V2:V5)

#Add header
colnames(death) <- header
colnames(death)[6] <- "Perc_Child_Death" # ^ Number of child deaths / number of child cases

# arrange by date
death$Date <- as.POSIXct(death$Date, format = "%m/%d/%y")
death <- death %>% arrange(Date)

death$Cumulative_All_Ages <- as.numeric(as.character(gsub(",", "", death$Cumulative_All_Ages)))
death$Cumulative_Child <- as.numeric(as.character(gsub(",", "", death$Cumulative_Child)))
death$Perc_Children_Total <- as.numeric(as.character(gsub("%", "", death$Perc_Children_Total)))
death$Perc_Child_Death <- as.numeric(as.character(gsub("%", "", death$Perc_Child_Death)))


## Add column for weekly counts
cases <- cases %>% 
  mutate(weekly_count = Cumulative_All_Ages - lag(Cumulative_All_Ages)) %>%
  mutate(child_weekly_count = Cumulative_Child - lag(Cumulative_Child))

death <- death %>% 
  mutate(weekly_count = Cumulative_All_Ages - lag(Cumulative_All_Ages)) %>%
  mutate(child_weekly_count = Cumulative_Child - lag(Cumulative_Child))

hosp <- hosp %>% 
  mutate(weekly_count = Cumulative_All_Ages - lag(Cumulative_All_Ages)) %>%
  mutate(child_weekly_count = Cumulative_Child - lag(Cumulative_Child))

## Save processed data to csv
write.csv(cases, "processed_data/aap_case_counts.csv", row.names = FALSE)
write.csv(hosp, "processed_data/aap_hospitalization_counts.csv", row.names = FALSE)
write.csv(death, "processed_data/aap_death_counts.csv", row.names = FALSE)


## Plots

# Pediatric Cases
date_labs <- as.Date(cases$Date)

p1 <- ggplot(cases, aes(x = as.Date(Date), y = Cumulative_Child)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("Cumulative Pediatric Cases") + 
  xlab("") +
  scale_x_date(breaks = date_labs, date_labels = "%b %d") + 
  theme_bw()

p1 <- p1 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
           axis.text.y = element_text(face = "bold", size = 12),
           axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig1_cumulative_pediatric_cases.png", plot = p1, width=10, height=8, units="in")

p2 <- ggplot(cases, aes(x = as.Date(Date), y = per_100k_children)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("Cases per 100k Children") + 
  xlab("") +
  ylim(0,1500) + 
  scale_x_date(breaks = date_labs, date_labels = "%b %d") + 
  theme_bw()

p2 <- p2 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig2_pediatric_cases_per100k.png", plot = p2, width=10, height=8, units="in")

p3 <- ggplot(cases, aes(x = as.Date(Date), y = Perc_Children_Total)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("% Children of Total Cases") + 
  xlab("") +
  ylim(0,12) +
  scale_x_date(breaks = date_labs, date_labels = "%b %d") + 
  theme_bw()

p3 <- p3 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                     axis.text.y = element_text(face = "bold", size = 12),
                     axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig3_pediatric_percent_total_cases.png", plot = p3, width=10, height=8, units="in")


# Pediatrics with All Ages
p4 <- ggplot(cases, aes(x = as.Date(Date))) + 
  geom_point(aes(y = Cumulative_All_Ages, color = "slateblue")) + 
  geom_point(aes(y = Cumulative_Child, color = "tomato")) +
  geom_line(group = 1, aes(y = Cumulative_All_Ages, color = "slateblue"), size = 1) +
  geom_line(group = 1, aes(y = Cumulative_Child, color = "tomato"), size = 1) +
  ylab("Cumulative Cases") + 
  xlab("") +
  scale_colour_manual(name = " ",
                      labels = c("All Ages", "Pediatric"), 
                      values = c("slateblue", "tomato")) + 
  scale_x_date(breaks = date_labs, date_labels = "%b %d") + 
  theme_bw()

p4 <- p4 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
           axis.text.y = element_text(face = "bold", size = 12),
           axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig4_cumulative_patient_cases.png", plot = p4, width=10, height=8, units="in")

# Pediatric Hospitalizations
date_hosp_labs <- as.Date(hosp$Date)

p5 <- ggplot(hosp, aes(x = as.Date(Date), y = Cumulative_Child)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("Cumulative Pediatric Hospitalizations") + 
  xlab("") +
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p5 <- p5 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
           axis.text.y = element_text(face = "bold", size = 12),
           axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig5_cumulative_pediatric_hospitalizations.png", plot = p5, width=10, height=8, units="in")


p6 <- ggplot(hosp, aes(x = as.Date(Date), y = Perc_Children_Total)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("% Children of total Hospitalizations") + 
  xlab("") +
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p6 <- p6 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig6_percent_pediatric_hospitalizations.png", plot = p6, width=10, height=8, units="in")


p7 <- ggplot(hosp, aes(x = as.Date(Date), y = Hosp_Rate)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("Hospitalization Rate") + 
  xlab("") +
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p7 <- p7 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig7_pediatric_hospitalization_rate.png", plot = p7, width=10, height=8, units="in")



# Pediatrics Hospitalizations with All Ages
p8 <- ggplot(hosp, aes(x = as.Date(Date))) + 
  geom_point(aes(y = Cumulative_All_Ages, color = "slateblue")) + 
  geom_point(aes(y = Cumulative_Child, color = "tomato")) +
  geom_line(group = 1, aes(y = Cumulative_All_Ages, color = "slateblue"), size = 1) +
  geom_line(group = 1, aes(y = Cumulative_Child, color = "tomato"), size = 1) +
  ylab("Cumulative Hospitalizations") + 
  xlab("") +
  scale_colour_manual(name = " ",
                      labels = c("All Ages", "Pediatric"), 
                      values = c("slateblue", "tomato")) + 
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p8 <- p8 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
              axis.text.y = element_text(face = "bold", size = 12),
              axis.title.y = element_text(face = "bold", size = 16)) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE))

ggsave(filename="results/national_data/Fig8_cumulative_patient_hospitalizations.png", plot = p8, width=10, height=8, units="in")


# Pediatric Mortality
p9 <- ggplot(death, aes(x = as.Date(Date), y = Cumulative_Child)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("Cumulative Pediatric Deaths") + 
  xlab("") +
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p9 <- p9 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
           axis.text.y = element_text(face = "bold", size = 12),
           axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig9_cumulative_pediatric_mortality.png", plot = p9, width=10, height=8, units="in")

p10 <- ggplot(death, aes(x = as.Date(Date), y = Perc_Children_Total)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("% Children of total Deaths") + 
  xlab("") +
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p10 <- p10 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig10_pediatric_percent_total_mortality.png", plot = p10, width=10, height=8, units="in")


p11 <- ggplot(death, aes(x = as.Date(Date), y = Perc_Child_Death)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("% Children of total Deaths") + 
  xlab("") +
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p11 <- p11 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                   axis.text.y = element_text(face = "bold", size = 12),
                   axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig11_percent_pediatric_cases_death.png", plot = p11, width=10, height=8, units="in")


# Pediatrics with All Ages
p12 <- ggplot(death, aes(x = as.Date(Date))) + 
  geom_point(aes(y = Cumulative_All_Ages, color = "slateblue")) + 
  geom_point(aes(y = Cumulative_Child, color = "tomato")) +
  geom_line(group = 1, aes(y = Cumulative_All_Ages, color = "slateblue"), size = 1) +
  geom_line(group = 1, aes(y = Cumulative_Child, color = "tomato"), size = 1) +
  ylab("Cumulative Deaths") + 
  xlab("") +
  scale_colour_manual(name = " ",
                      labels = c("All Ages", "Pediatric"), 
                      values = c("slateblue", "tomato")) + 
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p12 <- p12 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
           axis.text.y = element_text(face = "bold", size = 12),
           axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig12_cumulative_patient_mortality.png", plot = p12, width=10, height=8, units="in")

## weekly counts 

# Cases
p13 <- ggplot(cases, aes(x = as.Date(Date), y = child_weekly_count)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("Weekly Pediatric Cases") + 
  xlab("") +
  scale_x_date(breaks = date_labs, date_labels = "%b %d") + 
  theme_bw()

p13 <- p13 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig13_weekly_pediatric_cases.png", plot = p13, width=10, height=8, units="in")


p14 <- ggplot(cases, aes(x = as.Date(Date))) + 
  geom_point(aes(y = weekly_count, color = "slateblue")) + 
  geom_point(aes(y = child_weekly_count, color = "tomato")) +
  geom_line(group = 1, aes(y = weekly_count, color = "slateblue"), size = 1) +
  geom_line(group = 1, aes(y = child_weekly_count, color = "tomato"), size = 1) +
  ylab("Weekly Cases") + 
  xlab("") +
  scale_colour_manual(name = " ",
                      labels = c("All Ages", "Pediatric"), 
                      values = c("slateblue", "tomato")) + 
  scale_x_date(breaks = date_labs, date_labels = "%b %d") + 
  theme_bw()

p14 <- p14 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16)) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE))

ggsave(filename="results/national_data/Fig14_weekly_patient_cases.png", plot = p14, width=10, height=8, units="in")

# Hospitalizations
p15 <- ggplot(hosp, aes(x = as.Date(Date), y = child_weekly_count)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("Weekly Pediatric Hospitalizations") + 
  xlab("") +
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p15 <- p15 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig15_weekly_pediatric_hospitalizations.png", plot = p15, width=10, height=8, units="in")


p16 <- ggplot(hosp, aes(x = as.Date(Date))) + 
  geom_point(aes(y = weekly_count, color = "slateblue")) + 
  geom_point(aes(y = child_weekly_count, color = "tomato")) +
  geom_line(group = 1, aes(y = weekly_count, color = "slateblue"), size = 1) +
  geom_line(group = 1, aes(y = child_weekly_count, color = "tomato"), size = 1) +
  ylab("Weekly Hospitalizations") + 
  xlab("") +
  scale_colour_manual(name = " ",
                      labels = c("All Ages", "Pediatric"), 
                      values = c("slateblue", "tomato")) + 
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p16 <- p16 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16)) + 
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE))

ggsave(filename="results/national_data/Fig16_weekly_patient_hospitalizations.png", plot = p16, width=10, height=8, units="in")


# Death
p17 <- ggplot(death, aes(x = as.Date(Date), y = child_weekly_count)) + 
  geom_point(color = "tomato") + 
  geom_line(color = "tomato") +
  ylab("Weekly Pediatric Deaths") + 
  xlab("") +
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p17 <- p17 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                 axis.text.y = element_text(face = "bold", size = 12),
                 axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig17_weekly_pediatric_mortality.png", plot = p17, width=10, height=8, units="in")


p18 <- ggplot(death, aes(x = as.Date(Date))) + 
  geom_point(aes(y = weekly_count, color = "slateblue")) + 
  geom_point(aes(y = child_weekly_count, color = "tomato")) +
  geom_line(group = 1, aes(y = weekly_count, color = "slateblue"), size = 1) +
  geom_line(group = 1, aes(y = child_weekly_count, color = "tomato"), size = 1) +
  ylab("Weekly Deaths") + 
  xlab("") +
  scale_colour_manual(name = " ",
                      labels = c("All Ages", "Pediatric"), 
                      values = c("slateblue", "tomato")) + 
  scale_x_date(breaks = date_hosp_labs, date_labels = "%b %d") + 
  theme_bw()

p18 <- p18 + theme(axis.text.x= element_text(angle = 60, hjust = 1, face = "bold", size = 12),
                   axis.text.y = element_text(face = "bold", size = 12),
                   axis.title.y = element_text(face = "bold", size = 16))

ggsave(filename="results/national_data/Fig18_weekly_patient_mortality.png", plot = p18, width=10, height=8, units="in")

