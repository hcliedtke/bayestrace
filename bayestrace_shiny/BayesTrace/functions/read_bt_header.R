# Function to get the header info from a BT log file

### arguments:
# x: is the inputFile output for one or multiple selected BayesTraits log files.

read_bt_header<-function(x){
  
  
  log_names<-str_remove_all(x$name, pattern="\\.Log\\.txt")
  
  header_list<-list()
  for(i in 1:length(x$datapath)){
    header_list[[i]]<-read_tsv(x$datapath[i],n_max=grep(pattern = "Iteration\\tLh", read_lines(x$datapath[i], n_max=Inf))-1, col_names = TRUE) %>%
      separate(`Options:`, c("Options",log_names[i]),sep=":\\s+")
  }
  
  return(Reduce(full_join,header_list))
  
}

