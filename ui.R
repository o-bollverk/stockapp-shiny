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
