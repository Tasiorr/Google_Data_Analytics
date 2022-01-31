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

##### **Load packages in R Programming**

       library(tidyverse)  #helps wrangle data
       library(lubridate)  #helps wrangle date attributes
       library(ggplot2)    #helps visualize data
       library(dplyr)
    
##### **Organize: Reading the data from CSV files**

       csv_files <- list.files(path = "C:/Users/...../CSV", recursive = TRUE, full.names = TRUE) %>%
        lapply(read_csv) %>%
        bind_rows

##### **Creating a Data Frame - all the CSV flies will be concatented into one dataframe**

       df <- as.data.frame(csv_files)

##### **Data cleaning**
Removing Duplicates

      df_no_dups <- df[!duplicated(df$ride_id),]
      print(paste("Removed", nrow(df) - nrow(df_no_dups), "duplicated rows"))

##### **Parsing datetime columns**
Total time of a bike ride

      df_no_dups <- df_no_dups %>%
        mutate(ride_time_m = as.numeric(df_no_dups$ended_at - df_no_dups$started_at)/60)
      summary(df_no_dups$ride_time_m)

| Min         | 1st Qu.     | Median    | Mean       | rd Qu.       | Max    |
|-------------|-------------|-----------|------------|--------------|--------|
| -58.03      | 6.75        | 12.00     |21.94       |21.78         |55944.15|

##### **Parsing datetime columns**
Added new columns: Year, Month, Day of the week

    df_no_dups <- df_no_dups %>%
        mutate(start_day = weekdays(started_at),
            end_day = weekdays(ended_at),
            moth = format(as.POSIXct(started_at), "%B"),
            year = year(started_at),
            start_lat = NULL,
            start_lng = NULL,
            end_lat = NULL)

##### **Negative values of the trip duration has to be deleted**
Negativ tripduration

    df_no_dups %>% 
        filter(ride_time_m < 0) %>% 
        summarize("value"=n()) ##Number of negative values

Remove the negative values

    df_no_dups <- df_no_dups %>%
        filter(-ride_time_m < 0)

##### **Saving the result as a CSV**

      df_no_dups %>%
        write.csv("case_study_1.csv")


### **Phase 4: Analyzing Data - a summary of analysis**

### **Phase 5: Share - supporting visualizations and key findings**

### **Phase 6: Act - top three recommendations based on analysis**

