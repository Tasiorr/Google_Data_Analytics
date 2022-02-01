# **Cyclistic Bike-Share: Case Study**
---
_This document is created as part of the capstone project of the Google Data Analytics Professional Certificate._

## **Scenario — excerpt from original document**
You are a junior data analyst working in the marketing analyst team at Cyclistic, a bike-share company in Chicago. The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore, your team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights, your team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives must approve your recommendations, so they must be backed up with compelling data insights and professional data visualizations.

## **About the company — excerpt from original document**
In 2016, Cyclistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.

Until now, Cyclistic’s marketing strategy relied on building general awareness and appealing to broad consumer segments. One approach that helped make these things possible was the flexibility of its pricing plans: single-ride passes, full-day passes, and annual memberships. Customers who purchase single-ride or full-day passes are referred to as casual riders. Customers who purchase annual memberships are Cyclistic members.

Cyclistic’s finance analysts have concluded that annual members are much more profitable than casual riders. Although the pricing flexibility helps Cyclistic attract more customers, Moreno believes that maximizing the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, Moreno believes there is a very good chance to convert casual riders into members. She notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs.

Moreno has set a clear goal: Design marketing strategies aimed at converting casual riders into annual members. In order to do that, however, the marketing analyst team needs to better understand how annual members and casual riders differ, why casual riders would buy a membership, and how digital media could affect their marketing tactics. Moreno and her team are interested in analyzing the Cyclistic historical bike trip data to identify trends.

The project follows the six step data analysis process: **ask, prepare, process, analyze, share, and act**.

## **Working process**
### **Phase 1: Ask -  A clear statement of the business task**
Three questions will guide the future marketing program:
1. How do annual members and casual riders use Cyclistic bikes differently?
2. why would casual riders buy Cyclistic annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?

