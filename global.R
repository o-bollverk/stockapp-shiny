library(data.table)
library(dplyr)
library(shiny)
library(purrr)
library(jsonlite)

data_dir <- "~/shinyapp-data/"
list.files(data_dir)
combined_df <- data.table::fread(paste0(data_dir, "tweets_trends_prices_combined.csv"))

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
