# Calculate wordcount with R.  ------------

library(data.table)
library(dplyr)
library(purrr)
library(jsonlite)
library(tidyr)
library(magrittr)
library(stringr)
library(lubridate)

# Load tweet and price data ---------
combined_df <- data.table::fread(paste0(data_dir, "tweets_trends_prices_combined.csv"))
combined_df <- combined_df %>% 
  mutate(wordcount = ifelse(value_type == "text", 
                       stringi::stri_count_fixed(pattern = symbol ,str = value) + 
                         stringi::stri_count_fixed(pattern = paste0("#", symbol) ,str = value) + 
                         stringi::stri_count_fixed(pattern = str_to_lower(symbol) ,str = value),
                       0))
combined_df