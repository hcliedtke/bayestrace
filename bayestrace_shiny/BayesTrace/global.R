# Load required packages -------------------------------
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyFiles)
library(tidyverse)
library(plotly)
library(reactable)
library(shinybusy)
library(shinyalert)

# ============================================
# generalized functions
read_log<-function(filePath, abbrev_length=20){
  
  ## read file names
  log_files<-list.files(filePath, pattern = "Log.txt")
  log_paths<-list.files(filePath, pattern = "Log.txt", full.names = TRUE)
  log_names<-str_remove_all(log_files, pattern="\\.Log\\.txt")
  log_names_abbr<-abbreviate(log_names,minlength=abbrev_length)
  
  # if only one log file
  if(length(log_files)==1){
    read_tsv(log_paths,
             skip=grep(pattern = "Iteration\\tLh", read_lines(log_paths, n_max=Inf))-1,
             col_names = TRUE,
             na=c("",NA, "--")) %>%
      discard(~all(is.na(.))) %>%
      mutate(`Run ID`=log_names_abbr)
  } else{
    # empty list
    chain_list<-list()
    
    for(i in 1:length(log_files)){
      chain_list[[i]]<-read_tsv(log_paths[i],
                                skip=grep(pattern = "Iteration\\tLh", read_lines(log_paths[i], n_max=Inf))-1,
                                col_names = TRUE,
                                na=c("",NA, "--")) %>%
        discard(~all(is.na(.)))
    }
    names(chain_list)<-log_names_abbr
    chain_df<-bind_rows(chain_list, .id="Run ID") # appends chains
    
    return(chain_df)
  }
  
  
}
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