### **Phase 2: Data Preparation - A description of all data sources used**
The data that we will be using is Cyclistic’s historical trip data from last 12 months (January-2021 to December-2021). 
The data can be found under this   [link](https://divvy-tripdata.s3.amazonaws.com/index.html).
The dataset consists of 12 CSV files (each for a month) with 13 columns and more than 5 million rows.

### **Phase 3: Process - Documentation of any cleaning or manipulation of data**
Before we start analyzing, it is necessary to make sure data is clean, free of error and in the right format.

#### **Load packages in R Programming**
```R
library(tidyverse)  #helps wrangle data
library(lubridate)  #helps wrangle date attributes
library(ggplot2)    #helps visualize data
library(dplyr)
```

#### **Organize: Reading the data from CSV files**
```R
csv_files <- list.files(path = "C:/Users/...../CSV", recursive = TRUE, full.names = TRUE) %>%
    lapply(read_csv) %>%
    bind_rows
```

#### **Creating a Data Frame - all the CSV flies will be concatented into one dataframe**
```R
df <- as.data.frame(csv_files)
```

#### **Data cleaning - Removing Duplicates**
```R
df_no_dups <- df[!duplicated(df$ride_id),]
print(paste("Removed", nrow(df) - nrow(df_no_dups), "duplicated rows"))
```

#### **Total time of a bike ride - Represents the total time of a bike ride, in minutes**
```R
df_no_dups <- df_no_dups %>%
       mutate(ride_time_m = as.numeric(df_no_dups$ended_at - df_no_dups$started_at)/60)
summary(df_no_dups$ride_time_m)
```

| Min         | 1st Qu.     | Median    | Mean       | rd Qu.       | Max    |
|-------------|-------------|-----------|------------|--------------|--------|
| -58.03      | 6.75        | 12.00     |21.94       |21.78         |55944.15|

#### **Added new columns: start_day, end_day, moth, year, hour and delate start_lat, start_lng, end_lat**
```R
df_no_dups <- df_no_dups %>%
  mutate(start_day = weekdays(started_at),
         end_day = paste(strftime(df_no_dups$ended_at, "%u"), "-", strftime(df_no_dups$ended_at, "%a")),
         month = format(as.POSIXct(started_at), "%m"),
         year = year(started_at),
         hour = strftime(df_no_dups$ended_at, "%H"),
         start_lat = NULL,
         start_lng = NULL,
         end_lat = NULL)
```

#### **Negativ trip duration - Negative values has to be deleted**
```R
df_no_dups %>% 
  filter(ride_time_m < 0) %>% 
  summarize("value"=n()) ##Number of negative values
```
Remove the negative values
```R
df_no_dups <- df_no_dups %>%
  filter(-ride_time_m < 0)
```

#### **Saving the result as a CSV**
```R
df_no_dups %>%
  write.csv("case_study_1.csv")
```

### **Phase 4: Analyzing Data - a summary of analysis**
To quick start, let's generate a summary of the dataset
```R
summary(df_no_dups)
```
#ZDJECIE
One thing that immediately catches the attention is ride_time_m. This field has no more negative values but the biggest value is 55944,15 which is almost 39 days. This field will be explored further in the document.

#### **Data distribution**
Here we want to try to answer the most basic questions about how the data is distributed.

##### **Casuals vs members**
How much of the data is about members and how much is about casuals?
```R
df_no_dups %>%
  group_by(member_casual) %>%
  summarise("count" = length(ride_id),
            "%" = length(ride_id) / nrow(df_no_dups) * 100)
```

| member_casual |  count  |     %    |
|---------------|---------|----------|
|      casual	  | 2528664 |	45.19983 |		
|      member	  | 3065746 |	54.80017 |	

#ZDJECIE

As we can see , members have a almost 55% of the whole amount of client and casual is equal to 45%.

##### **Month**
How much of the data is distributed by month?
```R
df_no_dups %>%
    group_by(month) %>%
    summarise(count = length(ride_id),
              '%' = (length(ride_id) / nrow(df_no_dups)) * 100,
              'members_p' = (sum(member_casual == "member") / length(ride_id)) * 100,
              'casual_p' = (sum(member_casual == "casual") / length(ride_id)) * 100,
              'Member x Casual Perc Difer' = members_p - casual_p)
```

#ZDJECIE

Some considerations can be taken by this chart:
*      The months with the biggest count of data points are July and August.
*      We have slightly more casuals the members in June, July and August.

##### **Weekday**
How much of the data is distributed by weekday?
```R
df_no_dups %>%
    group_by(end_day) %>% 
    summarise(count = length(ride_id),
              '%' = (length(ride_id) / nrow(df_no_dups)) * 100,
              'members_p' = (sum(member_casual == "member") / length(ride_id)) * 100,
              'casual_p' = (sum(member_casual == "casual") / length(ride_id)) * 100,
              'Member x Casual Perc Difer' = members_p - casual_p)
```

#ZDJECIE

Some considerations can be taken by this chart:
*      The biggest volume of data is on the weekend.
*      Saturday has the biggest data points.
*      Members may have the biggest volume of data, besides on weekend
*      Weekends have the biggest volume of casual, starting on friday, a ~15% increase.

##### **Hour of the day**
What is the hour distribution over the week

#ZDJECIE

From this chart, we can see:
*      There's a bigger volume of bikers in the afternoon.
*      We have more members during the morning, mainly in between 5am and 11am
*      And more casuals between 11pm and 4am
*      This chart can be expanded ween seen it divided by day of the week.

```R
df_no_dups %>%
    ggplot(aes(hour, fill=member_casual)) +
    geom_bar() +
    labs(x="Hour of the day", title="Chart 05 - Distribution by hour of the day divided by weekday") +
    facet_wrap(~ end_day)
```

#ZDJECIE

The two plots differs on some key ways:
*      While the weekends have a smooth flow of data points, the midweek have a more steep flow of data.
*      There's a big increase of data points in the midween between 6am to 8am. Then it fall a bit.
*      Another big increase is from 5pm to 6pm.
*      During the weekend we have a bigger flow of casuals between 11am to 6pm.


##### **Rideable type**
```R
df_no_dups %>%
    group_by(rideable_type) %>% 
    summarise(count = length(ride_id),
          '%' = (length(ride_id) / nrow(df_no_dups)) * 100,
          'members_p' = (sum(member_casual == "member") / length(ride_id)) * 100,
          'casual_p' = (sum(member_casual == "casual") / length(ride_id)) * 100,
          'member_casual_perc_difer' = members_p - casual_p)
```

#ZDJECIE

It's important to note that:
*      Classic bikes have the biggest volume of rides, but this can be that the company may have more classic bikes.
*      Members have a bigger preference for classic bikes, 61% more.
*      Also for electric bikes, 53%.

##### **ride_time_m**
```R
summary(df_no_dups$ride_time_m)
```

```R
ventiles = quantile(df_no_dups$ride_time_m, seq(0, 1, by=0.05))
ventiles
```
          0%           5%          10%          15%          20%          25%          30%          35%          40%          45%          50% 
1.666667e-02 2.800000e+00 3.983333e+00 4.950000e+00 5.850000e+00 6.750000e+00 7.666667e+00 8.633333e+00 9.666667e+00 1.076667e+01 1.200000e+01 
         55%          60%          65%          70%          75%          80%          85%          90%          95%         100% 
1.336667e+01 1.495000e+01 1.680000e+01 1.903333e+01 2.178333e+01 2.530000e+01 3.003333e+01 3.771667e+01 5.588333e+01 5.594415e+04 

We can see that:
*      The difference between 0% and 100% is 55944 minutes.
*      The difference between 5% and 95% is 53 minutes. Because of that, in the analysis of this variable we are going to use a subset of the dataset without outliners. The subset will contain 95% of the dataset.

```R
cyclistic_without_outliners <- df_no_dups %>% 
    filter(ride_time_m > as.numeric(ventiles['5%'])) %>%
    filter(ride_time_m < as.numeric(ventiles['95%']))

print(paste("Removed", nrow(df_no_dups) - nrow(cyclistic_without_outliners), "rows as outliners" ))
```
[1] "Removed 561419 rows as outliners"



### **Phase 5: Share - supporting visualizations and key findings**

### **Phase 6: Act - top three recommendations based on analysis**

