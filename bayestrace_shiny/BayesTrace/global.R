# Load required packages -------------------------------
library(shiny)
library(shinydashboard)
library(shinyFiles)
library(tidyverse)
library(plotly)
library(reactable)

# set working directory -------------------------------

#setwd("~/Documents/git_projects/bayestrace/bayestrace_shiny/BayesTrace/")

dir<-"~/Documents/git_projects/bayestrace/bayestrace_shiny/BayesTrace/"


# ============================================
# generalized functions
read_log<-function(filePath){
  read_tsv(filePath,
           skip=grep(pattern = "Iteration\\tLh",
                     read_lines(filePath, n_max=Inf))-1,
           col_names = TRUE, na=c("",NA, "--")) %>%
    discard(~all(is.na(.))) #%>%
    #filter(row_number() %in% floor(seq(1, n(), length.out=1000)))
}