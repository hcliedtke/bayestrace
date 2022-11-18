# Load required packages -------------------------------
library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(reactable)


# Load Helper files -------------------------------
source("~/Documents/GitHub/bayestrace/BayesTrace/functions/read_bt_log.r")
source("~/Documents/GitHub/bayestrace/BayesTrace/functions/read_bt_header.r")


# set working directory -------------------------------

setwd("~/Documents/GitHub/bayestrace/BayesTrace/test_data/")

# Load demo data -------------------------------

infolder<-"~/Documents/GitHub/bayestrace/BayesTrace/test_data/"

log_files<-list.files(path = infolder, pattern = ".Log.txt", full.names = TRUE)

log_list<-list()
for(i in 1:length(log_files)){
  log_list[[i]]<-read_tsv(log_files[i], skip=grep(pattern = "Iteration\\tLh", read_lines(log_files[i], n_max=Inf))-1, col_names = TRUE) %>%
    discard(~all(is.na(.)))
}

names(log_list)<-gsub(log_files, pattern=".*//(.*)\\.Log.txt", replacement = "\\1")

log_df<-bind_rows(log_list, .id="Run ID")

