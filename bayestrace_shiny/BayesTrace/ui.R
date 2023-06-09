ui <- fluidPage(style='padding:100px;',
                # use this in non shinydashboard app
                useShinydashboard(),
                # add busy spinner
                add_busy_spinner(spin = "orbit", position = "full-page"),
                ## 
                
                titlePanel(title=div(img(src="bt_logo3.png", height="50%", width="50%"), align="center")),
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         shinyDirButton(id='folder',
                                        label='Select BayesTraits Folder...',
                                        title="Please select a folder that contains the BayesTraits Output"),
                         downloadButton("report", "Generate report", class="btn-info"),
                         actionButton("help_btn", "Help!", class = "btn-warning")
                ),
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(p("Run characteristics")),
                         shinydashboard::valueBoxOutput(outputId = "value_n_logs",width=4),
                         shinydashboard::valueBox(icon = icon("not-equal"), width=4, color="maroon",
                                                  "Run Type", value="mixed"),
                         shinydashboard::valueBox(icon = icon("link"), width=4, color="orange",
                                                  "Stones", value="No")
                ),
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(p("Live trace of LogLikelihood will load here")),
                         plotlyOutput("plotTwo")
                )
)

