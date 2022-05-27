#install.packages("gtrendsR")
library(gtrendsR)
library(dplyr)
library(tidyr)
library(magrittr)
library(stringr)
library(lubridate)
library(plotly)

# http://rstudio-pubs-static.s3.amazonaws.com/493413_f3d12f11474a4484b2791dd0fd0a9bf5.html

for(symbol in c("Tesla", "Apple", "Bitcoin")){
  #trends <- gtrends(keyword = symbol, geo = "US", onlyInterest = TRUE,time = "NOW-H")
  trends <- gtrends(keyword = symbol, geo = "US", onlyInterest = TRUE,time = "today 3-m")
  trends <- trends$interest_over_time %>%
    as_data_frame() %>%
    select(c(date, hits, keyword))
  #trends$date <- as_date(ceiling_date(trends$date, unit = "weeks", change_on_boundary = NULL,
  #                                    week_start = getOption("lubridate.week.start", 1)))
  trends_vec[[symbol]] <- trends
}

