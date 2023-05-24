ui <- fluidPage(
  
  navbarPage("BayesTrace",
             
             tabPanel(title = "Live Trace",
                      sidebarLayout(
                        sidebarPanel(
                          
                          #fileInput("file1", "Choose log file"),#add red asterisks to make this mandatory
                          shinyFilesButton("GetFile", "Choose log file" ,
                                           title = "Please select a file:", multiple = FALSE,
                                           buttonType = "default", class = NULL), 
                          actionButton("stop", "Stop", class = "btn-danger")
                          
                        ), #-> closesidebarPanel
                        
                        mainPanel(
                          tabsetPanel(
                            tabPanel("Trace",
                                     plotlyOutput("plotOne")),
                            tabPanel("Data",
                                     tableOutput("tableOne")))
                          ) #-> close mainPanel
                        )   #-> close sidebarLayout  
             ), #-> close first tabPanel
             
            #================================================================ 
             # Tab 2
             
             tabPanel(title = "Generate Report",
                      mainPanel(
                        shinyDirButton('folder', 'Folder select', 'Please select a folder', FALSE)
                      ),
                      textOutput(outputId = "dir")
                      ) #-> close mainPanel)
  )  #-> close first NavBarPage
  
  
)
