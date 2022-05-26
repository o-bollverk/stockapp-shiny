# Combine data 

library(data.table)
library(dplyr)
library(shiny)
library(purrr)
library(jsonlite)
library(gtrendsR)
library(dplyr)
library(tidyr)
library(magrittr)
library(stringr)
library(lubridate)
library(plotly)

# Load tweet and price data ---------
data_dir <- "~/shinyapp-data/"

tesla_df <- fread(paste0(data_dir, "TSLA.csv"))
btc_df <- fread(paste0(data_dir, "BTC.csv"))
aapl_csv <- fread(paste0(data_dir, "AAPL.csv"))

btc_tweet_df <- jsonlite::read_json(paste0(data_dir, "bitcointweet.json"),simplifyVector = T) %>%
  mutate(time = as.POSIXct(
    strptime(
      gsub(
        pattern = ",", replacement = "", timestamp), "%d/%m/%Y %H:%M:%S")
  ))

# btc_tweet_df2 <- jsonlite::read_json(paste0(data_dir, "data.json"),simplifyVector = T) %>%
#   mutate(time = as.POSIXct(
#     strptime(
#       gsub(
#         pattern = ",", replacement = "", timestamp), "%d/%m/%Y %H:%M:%S")
#   ))
# 

tesla_tweet_df <- jsonlite::read_json(paste0(data_dir, "tsla4.json"),simplifyVector = T) %>%
  mutate(time = as.POSIXct(
    strptime(
      gsub(
        pattern = ",", replacement = "", timestamp), "%d-%m-%Y %H:%M:%S")
  ))

stock_df <- rbind.data.frame(
  tesla_df %>%
    mutate(stock = "Tesla"),
  btc_df %>%
    mutate(stock = "Bitcoin"),
  aapl_csv %>%
    mutate(stock = "Apple")
)

stock_df$timestamp <- gsub(pattern = ",", replacement = "", stock_df$timestamp)
stock_df$time <- as.POSIXct(strptime(stock_df$timestamp, "%d-%m-%Y %H:%M:%S"))

# tweet -------------
tweets_df <- rbind.data.frame(btc_tweet_df,
                 tesla_tweet_df) %>% 
  mutate(value = keyword) %>% 
  select(-timestamp)


# Obtain google trends data with the gtrendsR package ---------

trends_vec <- vector(mode = "list")

for(symbol in c("Tesla", "Apple", "Bitcoin")){
  #trends <- gtrends(keyword = symbol, geo = "US", onlyInterest = TRUE,time = "NOW-H")
  trends <- gtrends(keyword = symbol, geo = "US", onlyInterest = TRUE,time = "now 1-d")
  trends <- trends$interest_over_time %>%
    as_data_frame() %>%
    select(c(date, hits, keyword))
  #trends$date <- as_date(ceiling_date(trends$date, unit = "weeks", change_on_boundary = NULL,
  #                                    week_start = getOption("lubridate.week.start", 1)))
  trends_vec[[symbol]] <- trends
}

trends_df <- data.table::rbindlist(trends_vec)


# reshape some variables -----------
