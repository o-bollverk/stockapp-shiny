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
# 
# stock_df <- stock_df %>%
#   group_by(stock) %>%
#   mutate(value = normalize_to_onezero(value),
#          smoothed_value = normalize_to_onezero(smoothed_value)) %>%
#   ungroup()

#stock_df
# shinydashboard ----------------
library(tidyverse)
library(shiny)
library(DT)
#library(leaflet)
library(plotly)
library(shinydashboard)
library(ggrepel)

normalize_to_onezero <- function(x)(x-min(x))/(max(x)-min(x))


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
      "time_slider",
      label = "Select time for price plot interval",
      min = stock_df$time %>% min(),
      max = stock_df$time %>% max(),
      value = c(stock_df$time %>% min(),
              stock_df$time %>% max()), ticks = F
    ), 
    sliderInput(
      "loess_slider",
      label = "Select a parameter for the price estimation function",
      min = 0.1,
      max = 0.9,
      value = 0.7,
      ticks = T
    ),
    radioButtons(
      "loess_family",
    label = "Select the type of algorithm to use",
    choiceNames =  c("Gaussian", "Symmetric"), 
    choiceValues =  c("gaussian", "symmetric"), 
    selected = "gaussian",
    ),
    width = "350px"
),
  dashboardBody(
    fluidRow(
      box(
        title = "Stock value with their estimates.",
        plotlyOutput("plot",width = "1200px", height = "500px")
      )),
    fluidRow(
      box(
        title = "Google trends.",
        plotlyOutput("plot2", width = "1200px", height = "500px")
      )
      )
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
             filter(stock %in% input$stock_selection) %>% 
             filter(time > input$time_slider[1] & 
                      time < input$time_slider[2]),
           aes(x = time, y = value,
                                                           color = stock, group = stock)) +
      geom_point() +
      geom_line(size = 0.6, alpha = 0.8) +
      geom_line(data = stock_df %>% 
                  arrange(stock) %>%   #stock_df %>%
                      mutate(smoothed_value = 
                           stock_df %>%
                           group_by(stock) %>%
                           summarise(smoothed_value =
                                       return_loess(value, time, span = input$loess_slider, family = input$loess_family )) %>%
                           ungroup() %>%
                           arrange(stock) %>% 
                             pull(smoothed_value)) %>% 
                  filter(stock %in% input$stock_selection) %>% 
                  filter(time > input$time_slider[1] & 
                           time < input$time_slider[2]),
                aes(x = time, y = smoothed_value, color = stock, alpha = 0.5),
                linetype = "dashed") +
      theme_bw() +
      ggtitle("Loess function estimated and actual value for stock") #+
      #theme(title = element_text(size = "20"))
  })
  output$plot2 = renderPlotly({
    ggplot(trends_df %>%
             filter(symbol %in% input$stock_selection),
           aes(x = time, y = value,
               color = symbol, group = symbol)) +
      geom_point() +
      geom_line() +
      theme_bw() +
      ggtitle("Google trend") #+
    #theme(title = element_text(size = "20"))
  })
}
shinyApp(ui = ui, server = server)
