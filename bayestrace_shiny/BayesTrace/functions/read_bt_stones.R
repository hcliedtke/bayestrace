## function to read BT Stones files

### arguments:
# x: is the folder that contains one or more BayesTraits Stones files. Stones files must end with .Stones.txt

### output:
# a list containing acceptance rate information


read_bt_stones<-function(x,abbrev_length=20){
  
  ## read file names
  stones_paths<-x
  stones_names<-str_remove_all(names(x), pattern="\\.Stones\\.txt")
  stones_names_abbr<-abbreviate(stones_names,minlength=abbrev_length)
  
  
  ## make empty lists
  header_list<-list()
  stones_list<-list()
  marLik_list<-list()
  
  ##
  for(i in 1:length(stones_paths)){
    
    ## find 1st line of table
    first_line=grep(pattern = "^Stone No", read_lines(stones_paths[i], n_max=20))-1
    
    ## find last line of table
    last_line=grep(pattern = "Log marginal likelihood", read_lines(stones_paths[i]))-1
    
    ## get header info
    header_list[[i]]<-read_lines(stones_paths,
                                 skip = 1,
                                 n_max=first_line-1) %>%
      map_chr(~ .x %>% str_replace_all("^ +|^\t+| +$|\t$", "")) %>% # remove leading and trailing spaces
      map_chr(~ .x %>% str_replace_all("(:  )+|: - |:\t", ";")) %>% # unify column delimiter
      map_chr(~ .x %>% str_replace_all("; +|;\t+| +;|\t;", ";")) %>% # remove leading and trailing spaces
      paste0(., "\n",collapse = "\n") %>%
      read_delim(delim=";",
                 col_names = c("Parameters",stones_names_abbr[i])) %>%
      purrr::discard(~all(is.na(.)))
    
    ## get stones iterations
    stones_list[[i]]<-read_tsv(file = stones_paths[i],
                               skip = first_line,
                               n_max = last_line-(first_line+1),
                               col_names = TRUE)
    
    ## get marginal likelihood
    marLik_list[[i]]<-read_tsv(file = stones_paths[i],
                                 skip = last_line,
                               col_names = c("marLik",stones_names_abbr[i]))
    
  }
  
  ### Join header lists into a single df
  header_df<-header_list %>%
    reduce(full_join, by="Parameters") %>%
    distinct()
  
  ### Join marginal likelihood lists into a single df
  marLik_df<-marLik_list %>%
    reduce(full_join, by="marLik") %>%
    distinct()
  
  ### concatenate stones list into a single df 
  names(stones_list)<-stones_names_abbr
  stones_df<-bind_rows(stones_list, .id="Run ID")
  
  
  # function output
  return(list(header=header_df,
              stones=stones_df,
              `marginal likelihood`=marLik_df))

}

