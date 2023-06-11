server <- function(input,output,session){
  #======================
  # global server settings
  options(shiny.maxRequestSize=30*1024^2) 
  
  #======================
  # read in user-specified file
## data <- reactive({
##   req(input$file1)
##   file_path<-input$file1$datapath
##   #file_path<-file1$datapath
##   if(is.null(input$file1)){return()}
##   read_tsv(file_path,
##            skip=grep(pattern = "Iteration\\tLh",
##                      read_lines(file_path, n_max=Inf))-1,
##            col_names = TRUE, na=c("",NA, "--")) %>%
##     discard(~all(is.na(.))) %>%
##     filter(row_number() %in% floor(seq(1, n(), length.out=1000)))
# })
  
  #=======================
  # help button
  observeEvent(input$help_btn, {
    # Show a simple modal
    shinyalert(title="Getting Started", type="info",
    text = "To get started, select a folder that contains your BayesTraits output files. The folder should contain the following:
    - a log file (.Log.txt)
    - a shedule file (.Shedule.txt)
    - a tree file (.trees)
    
    For any issues, drop me a line here: <url>"
    
    )
  })

##  #=======================
##  # read user-specified mcmc chain file and update on file changes
##  volumes = getVolumes()
##  v = reactiveValues(path = NULL)
##  
##  observe({
##    
##      shinyFileChoose(input, "GetFile", roots = volumes, session = session)
##      
##      req(input$GetFile)
##      file_selected <- parseFilePaths(volumes, input$GetFile)
##      v$path <- as.character(file_selected$datapath)
##      req(v$path)
##      v$data <- reactiveFileReader(1000, session, filePath = v$path, readFun = read_log)
##  })
##  
##  
##  
##  #======================= 
##  # render plotly
##  
##  output$plotOne <- renderPlotly({
##    req(v$data)
##    if(is.null(v$data())){return ()}
##    plot_ly(data=v$data(),
##            x=~Iteration, y=~Lh,
##            type = 'scatter',
##            mode = 'lines')
##  })
##  
 
  #=======================
  # read user-specified BayesTraits directory

  home <- normalizePath("../")
  home <- c('home' = home) 
  
  shinyDirChoose(input, 'folder', roots = home)
  
  path <- reactive({
    parseDirPath(roots = home, input$folder)
  })
  
  # check path is correct
  #output$fileReaderText <- renderText({
  # file.path(path(),
  #  list.files(path=path(), pattern="Log.txt"))
  #  })
  
  reac <- reactiveValues()
  
  observeEvent(path(), {
   log_filename <- list.files(path=path(), pattern="Log.txt")
    
    req(length(file.exists(file.path(path(), log_filename))) > 0)
    if(file.exists(file.path(path(), log_filename))) {
      
      #for(i in 1:length())
      fileReaderData <- reactiveFileReader(1000,
                                           session,
                                           filePath = file.path(path(), log_filename),
                                           readFun = read_log)
      
      #======================= 
      # render plotly
      
      output$chainPlot <- renderPlotly({
        req(fileReaderData())
        if(is.null(fileReaderData())){return()}
        
        
        gg_chain<-fileReaderData() %>%
          as_tibble() %>%
          ggplot(aes(x=Iteration, y=Lh, color=`Run ID`)) +
          geom_line(alpha=0.75) +
          scale_colour_manual(values=unname(run_colors)) +
          theme(legend.position = "None")
        
        # plotly-fy
        ggplotly(gg_chain) %>%
          layout(legend = list(orientation = "h", x = 0, y =-0.2))
        })
      }
      
  })
  
  
  #=======================
  # gather data to generate value boxes
  
  n_logs <- reactive({
    if (is.null(input$folder)) return(NULL)
    list.files(path=path(), pattern="Log.txt") %>% length()
  })

  output$value_n_logs <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(value = n_logs(),
                             subtitle = "Log files found:",
                             icon = icon("clipboard"),
                             color="teal")
  })
  
  
  
  #=======================
  # render Rmd report
  
  output$report <- downloadHandler(
    filename = "report.html",
    
    content = function(f) {
      
      # have temporary loading modal
      showModal(modalDialog("Generating Report..", footer=NULL))
      on.exit(removeModal())
      
      # call bayestrace report file and pass the input file directory to it
      
      rmarkdown::render("bayestrace_report.Rmd", output_file = f,
                        params = list(dir_path=path()),
                        envir = new.env(parent = globalenv())
      )
    }
  )

  
  
}

