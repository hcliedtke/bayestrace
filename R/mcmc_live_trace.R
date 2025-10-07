#' Run a live-updating MCMC trace from BayesTraits Log file
#'
#' @param file_path path, or vector of multiple paths to BayesTraits Log files
#' @param refresh_rate Refresh interval in milliseconds (default: 2000 ms)
#' @examples
#' mcmc_live_trace("./my_bayestraits_run.Log.txt")
#'
#'
mcmc_live_trace <- function(file_path, refresh_rate = 2000) {
  #library(shiny)
  #library(ggplot2)
  #library(readr)
  #library(dplyr)
  #library(bayestrace)

  ui <- fluidPage(
    titlePanel("Live MCMC Tracer"),
    p("Watching file:", strong(file_path)),
    plotOutput("live_plot", height = "500px"),
    tags$hr(),
    p(em("Plot updates automatically as the file changes."))
  )

  server <- function(input, output, session) {
    # Automatically re-read file every 'refresh_rate' ms
    live_data <- reactiveFileReader(
      intervalMillis = refresh_rate,
      session = session,
      filePath = file_path,
      readFunc = read_bt_log
    )

    output$live_plot <- renderPlot({
      df <- live_data()

      validate(need(nrow(df$chain) > 1, "Waiting for data..."))

      df$chain %>%
        ggplot(aes(x = Iteration, y = Lh)) +
        geom_line(color = "dodgerblue", linewidth = 1.2) +
        theme_minimal(base_size = 14) +
        labs(
          title = paste("Last updated:", Sys.time()),
          x = "Iterations", y = "Lh"
        )
    })
  }

  shinyApp(ui, server)
}
