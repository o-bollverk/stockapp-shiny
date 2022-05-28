library(data.table)
library(dplyr)
library(shiny)
library(purrr)
library(jsonlite)
library(prophet)
library(tidyverse)
library(shiny)
library(DT)
#library(leaflet)
library(plotly)
library(shinydashboard)
library(ggrepel)

data_dir <- "~/shinyapp-data/"
list.files(data_dir)
combined_df <- data.table::fread(paste0(data_dir, "tweets_trends_prices_combined.csv"))

# no zeros in keyword
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

# shinydashboard ----------------


normalize_to_onezero <- function(x)(x-min(x))/(max(x)-min(x))


ui = dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    sidebarMenu(
      menuItem(text = "Data overview",
               startExpanded = T,
               icon = icon("table"),
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
    )
    )
    ),
    sidebarMenu(
      menuItem(text = "Forecasting and analytics",
               icon = icon("signal"),
        startExpanded = T,
    radioButtons(
      "loess_family",
    label = "Select the type of algorithm to use",
    choiceNames =  c("Gaussian", "Symmetric"), 
    choiceValues =  c("gaussian", "symmetric"), 
    selected = "gaussian",
    ),
    radioButtons(
      "stock_selection_prediction",
      label = "Select stock for prediction",
      choiceNames =  c("Apple","Tesla", "Bitcoin"), 
      choiceValues =  c("Apple", "Tesla", "Bitcoin"), 
      selected = "Apple",
    ),
    sliderInput(
      "prediction_days_slider",
      label = "Select number of days for prediction interval",
      min = 5,
      max = 40,
      value = 20, 
      ticks = F
    )
      )
    ),
    width = "350px"
    
),
  dashboardBody(
    #mainPanel(
      tabsetPanel(type = "pills",#id = "tabs",
        tabPanel("Data overview",#tabItem(tabName = "test",
          fluidRow(
            box(
              title = "Prices with their smoothed estimations",
              width = 8,
              plotlyOutput("plot",width = "1200px", height = "500px"),
            ),
            ),
          fluidRow(
            box(
              width = 8,
              title = "Google trends",
              plotlyOutput("plot2", width = "1200px", height = "500px")
            )
          )
        ),
      
        # box(
        #   title = "Box2",
        #   p("Box2")
        # ),
        # box(
        #   h1("Box3"),
        #   p("Box3", style = "color:grey")
        # )
        #tabName = "Data overview"
       #),
      tabPanel("Forcasting and analytics",
               #tabItem(tabName = "test2",
        #tabName = "Modelling and forecasting",
        fluidRow(
          box(
            width = 8,
            title = "Price forecast",
            plotlyOutput("plot3",width = "1200px", height = "500px"),
          )
          ),
        fluidRow(
          box(
            width = 8,
            title = "Normalized Google trend score and normalized price",
            plotlyOutput("plot4", width = "1200px", height = "500px")
          )
        )
      ),
      tabPanel("Aggregated statistics",
               #tabItem(tabName = "test2",
               #tabName = "Modelling and forecasting",
               fluidRow(
                 box(
                   width = 8,
                   title = "Mean price over a window of 14 days",
                   plotlyOutput("plot5",width = "1200px", height = "500px"),
                 )
               ),
               fluidRow(
                 box(
                   width = 8,
                   title = "Mean sentiment",
                   plotlyOutput("plot6", width = "1200px", height = "500px")
                 )
               )
      )
  )
)
)
#)

