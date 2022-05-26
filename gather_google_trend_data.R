#install.packages("gtrendsR")
library(gtrendsR)
library(dplyr)
library(tidyr)
library(magrittr)
library(stringr)
library(lubridate)
library(plotly)

# http://rstudio-pubs-static.s3.amazonaws.com/493413_f3d12f11474a4484b2791dd0fd0a9bf5.html


symbol <- "TESLA"
trends <- gtrends(keyword = symbol, geo = "US", onlyInterest = TRUE)
trends <- trends$interest_over_time %>%
  as_data_frame() %>%
  select(c(date, hits, keyword))
trends$date <- as_date(ceiling_date(trends$date, unit = "weeks", change_on_boundary = NULL,
                                    week_start = getOption("lubridate.week.start", 1)))

trends



trends %>%  
  plot_ly(x=~date, y=~hits, mode = 'lines', name = "Google Search Trends") %>%
  layout(title = paste0("Interest over Time: ",symbol), yaxis = list(title = "hits"))

trends <- gtrends(keyword = symbol, geo = "US", onlyInterest = TRUE)
trends <- trends$interest_over_time %>%
  as_data_frame() %>%
  select(c(date, hits, keyword))
trends$date <- as_date(ceiling_date(trends$date, unit = "weeks", change_on_boundary = NULL,
                                    week_start = getOption("lubridate.week.start", 1)))
trends %>%  
  plot_ly(x=~date, y=~hits, mode = 'lines', name = "Google Search Trends") %>%
  layout(title = paste0("Interest over Time: ",symbol), yaxis = list(title = "hits"))
