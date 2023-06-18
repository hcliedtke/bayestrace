# Load required packages -------------------------------
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyFiles)
library(tidyverse)
library(plotly)
library(reactable)
library(shinyalert)

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
# function to read log file header

read_header<-function(dir_path){
  
  ### read log header
  header_list<-list()
  log_paths<-list.files(path=dir_path, pattern="Log.txt", full.names = T)
  log_files<-basename(log_paths)
  
  for(i in 1:length(log_files)){
    last_line=grep(pattern = "^\\s+|^\\t+", read_lines(log_paths[i], n_max=100))[1]-2 # finds first line with a space or tab as the first character, then backtraces 2.
    
    header_list[[i]]<-read.delim(log_paths[[i]],header = T,nrows = last_line-1, sep=":") %>%
      mutate(X=str_remove_all(X, " "))
  }  
    # return header list
    return(header_list)
    

}


# ============================================
# function to check whether input is correct and if not, provide informative error messages

input_check<-function(dir_path){
  ### check if log file exists
  
  ### check if run modes are different
  
}


# ============================================
# function to gather run info

get_run_info<-function(dir_path) {
  
  # make empty list
  run_info<-list()
  
  # read log header
  header_list<-read_header(dir_path=dir_path)
  
  ## count number of log files
  run_info$n_runs<-header_list %>% length()
  
  ## check if stones have been run
  run_info$stones<-list.files(path=dir_path, pattern="Stones.txt") %>% length() > 0
  
  ## check run mode
  run_info$mode<-case_when(
    any(str_detect(header_list[[1]]$X, "Discrete")) ~ "Discrete",
    any(str_detect(header_list[[1]]$X, "MultiState")) ~ "MultiState"
  )
  
  # return list
  return(run_info)
}


# ============================================
# function to read chain from the log file
read_chain<-function(filePath){
  
  ## read file names
  log_files<-basename(filePath)
  log_paths<-file.path(filePath)
  log_names<-str_remove_all(log_files, pattern="\\.Log\\.txt")
  
  # if only one log file
  if(length(log_files)==1){
    chain_df<-read_tsv(log_paths,
                       skip=grep(pattern = "Iteration\\tLh", read_lines(log_paths, n_max=Inf))-1,
                       col_names = TRUE,
                       na=c("",NA, "--")) %>%
      discard(~all(is.na(.))) %>%
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
        discard(~all(is.na(.)))
    }
    names(chain_list)<-log_names
    chain_df<-bind_rows(chain_list, .id="Run ID") # appends chains
  }
  
  
  return(chain_df)
  
}


