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
