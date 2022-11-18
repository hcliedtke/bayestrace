## function to read BT log files

### arguments:
# x: is the fileInput object for one or more BayesTraits log files. Log files must end with .Log.txt

read_bt_log<-function(x){
  
  log_names<-str_remove_all(x$name, pattern="\\.Log\\.txt")
  
  log_list<-list()
  for(i in 1:length(x$datapath)){
    log_list[[i]]<-read_tsv(x$datapath[i], skip=grep(pattern = "Iteration\\tLh", read_lines(x$datapath[i], n_max=Inf))-1, col_names = TRUE) %>%
    discard(~all(is.na(.)))
  }
  
  names(log_list)<-log_names

  log_df<-bind_rows(log_list, .id="Run ID")
  
  return(log_df)
}

