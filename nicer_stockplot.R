stock_df
p1 <- stock_df %>%
  filter(symbol == "Tesla") %>% 
  mutate(date = time) %>% 
  plot_ly(x = ~date,
          type = "candlestick", 
          open = ~value, 
          close = ~value + 0.001,
          high = ~value,
          low = ~value,
          name = "symbol") %>%
  layout(
    xaxis = list(
      rangeselector = list(
        buttons = list(
          list(
            count = 1,
            label = "1 mo",
            step = "week",
            stepmode = "backward"),
          list(
            count = 3,
            label = "3 mo",
            step = "month",
            stepmode = "backward"),
          list(
            count = 6,
            label = "6 mo",
            step = "month",
            stepmode = "backward"),
          list(
            count = 1,
            label = "1 yr",
            step = "year",
            stepmode = "backward"),
          list(
            count = 3,
            label = "3 yr",
            step = "year",
            stepmode = "backward"),
          list(step = "all"))),
      rangeslider = list(visible = FALSE)),
    yaxis = list(title = "Price ($)",
                 showgrid = TRUE,
                 showticklabels = TRUE))

p1 


p2 <- stock %>%
  plot_ly(x=~date, y=~volume, type='bar', name = "Volume") %>%
  layout(yaxis = list(title = "Volume"))

p <- subplot(p1, p2, heights = c(0.7,0.3), nrows=2,
             shareX = TRUE, titleY = TRUE) %>%
  layout(title = paste0(symbol))
p