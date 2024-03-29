library(data.table)
library(dplyr)
library(shiny)
library(purrr)
library(jsonlite)
library(prophet)
library(shiny)
library(DT)
#library(leaflet)
library(plotly)
library(shinydashboard)

#data_dir <- "~/shinyapp-data/"
#list.files(data_dir)
#combined_df <- data.table::fread(paste0(data_dir, "tweets_trends_prices_combined.csv"))
bucket <- s3_bucket("ccbda-final-proj")
combined_df = read_csv_arrow(bucket$path("tweets_trends_prices_combined.csv"))
aggregated_df = read_csv_arrow(bucket$path("result_aggregated.csv"))

# data_dir <- "/home/revilo/shinyapp-data/"
# combined_df <- data.table::fread(paste0(data_dir, "tweets_trends_prices_combined.csv")) %>% 
#   as_tibble()
# aggregated_df <- data.table::fread(paste0(data_dir, "result_aggregated.csv")) %>% 
#   as_tibble()

combined_df <- combined_df %>% 
  filter(!(value_type == "keyword" & value == 0))

stock_df <- combined_df %>% 
  filter(value_type == "stock") %>% 
  mutate(value = as.numeric(value)) %>% 
  mutate(stock = symbol)

return_loess <- function(value_col, time_col, span = 0.5, family = "gaussian") {
  fun_df <- data.frame(value_col, time_col) #symmetric
  names(fun_df) <- c("value", "time")
  loess_fun <- loess(data = fun_df,
                     formula =  value ~ as.numeric(time), span = span, family  = family)
  return(predict(loess_fun))
}

stock_df <- stock_df %>%
  arrange(stock) %>%
  mutate(smoothed_value = 
           stock_df %>%
           group_by(stock) %>%
           summarise(smoothed_value =
                       return_loess(value, time)) %>%
           ungroup() %>%
           arrange(stock) %>% 
           pull(smoothed_value))

trends_df <- 
  combined_df %>% 
  filter(value_type == "keyword") %>% 
  mutate(value = as.numeric(value))

normalize_to_onezero <- function(x){(x-min(x))/(max(x)-min(x))}

