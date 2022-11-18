shinyServer <- function(input, output) {
  
  
  
  #############################################################################
  # user input log files
  MCMC = reactive({
    
    inFile <- input$log_file1
    
    if (is.null(inFile))
      return(NULL)
    
    trace <- read_bt_log(inFile)
    header <- read_bt_header(inFile)
    
    return(list(trace=trace,
                header=header))

  })
  

  #############################################################################
  # Log file headers

  output$btHeader <- renderReactable({
  
    validate(need(nrow(MCMC()$header)>0,'Please upload at least one BT log file using the input field on the sidebar'))
    
    MCMC()$header %>%
      as_tibble() %>%
      reactable()
  })
  
  
  
  #############################################################################
  # trace plots
  output$LhTrace <- renderPlotly({
    
    validate(need(nrow(MCMC()$trace)>0,'Please upload at least one BT log file using the input field on the sidebar'))
    
    LhTrace_gg<-MCMC()$trace %>%
    ggplot(aes(x=Iteration, y=Lh, color=`Run ID`)) +
      geom_line(size=0.25, alpha=0.9) +
      geom_smooth(se = FALSE, color="black", size=0.5) +
      theme_bw()
    
    ggplotly(LhTrace_gg)
  })  
  
  output$LhDensity <- renderPlotly({
    
    validate(need(nrow(MCMC()$trace)>0,'Please upload at least one BT log file using the input field on the sidebar'))
    
    LhDensity_gg<-MCMC()$trace %>%
      ggplot(aes(x=Lh, fill=`Run ID`)) +
      geom_density(alpha=0.25, color=NA) +
      theme_bw()
    
    ggplotly(LhDensity_gg)
  })  
  
  #############################################################################
  # Root state pie
  
  output$RootState <- renderPlotly({
  
    RootState_gg<-MCMC()$trace %>%
      select(`Run ID`,starts_with("Root")) %>%
      #filter(model=="run 1") %>%
      group_by(`Run ID`) %>%
      summarise_all(mean) %>%
      pivot_longer(-`Run ID`, names_to="Root State",values_to="prob") %>%
      mutate(`Root State`=str_remove_all(`Root State`, pattern="Root P\\(|\\)")) %>%
      ggplot(aes(x=`Run ID`,y=prob, fill=`Root State`)) +
      geom_bar(stat="identity") +
      #scale_fill_manual(values=c("#24b9e9","#55FF7E","#009E73","#BF9C00","#f6776f"),
      #                labels=c("Aquatic","Direct","Semi","Terr","Viv"),
      #                breaks=c("Root P(A)","Root P(D)","Root P(S)","Root P(T)","Root P(V)")) +
    #ggtitle("BayesTraits root states") +
    coord_polar("y") +
    theme_void()

    ggplotly(RootState_gg)
  })  
  
  #############################################################################
  # States densities
  
  #############################################################################
  # full log table outpud
  output$logtable <- renderTable({
    MCMC()$trace %>%
      slice_head(n=10) ### limited to the first 10 lines!!!
  })
  
    
}








