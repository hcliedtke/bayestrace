server <- function(input,output,session){
  #======================
  # global server settings
  options(shiny.maxRequestSize=30*1024^2) 
  
  #======================
  #======================
  # Live Trace Tab
  #======================
  #======================
  
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
  # read user-specified file and update one file changes
  volumes = getVolumes()
  v = reactiveValues(path = NULL)
  
  observe({
    
      shinyFileChoose(input, "GetFile", roots = volumes, session = session)
      
      req(input$GetFile)
      file_selected <- parseFilePaths(volumes, input$GetFile)
      v$path <- as.character(file_selected$datapath)
      req(v$path)
      v$data <- reactiveFileReader(1000, session, filePath = v$path, readFun = read_log)
  })
  
  
  
  #======================= 
  # render plotly
  
  output$plotOne <- renderPlotly({
    req(v$data)
    if(is.null(v$data())){return ()}
    plot_ly(data=v$data(),
            x=~Iteration, y=~Lh,
            type = 'scatter',
            mode = 'lines')
  })
  
  #=======================
  # render input output
  #output$tableOne <- renderReactable({
  #  req(v$data)
  #  if(is.null(v$data())){return ()}
  #  v$data()
  #})
  
  #======================
  #======================
  # Reporting Tab
  #======================
  #======================
  
  
  #=======================
  # read user-specified BayesTraits directory
  volumes = getVolumes()
  shinyDirChoose(input, 'folder', roots=c(wd="../"), session=session)
  path1 <- reactive({
    return(print(parseDirPath(c(wd="../"), input$folder)))
  })
  output$dir <- renderText({
    list.files(path1())
  })
  

  
}

