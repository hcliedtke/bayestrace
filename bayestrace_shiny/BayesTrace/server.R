server <- function(input,output,session){
  #======================
  # global server settings
  options(shiny.maxRequestSize=30*1024^2) 
  
  
  #=======================
  # help button
  observeEvent(input$help_btn, {
    # Show a simple modal
    shinyalert(title="Getting Started", type="info",
    text = "To get started, select some (or all) files in a folder that contains your BayesTraits output files. The selected files should contained at least one of these:
    
    1. a log file (.Log.txt)
    2. a shedule file (.Shedule.txt)
    3. a tree file (.trees)
    
    Optional files include:
    
    a) a stones file (.stones.txt)
    
    For any problems, raise an issue in the github repository (link at bottom of page)"
    
    )
  })

  #=======================
  # Index user-specified BayesTraits files
  
  file_index<-reactive({
    req(input$bt_files)
    data.frame(filename=input$bt_files$name) %>%
      mutate(
        filetype=case_when(
          str_detect(filename,"Log.txt") ~ "log",
          str_detect(filename,"Schedule.txt") ~ "schedule",
          str_detect(filename,"Stones.txt") ~ "stones",
          str_detect(filename,"\\.tre\\w+$|\\.nex$|\\.nexus$") ~ "tree",
          TRUE ~ "unknown"),
        filepath=input$bt_files$datapath
        )
               
  })
  
  # render file index table. uncomment for trouble shooting
  output$fileindex <- renderTable(file_index())
  
  
  #=======================
  # Plot info boxes
  
  observeEvent(file_index(),{
    
    #### INFO BOX: NUMBER OF LOG FILES
    
    output$value_n_logs <- shinydashboard::renderInfoBox({
      shinydashboard::infoBox(value = sum(file_index()$filetype=="log", na.rm=T),
                               title = "Log files found:",
                               icon = icon("clipboard"),
                               color="teal", fill=TRUE)
    })
    
    #### INFO BOX: RUN TYPE
    
    header_list<-read_header(file_path=file_index() %>%
                               filter(filetype=="log") %>%
                               pull(filepath))
                             
    run_mode<-case_when(
      any(str_detect(header_list[[1]]$X, "Discrete")) ~ "Discrete",
      any(str_detect(header_list[[1]]$X, "MultiState")) ~ "MultiState"
    )
    
    output$run_mode <- shinydashboard::renderInfoBox({
      shinydashboard::infoBox(value = run_mode,
                               title = "Model:",
                               icon = icon("cogs"),
                               color="olive", fill=TRUE)
    })
    
    #### INFO BOX: comparison mode
    
    if(length(header_list)==1) {
      comparison_mode<-"Single run"
    } else {
      header_df<-header_list %>%
        reduce(full_join, by="Options") 
      
      comparison_mode<-header_df  %>%
        filter(if_any(2:ncol(.), ~ .x != header_df[,2])) %>%
        filter(!Options %in% c("Log File Name","Seed", "Schedule File", "Iterations", "Cores")) %>%
        nrow()>0
      
      comparison_mode<-ifelse(comparison_mode, "Multi-run, different settings", "Multi-run, same settings")
    }
    
    
    output$comparison_mode <- shinydashboard::renderInfoBox({
      shinydashboard::infoBox(value = comparison_mode,
                              title = "Mode:",
                              icon = icon("not-equal"),
                              color="maroon", fill=TRUE)
    })
    
    #### INFO BOX: STONES
    
    output$stones <- shinydashboard::renderInfoBox({
          shinydashboard::infoBox(value = length(which((file_index()$filetype=="stones"))),
                                   title = "Stones:",
                                   icon = icon("link"),
                                   color="orange", fill=TRUE)
    })
    
    
    
  })
  
    #======================= 
    # Render log chains
  
  observeEvent(file_index(),{
    
    # extract mcmc
    
    tbl_mcmc<-read_chain(file_index=file_index() %>%
                           filter(filetype=="log"))
    
     output$chainPlot <- renderPlotly({
       
       # plot chain 
       gg_chain<-tbl_mcmc %>%
         ggplot(aes(x=Iteration, y=Lh, color=`Run ID`)) +
         geom_line(alpha=0.75) +
         scale_colour_manual(values=unname(run_colors)) +
         theme(legend.position = "none")
       
       # plotly-fy chain
       ggplotly(gg_chain) %>%
         layout(legend = list(orientation = "h", x = 0, y =-0.2))
       
       })

     output$violinPlot <- renderPlotly({
       
       # plot violins
       gg_violin<-tbl_mcmc %>%
         ggplot(aes(x=`Run ID`, y=Lh, color=`Run ID`, fill=`Run ID`)) +
         geom_violin(alpha=0.75) +
         labs(x="") +
         scale_colour_manual(values=unname(run_colors)) +
         scale_fill_manual(values=unname(run_colors)) +
         theme(legend.position = "none",
               axis.text.x = element_blank())
       
       # plotly-fy chain
       ggplotly(gg_violin)
       
     })
     
     
     
 })
  
  #=======================
  # Verify input
  observeEvent(file_index(),{
    
    output$file_check <- renderTable(colnames=F,
                                     striped=T,
                                     expr={
      
      expr=input_check(file_index=file_index())
      })
    
  })
  
  #=======================
  # declare fine-tune inputs
  
  user_burnin=reactive(input$burnin)
  downsample=reactive(input$downsample)
  abbrnames=reactive(input$abbrnames)
  
  #=======================
  # render Rmd report
  
  output$report <- downloadHandler(
    filename = "BayesTrace_report.html",
    
    content = function(f) {
      
      # have temporary loading modal
      showModal(modalDialog("Generating Report..", footer=NULL))
      on.exit(removeModal())
      
      # call bayestrace report file and pass the input file directory to it
      
      rmarkdown::render("bayestrace_report.Rmd", output_file = f,
                        params = list(file_index=file_index(),
                                      user_burnin=user_burnin(),
                                      downsample=downsample(),
                                      abbrnames=abbrnames(),
                                      shinyfy=TRUE),
                        envir = new.env(parent = globalenv())
      )
    }
  )

  
  
}

