## function to read BT log files header

### arguments:
# file_path: is the path to a BayesTraits logfile (can be multiple)

### output:
# a list of tibbles for log header.

read_bt_header<-function(file_path){
  
  ### read log header
  header_list<-list()
  #log_paths<-list.files(path=dir_path, pattern="Log.txt", full.names = T)
  log_paths<-file_path
  #log_files<-basename(log_paths)
  
  for(i in 1:length(log_paths)){
    last_line=grep(pattern = "^\\s+|^\\t+", read_lines(log_paths[i], n_max=1000))[1]-2 # finds first line with a space or tab as the first character, then backtraces 2.
    
    header_list[[i]]<-read_lines(log_paths,skip = 1,
                                 n_max=last_line-1) %>%
      map_chr(~ .x %>% str_replace_all("^ +|^\t+| +$|\t$", "")) %>% # remove leading and trailing spaces
      map_chr(~ .x %>% str_replace_all("(:  )+|: - |:\t|\t", ";")) %>% # unify column delimiter
      map_chr(~ .x %>% str_replace_all("; +|;\t+| +;|\t;", ";")) %>% # remove leading and trailing spaces
      paste0(., "\n",collapse = "\n") %>%
      read_delim(delim=";", col_names = c("Options","X")) %>%
      purrr::discard(~all(is.na(.)))
  }  
  # return header list
  return(header_list)
  
  
}