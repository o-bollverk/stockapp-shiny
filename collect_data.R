# Combine data from 3 source before uploading to S3 ---------
library(data.table)
library(dplyr)
library(purrr)
library(jsonlite)
library(tidyr)
library(magrittr)
library(stringr)
library(lubridate)
library(gtrendsR)

# Load tweet and price data ---------
data_dir <- "/home/revilo/shinyapp-data/"

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

stock_df <- stock_df %>% 
  mutate(value = price) %>% 
  mutate(value_type = "stock") %>% 
  mutate(symbol = stock) %>% 
  select(-price, -stock, -timestamp) 

  
# tweets dataframe -------------
tweets_df <- rbind.data.frame(btc_tweet_df %>% 
                                mutate(symbol = "Bitcoin"),
                 tesla_tweet_df %>% 
                   mutate(symbol = "Tesla")) %>% 
  mutate(value = text) %>% 
  mutate(value_type = "text") %>% 
  select(-timestamp, -id, -text) #%>% 
 # mutate(time = as.POSIXct(strptime(.$time, "%Y-%m-%d- %H:%M:%S")))

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
trends_df <- trends_df %>% 
  mutate(value = hits) %>% 
  mutate(time = date) %>% 
  mutate(symbol = keyword) %>% 
  mutate(value_type = "keyword") %>%
  select(-keyword, -hits, -date)

# combine into single csv --------
rbind.data.frame(
  tweets_df,
  trends_df %>% 
    select(names(tweets_df)) %>% 
    mutate(value = as.character(value)),
  stock_df %>%  
    select(names(tweets_df)) %>% 
    mutate(value = as.character(value))
)
combined_df <- 
  rbind.data.frame(
    tweets_df,
    trends_df,
    stock_df
  )

# remove commas
combined_df <- combined_df %>% 
  mutate(value = gsub(pattern = ",", replacement = "", value))

# perform basic wordcount -----------

combined_df <- combined_df %>% 
  mutate(wordcount = ifelse(value_type == "text", 
                            stringi::stri_count_fixed(pattern = symbol ,str = value) + 
                              stringi::stri_count_fixed(pattern = paste0("#", symbol) ,str = value) + 
                              stringi::stri_count_fixed(pattern = str_to_lower(symbol) ,str = value),
                            0))
# write dataframe --------
# write.table(combined_df,
#             paste0(data_dir, "tweets_trends_prices_combined.csv"), sep = ",", row.names = F)

data.table::fwrite(combined_df,  paste0(data_dir, "tweets_trends_prices_combined.csv"))