server = function(input, output){
  output$plot = renderPlotly({
    ggplot(stock_df %>%
             filter(stock %in% input$stock_selection) %>% 
             filter(time > input$time_slider[1] & 
                      time < input$time_slider[2]),
           aes(x = time, y = value,
                                                           color = stock, group = stock)) +
      #geom_point() +
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
                aes(x = time, y = smoothed_value, color = stock, 
                    alpha = 0.5),
                linetype = "dashed") +
      theme_bw() + 
      ylim(0, NA) + 
      theme(legend.text = element_blank())#+
      #theme_bw() +
      #ggtitle("Loess function estimated and actual value for stock") #+
      #theme(title = element_text(size = "20"))
  })
  output$plot2 = renderPlotly({
    ggplot(trends_df %>%
             filter(time > input$time_slider[1] & 
                      time < input$time_slider[2]) %>% 
             filter(symbol %in% input$stock_selection),
           aes(x = time, y = value,
               color = symbol, group = symbol)) +
      #geom_point() +
      geom_line() +
      theme_bw() #+
      #ggtitle("Google trend")
  })
  output$plot3 = renderPlotly({
    #predictions
    m <- prophet( stock_df %>%
                    filter(symbol == input$stock_selection_prediction) %>% 
                    select(ds = time, y = value))
    future <- make_future_dataframe(m, periods = input$prediction_days_slider) %>% 
      filter(!wday(ds) 
             %in% c(1,7)) #account for regular gaps on weekends
    
    forecast <- predict(m, future) 
    
    plot(m, forecast, xlabel = "", ylabel = 
           "Price ($)") +
      theme(
        axis.title.y = element_text(size = 14),
        axis.title.x = element_blank(),
        title = element_text(size = 18)
      ) + 
      theme_bw() + 
      ggtitle(input$stock_selection_prediction)

    #theme(title = element_text(size = "20"))
  })
  output$plot4 = renderPlotly({
    
    combined_df %>% 
      filter(symbol == input$stock_selection_prediction) %>% 
      #filter(time %in% )
      #mutate(value = ifelse(value_type == "text", as.numeric(wordcount), value)) %>% 
      filter(time > input$time_slider[1] & 
             time < input$time_slider[2]) %>% 
      filter(value_type != "text") %>% 
      mutate(value = as.numeric(value)) %>% 
      group_by(value_type) %>% 
      mutate(normalized_value = normalize_to_onezero(value)) %>% 
      ungroup() %>% 
      ggplot(aes(x = time, y = normalized_value, color = value_type, group = value_type)) + 
      #geom_point() + 
      geom_line() + 
      theme_bw() + 
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank()
      ) + 
      ggtitle(input$stock_selection_prediction)
  })
  output$plot5 = renderPlotly({
    
    combined_df %>% 
      filter(symbol == input$stock_selection_prediction) %>% 
      #filter(time %in% )
      #mutate(value = ifelse(value_type == "text", as.numeric(wordcount), value)) %>% 
      filter(time > input$time_slider[1] & 
               time < input$time_slider[2]) %>% 
      filter(value_type != "text") %>% 
      mutate(value = as.numeric(value)) %>% 
      group_by(value_type) %>% 
      mutate(normalized_value = normalize_to_onezero(value)) %>% 
      ungroup() %>% 
      ggplot(aes(x = time, y = normalized_value, color = value_type, group = value_type)) + 
      #geom_point() + 
      geom_line() + 
      theme_bw() + 
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank()
      ) + 
      ggtitle(input$stock_selection_prediction)
  })
  output$plot6 = renderPlotly({
    
    combined_df %>% 
      filter(symbol == input$stock_selection_prediction) %>% 
      #filter(time %in% )
      #mutate(value = ifelse(value_type == "text", as.numeric(wordcount), value)) %>% 
      filter(time > input$time_slider[1] & 
               time < input$time_slider[2]) %>% 
      filter(value_type != "text") %>% 
      mutate(value = as.numeric(value)) %>% 
      group_by(value_type) %>% 
      mutate(normalized_value = normalize_to_onezero(value)) %>% 
      ungroup() %>% 
      ggplot(aes(x = time, y = normalized_value, color = value_type, group = value_type)) + 
      #geom_point() + 
      geom_line() + 
      theme_bw() + 
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank()
      ) + 
      ggtitle(input$stock_selection_prediction)
  })
  
}

shinyApp(ui = ui, server = server)

combined_df %>% 
  filter(symbol == "Bitcoin") %>%  
  #mutate(value = ifelse(value_type == "text", as.numeric(wordcount), value)) %>% 
  filter(value_type != "text") %>% 
  mutate(value = as.numeric(value)) %>% 
  group_by(value_type) %>% 
  mutate(normalized_value = normalize_to_onezero(value)) %>% 
  ungroup() %>% 
  ggplot(aes(x = time, y = normalized_value, color = value_type, group = value_type)) + 
  geom_point() + 
  geom_line(alpha = 0.2) + 
  theme_bw()

# plot x y plot

combined_df %>% 
  filter(symbol == "Bitcoin") %>%  
  #mutate(value = ifelse(value_type == "text", as.numeric(wordcount), value)) %>% 
  filter(value_type != "text") %>% 
  mutate(value = as.numeric(value)) %>% 
  
  group_by(value_type) %>% 
  mutate(normalized_value = normalize_to_onezero(value)) %>% 
  ungroup() %>% 
  ggplot(aes(x = time, y = normalized_value, color = value_type)) + geom_point()




