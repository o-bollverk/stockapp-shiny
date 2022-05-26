library(data.table)
library(dplyr)
library(shiny)
library(purrr)
library(jsonlite)

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

btc_tweet_df2 <- jsonlite::read_json(paste0(data_dir, "data.json"),simplifyVector = T) %>%
  mutate(time = as.POSIXct(
    strptime(
      gsub(
        pattern = ",", replacement = "", timestamp), "%d/%m/%Y %H:%M:%S")
  ))


# appl_tweet_df <- jsonlite::read_json(paste0(data_dir, "apple.json"),simplifyVector = T) %>%
#   mutate(time = as.POSIXct(
#     strptime(
#       gsub(
#         pattern = ",", replacement = "", timestamp), "%d-%m-%Y %H:%M:%S")
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

# calculate wordcount
btc_tweet_df %>%
  mutate(day_minute = substr(timestamp, 1, nchar(timestamp) - 3)) %>%
  group_by(day_minute) %>%
  summarise(wordcount = stringi::stri_count_fixed(pattern = "Bitcoin",str = text)) %>%
  ungroup()

# stock_df %>% head()
# loess(data = stock_df %>%
#         filter(stock == "Tesla"),
#         formula = time ~ price)
# predict(loess_fun)
return_loess <- function(price_col, time_col) {
  fun_df <- data.frame(price_col, time_col)
  names(fun_df) <- c("price", "time")
  loess_fun <- loess(data = fun_df,
                     formula =  price ~ as.numeric(time))
 return(predict(loess_fun))
}
stock_df <- stock_df %>%
  arrange(stock) %>%
  bind_cols(
    stock_df %>%
    group_by(stock) %>%
    summarise(smoothed_price =
                return_loess(price, time)) %>%
    ungroup() %>%
      arrange(stock) %>%
      select(-stock)
  )
normalize_to_onezero <- function(x)(x-min(x))/(max(x)-min(x))
stock_df <- stock_df %>%
  group_by(stock) %>%
  mutate(price = normalize_to_onezero(price),
         smoothed_price = normalize_to_onezero(smoothed_price)) %>%
  ungroup()
#stock_df
# shinydashboard ----------------
library(tidyverse)
library(shiny)
library(DT)
#library(leaflet)
library(plotly)
library(shinydashboard)
library(ggrepel)
ui = dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    selectInput(
      "stock_selection",
      label = "Select stock or Bitcoin",
      choices = c("Apple", "Tesla", "Bitcoin"),
      selected = c("Apple", "Tesla", "Bitcoin"),
      multiple = T
    ),
    sliderInput(
      "stock_selection",
      label = "Select time interval",
      min = stock_df$time %>% min(),
      max = stock_df$time %>% max(),
      value = c(stock_df$time %>% min(),
                stock_df$time %>% max())
    )
    # sliderInput(
    #   "slider",
    #   label = "Happiness index",
    #   min = 0,
    #   max = 1,
    #   value = c(.25, 0.75)
    # )
  ),
  dashboardBody(
    box(
      title = "Stock price with their estimates",
      plotlyOutput("plot",width = "1200px", height = "900px"),
    ),
    # box(
    #   title = "Box2",
    #   p("Box2")
    # ),
    # box(
    #   h1("Box3"),
    #   p("Box3", style = "color:grey")
    # )
  )
)
server = function(input, output){
  output$plot = renderPlotly({
    ggplot(stock_df %>%
             filter(stock %in% input$stock_selection),
           aes(x = time, y = price,
                                                           color = stock, group = stock)) +
      geom_point() +
      geom_line() +
      geom_line(data = stock_df %>%
                  filter(stock %in% input$stock_selection),
                aes(x = time, y = smoothed_price, color = stock)) +
      theme_bw() +
      ggtitle("Loess function estimated and actual price for stock") #+
      #theme(title = element_text(size = "20"))
  })
}
shinyApp(ui = ui, server = server)
