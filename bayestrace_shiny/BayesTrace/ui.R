dashboardPage(skin = "black",
  dashboardHeader(title = "BayesTrace"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Input",tabName = "input", icon = icon("pen"),
               fileInput(inputId = "log_file1",label = "Select one or multiple BT log files", multiple = TRUE)),
      menuItem("Run Info",tabName = "runinfo", icon = icon("document")),
      menuItem("MCMC Trace", tabName = "MCMCtrace", icon = icon("tachometer-alt")),
      menuItem("Rates", tabName = "rates", icon = icon("chart-pie")),
      menuItem("Log", tabName = "log", icon = icon("table"))
    )
  ),
  dashboardBody(
  
    
    tabItems(
      
      # input tab content
      tabItem(tabName = "runinfo",
              h2("BayesTraits Log file output"),
              fluidRow(
                box(width = 8,
                    reactableOutput("btHeader"))
              )
              
      ),
      
      # Trace tab content
      tabItem(tabName = "MCMCtrace",
              h2("MCMC traces"),
              fluidRow(
                box(width = 8,
                    plotlyOutput("LhTrace")),
                box(width = 4,
                    plotlyOutput("LhDensity"))
              )
              
      ),
      # rates tab content
      tabItem(tabName = "rates",
              h2("Rates and States"),
              fluidRow(
                box(width = 6,
                    plotlyOutput("RootState")),
                box(width = 6,
                    plotlyOutput("StateDensity"))
              )
              
              ),
      # Log tab content
      tabItem(tabName = "log",
              h2("BT log table"),
              fluidRow(
                box(width = 8,
                    tableOutput("logtable")))
    ))
    
    
  )
)