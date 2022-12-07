## function to read BT Schedule files

### arguments:
# x: is the folder that contains one or more BayesTraits Schedule files. Schedule files must end with .Schedule.txt

### output:
# a list containing acceptance rate information


read_bt_schedule<-function(x){
  
  ## read file names
  sched_files<-list.files(x, pattern = "Schedule.txt")
  sched_paths<-list.files(x, pattern = "Schedule.txt", full.names = TRUE)
  sched_names<-str_remove_all(sched_files, pattern="\\.Schedule\\.txt")
  
  ## make empty lists
  header_list<-list()
  schedule_list<-list()

  ##
  for(i in 1:length(sched_files)){
    
    ## find 1st line of table
    first_line=grep(pattern = "^Rate Tried", read_lines(sched_paths[i], n_max=20))-1
    
    ## get header info
    header_list[[i]]<-read_tsv(file = sched_paths[i], n_max = first_line-1, skip = 1, col_names = FALSE) %>%
      deframe()
    ## 
    schedule_list[[i]]<-read_tsv(file = sched_paths[i], skip = first_line, col_names = TRUE) %>%
      select(-starts_with("..."))
  }
  
  ## add file names to chains and bind rows into a single df
  names(header_list)<-sched_names
  header_df<-bind_rows(header_list, .id="Run ID")
  
  names(schedule_list)<-sched_names
  schedule_df<-bind_rows(schedule_list, .id="Run ID")
  
  
  # function output
  return(list(header=header_df,
              schedule=schedule_df))
  
}
  
  