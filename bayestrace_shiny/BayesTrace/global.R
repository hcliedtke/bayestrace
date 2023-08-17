# Load required packages -------------------------------
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(tidyverse)
library(plotly)
library(reactable)
library(shinyalert)
##flexdashboard libs
#library(knitr)
#library(flexdashboard)
#library(qgraph)
#library(coda)
#library(ape)
#library(RColorBrewer)
#library(visNetwork)

# ============================================
# Set themes  

# global themes
theme_set(theme_classic()+
            theme(
              # grid and axes
              axis.line=element_blank(),
              panel.grid.major.y = element_line(color = "grey95",size = 0.5),
              # facet strips
              strip.background = element_rect(color=NA, fill=NA),
              strip.text = element_text(hjust = 0, size=12))
)

# run colors
run_colors <- c(
  "1"   = "#727cf5",
  "2"    = "#0acf97",
  "3" = "#fa5c7c",
  "4"  = "#ffbc00",
  "5"   = "#2e4057",
  "6"   = "#8d96a3"
)

# ============================================
# function to read log file header. Takes path to files
source("functions/read_bt_header.R")

# ============================================
# function to check whether input is correct and if not, provide informative error messages

input_check<-function(file_index){
  
  file_index=file_index
  ### make empty list
  
  input_check<-list()
  
  ### check if log file exists
  input_check$logs=any(file_index$filetype=="log")
  
  ### check if schedule file exists
  input_check$schedule=any(file_index$filetype=="schedule")
  
  ### check that only one tree file has been uploaded
  input_check$trees=length(which(file_index$filetype=="tree"))==1
  
  ### check if all files in the log have been uploaded
  
  # read_header(file_path= file_index %>%
  #               filter(filetype=="log") %>%
  #                pull(filepath))
  
  
  
  ### check if run modes are different
  
  error_list<-list()
  
  if(!input_check$logs) error_list$logs <-  "No log files found. Are you sure you have uploaded at least one file with the extension .Log.txt?"
  
  if(!input_check$schedule) error_list$schedule <- "No schedule files found. Are you sure you have uploaded at least one file with the extension .Schedule.txt?"
  
  if(!input_check$trees) error_list$trees <- "No tree file found. Are you sure you have uploaded at least one file with the extension .trees, or .tre"
  
  
  ## enframe
  if(length(error_list)>0){
    errors<-error_list %>% 
      enframe()
  } else {
    errors<-data.frame(x="All files uploaded correctly")
  }
  
  return(errors)
  
}



# ============================================
# function to read chain from the log file
read_chain<-function(file_index){
  
  ## read file names
  log_files<-basename(file_index$filename)
  log_paths<-file.path(file_index$filepath)
  log_names<-str_remove_all(log_files, pattern="\\.Log\\.txt")
  
  # if only one log file
  if(length(log_files)==1){
    chain_df<-read_tsv(log_paths,
                       skip=grep(pattern = "Iteration\\tLh", read_lines(log_paths, n_max=Inf))-1,
                       col_names = TRUE,
                       na=c("",NA, "--")) %>%
      purrr::discard(~all(is.na(.))) %>%
      mutate(`Run ID`=log_names)
  } else{
    # empty list
    chain_list<-list()
    
    for(i in 1:length(log_files)){
      chain_list[[i]]<-read_tsv(log_paths[i],
                                skip=grep(pattern = "Iteration\\tLh",
                                          read_lines(log_paths[i], n_max=Inf))-1,
                                col_names = TRUE,
                                na=c("",NA, "--")) %>%
        purrr::discard(~all(is.na(.)))
    }
    names(chain_list)<-log_names
    chain_df<-bind_rows(chain_list, .id="Run ID") # appends chains
  }
  
  
  return(chain_df)
  
}


