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
    sidebarMenu(
      menuItem(text = "Aggregated price and sentiment",
               icon = icon("dollar"),
               startExpanded = T,
               radioButtons(
                 "window_size_selection",
                 label = "Select window size to aggregate over",
                 choiceNames =  c(3, 7, 14), 
                 choiceValues =  c(3, 7, 14), 
                 selected = 7,
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
                             title = "Mean price over a selected window of days",
                             plotlyOutput("plot5",width = "1200px", height = "500px"),
                           )
                         ),
                         fluidRow(
                           box(
                             width = 8,
                             title = "Mean sentiment over a selected window of days",
                             plotlyOutput("plot6", width = "1200px", height = "500px")
                           )
                         )
                )
    )
  )
)