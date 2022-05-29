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
    
    trends_df %>% 
      filter(symbol == input$stock_selection_prediction) %>% 
      filter(window_size == input$window_size_selection) %>% 
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
    aggregated_df %>% 
      filter(symbol == input$stock_selection) %>% 
      filter(window_size == input$window_size_selection) %>%
      filter(value_type == "price") %>% 
      filter(time > input$time_slider[1] & 
               time < input$time_slider[2]) %>% 
      ggplot(aes(x = time, y = mean, color = symbol, group = symbol)) + 
      #geom_point() + 
      geom_line() + 
      theme_bw() + 
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank()
      ) 
    
  })
  output$plot6 = renderPlotly({
    
    aggregated_df %>% 
      filter(symbol == input$stock_selection) %>% 
      filter(value_type == "sentiment") %>% 
      filter(time > input$time_slider[1] & 
               time < input$time_slider[2]) %>% 
      ggplot(aes(x = time, y = mean, color = symbol, group = symbol)) + 
      #geom_point() + 
      geom_line() + 
      theme_bw() + 
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_blank()
      ) 
  })
  
}
