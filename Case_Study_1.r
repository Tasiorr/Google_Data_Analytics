# title: "Case_Study_1"
# author: "Michal"
# date: "8 01 2022"

# Install required packages
library(tidyverse)  #helps wrangle data
library(lubridate)  #helps wrangle date attributes
library(ggplot2)    #helps visualize data
library(dplyr)  

# PROCESS
# Reading from CSV Files
csv_files <- list.files(path = "C:/Users/przyb/Desktop/Case study1/CSV", recursive = TRUE, full.names = TRUE) %>%
  lapply(read_csv) %>%
  bind_rows


# Creating a Data Frame - all the csvs files will be concatenated into one dataframe.
df <- as.data.frame(csv_files)


# Removing Duplicates
df_no_dups <- df[!duplicated(df$ride_id),]
print(paste("Removed", nrow(df) - nrow(df_no_dups), "duplicated rows"))


# Total time of a bike ride - represents the total time of a bike ride, in minutes
df_no_dups <- df_no_dups %>%
  mutate(ride_time_m = as.numeric(df_no_dups$ended_at - df_no_dups$started_at)/60)
summary(df_no_dups$ride_time_m)


# Added new columns: start_day, end_day, moth, year and delate start_lat, start_lng, end_lat
df_no_dups <- df_no_dups %>%
  mutate(start_day = weekdays(started_at),
         end_day = paste(strftime(df_no_dups$ended_at, "%u"), "-", strftime(df_no_dups$ended_at, "%a")),
         month = format(as.POSIXct(started_at), "%m"),
         year = year(started_at),
         hour = strftime(df_no_dups$ended_at, "%H"),
         start_lat = NULL,
         start_lng = NULL,
         end_lat = NULL)


# Negativ trip duration - negative values has to be deleted
df_no_dups %>% 
  filter(ride_time_m < 0) %>% 
  summarize("value"=n()) ##Number of negative values

# Remove the negative values
df_no_dups <- df_no_dups %>%
  filter(-ride_time_m < 0)


# Saving the result as a CSV
df_no_dups %>%
  write.csv("case_study_1.csv")

# DATA ANALYZE
summary(df_no_dups)
#One thing that immediately catches the attention is ride_time_m. This field has no more negative values but the biggest value is 55944,15 which is almost 39 days. This field will be explored further in the document.

#Casuals vs members - How much of the data is about members and how much is about casuals?
df_no_dups %>%
  group_by(member_casual) %>%
  summarise("count" = length(ride_id),
            "%" = length(ride_id) / nrow(df_no_dups) * 100)
#Plot the chart
myplot <- ggplot(df_no_dups, aes(member_casual,  fill=member_casual)) + 
  geom_bar(aes(y = (..count..)/sum(..count..))) +  
  scale_y_continuous(labels=scales::percent) +
  labs(x="Casuals vs Members", title="Case study 01 - Casuals vs Members distribution")
myplot


#Month - how much of the data is distributed by month?
df_no_dups %>%
    group_by(month) %>%
    summarise(count = length(ride_id),
              '%' = (length(ride_id) / nrow(df_no_dups)) * 100,
              'members_p' = (sum(member_casual == "member") / length(ride_id)) * 100,
              'casual_p' = (sum(member_casual == "casual") / length(ride_id)) * 100,
              'Member x Casual Perc Difer' = members_p - casual_p)

df_no_dups %>%
  ggplot(aes(month, fill=member_casual)) +
    geom_bar() +
    labs(x="Month", title="Chart 02 - Distribution by month") +
    coord_flip()


#Weekday - how much of the data is distributed by weekday?
df_no_dups %>%
    group_by(end_day) %>% 
    summarise(count = length(ride_id),
              '%' = (length(ride_id) / nrow(df_no_dups)) * 100,
              'members_p' = (sum(member_casual == "member") / length(ride_id)) * 100,
              'casual_p' = (sum(member_casual == "casual") / length(ride_id)) * 100,
              'Member x Casual Perc Difer' = members_p - casual_p)

ggplot(df_no_dups, aes(end_day, fill=member_casual)) +
    geom_bar() +
    labs(x="Weekdady", title="Chart 03 - Distribution by weekday") +
    coord_flip()


#Hour of the day
df_no_dups %>%
    group_by(hour) %>% 
    summarise(count = length(ride_id),
          '%' = (length(ride_id) / nrow(df_no_dups)) * 100,
          'members_p' = (sum(member_casual == "member") / length(ride_id)) * 100,
          'casual_p' = (sum(member_casual == "casual") / length(ride_id)) * 100,
          'member_casual_perc_difer' = members_p - casual_p)

df_no_dups %>%
    ggplot(aes(hour, fill=member_casual)) +
    labs(x="Hour of the day", title="Chart 04 - Distribution by hour of the day") +
    geom_bar()

#This chart can be expanded ween seen it divided by day of the week.
df_no_dups %>%
    ggplot(aes(hour, fill=member_casual)) +
    geom_bar() +
    labs(x="Hour of the day", title="Chart 05 - Distribution by hour of the day divided by weekday") +
    facet_wrap(~ end_day)


#Rideable type
df_no_dups %>%
    group_by(rideable_type) %>% 
    summarise(count = length(ride_id),
          '%' = (length(ride_id) / nrow(df_no_dups)) * 100,
          'members_p' = (sum(member_casual == "member") / length(ride_id)) * 100,
          'casual_p' = (sum(member_casual == "casual") / length(ride_id)) * 100,
          'member_casual_perc_difer' = members_p - casual_p)

ggplot(df_no_dups, aes(rideable_type, fill=member_casual)) +
    labs(x="Rideable type", title="Chart 06 - Distribution of types of bikes") +
    geom_bar() +
    coord_flip()


# ride_time_m
summary(df_no_dups$ride_time_m)

ventiles = quantile(df_no_dups$ride_time_m, seq(0, 1, by=0.05))
ventiles

cyclistic_without_outliners <- df_no_dups %>% 
    filter(ride_time_m > as.numeric(ventiles['5%'])) %>%
    filter(ride_time_m < as.numeric(ventiles['95%']))

print(paste("Removed", nrow(df_no_dups) - nrow(cyclistic_without_outliners), "rows as outliners" ))

#ride_time_m multivariable exploration
cyclistic_without_outliners %>% 
    group_by(member_casual) %>% 
    summarise(mean = mean(ride_time_m),
              'first_quarter' = as.numeric(quantile(ride_time_m, .25)),
              'median' = median(ride_time_m),
              'third_quarter' = as.numeric(quantile(ride_time_m, .75)),
              'IR' = third_quarter - first_quarter)

ggplot(cyclistic_without_outliners, aes(x=member_casual, y=ride_time_m, fill=member_casual)) +
    labs(x="Member x Casual", y="Riding time", title="Chart 07 - Distribution of Riding time for Casual x Member") +
    geom_boxplot()


#Ploting with weekday
ggplot(cyclistic_without_outliners, aes(x=end_day, y=ride_time_m, fill=member_casual)) +
    geom_boxplot() +
    facet_wrap(~ member_casual) +
    labs(x="Weekday", y="Riding time", title="Chart 08 - Distribution of Riding time for day of the week") +
    coord_flip()


#rideable_type
ggplot(cyclistic_without_outliners, aes(x=rideable_type, y=ride_time_m, fill=member_casual)) +
    geom_boxplot() +
    facet_wrap(~ member_casual) +
    labs(x="Rideable type", y="Riding time", title="Chart 09 - Distribution of Riding time for rideeable type") +
    coord_flip()
