ui <- fluidPage(style='padding:100px;',
                # app title
                title = "BayesTrace",
                # use this in non-shinydashboard apps to get e.g. valueboxes
                useShinydashboard(),
                ## 
                
                titlePanel(title=div(img(src="bt_logo3.png", height="50%", width="50%"), align="center")),
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Process BayesTraits output")),
                         shinyDirButton(id='folder',
                                        label='Select BayesTraits Folder...',
                                        title="Please select a folder that contains the BayesTraits Output"),
                         downloadButton("report", "Generate report", class="btn-info"),
                         actionButton("help_btn", "Help!", class = "btn-warning")
                ),
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Run Characteristics")),
                         shinydashboard::valueBoxOutput(outputId = "value_n_logs",width=4),
                         shinydashboard::valueBoxOutput(outputId = "run_mode", width = 4),
                         shinydashboard::valueBoxOutput(outputId = "stones", width = 4)
                ),
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Live MCMC trace")),
                         plotlyOutput("chainPlot")
                ),
                fluidRow(
                  div(
                      p(style="text-align:center",
                        "Copyright (c) 2023 H. Christoph Liedtke. All rights reserved.This work is licensed under the terms of the ",tags$a(
                          "MIT license",
                          target = "_blank",
                          href = "https://opensource.org/licenses/MIT")),
                      p(style="text-align:center",
                        "For more information and to post bugs, use the ",
                        tags$a(
                          "GitHub Page",
                          target = "_blank",
                          href = "https://github.com/hcliedtke/bayestrace"))
                      )
                )
                      
                         
)

