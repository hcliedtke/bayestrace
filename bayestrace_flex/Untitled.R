## function to read BT Schedule files

### arguments:
# x: is the folder that contains one or more BayesTraits Schedule files. Schedule files must end with .Schedule.txt

### output:
#
x=dir_path

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
    
    ## get header info
    header_list[[i]]<-read_tsv(file = sched_paths[i], n_max = 2, skip = 1, col_names = FALSE) %>%
      deframe()
    ## 
    header_list[[i]]<-read_tsv(file = sched_paths[i], n_max = 2, skip = 1, col_names = FALSE) %>%
      deframe()
    
    
  }
  
  