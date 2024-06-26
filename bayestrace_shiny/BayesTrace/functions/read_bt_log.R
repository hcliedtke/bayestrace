## function to read BT log files

### arguments:
# x: is the folder that contains one or more BayesTraits log files. Log files must end with .Log.txt
# abbrev_length: number of characters to abbreviate run names (useful for neater visualization)

### output:
# a list object with different tibbles for each section of the log header.

read_bt_log<-function(x, abbrev_length=20){
  
  ### read log header
  header_list<-list()
  log_paths<-x
  log_names<-str_remove_all(names(x), pattern="\\.Log\\.txt")
  log_names_abbr<-abbreviate(log_names,minlength=abbrev_length)
  
  ## read file names
  #log_files<-list.files(x, pattern = "Log.txt")
  #log_paths<-list.files(x, pattern = "Log.txt", full.names = TRUE)
  #log_names<-str_remove_all(log_files, pattern="\\.Log\\.txt")
  #log_names_abbr<-abbreviate(log_names,minlength=abbrev_length)
  
  ## make empty lists
  header_list<-list()
  tags_list<-list()
  restrictions_list<-list()
  priors_list<-list()
  tree_list<-list()
  recon_list<-list()
  chain_list<-list()
  
  ## make internal function for reading subsections.
  
  tabulate_section<-function(log_paths,first_line, last_line, col_names) {
    
    read_lines(log_paths,
               skip=first_line,
               n_max=last_line-1) %>%
      map_chr(~ .x %>% str_replace_all("^ +|^\t+| +$|\t$", "")) %>% # remove leading and trailing spaces
      map_chr(~ .x %>% str_replace_all("(:  )+|: - |:\t|\t|(  )+", ";")) %>% # unify column delimiter
      map_chr(~ .x %>% str_replace_all("; +|;\t+| +;|\t;", ";")) %>% # remove leading and trailing spaces
      map_chr(~ .x %>% str_replace_all(";+", ";")) %>% # remove duplicated column breaks
      paste0(., "\n",collapse = "\n") %>%
      read_delim(delim=";",col_names = col_names) %>%
      purrr::discard(~all(is.na(.)))
  }
  
  for(i in 1:length(log_paths)){
    
  ## get headers
    first_line=1
    last_line=grep(pattern = "^\\s+|^\\t+", read_lines(log_paths[i], n_max=100))[1]-2 # finds first line with a space or tab as the first character, then backtraces 2.
    
    header_list[[i]]<-tabulate_section(log_paths[i], first_line, last_line, col_names=c("Options",log_names_abbr[i]))  
  
    
  ## get tags
    first_line=grep(pattern = "Tags:", read_lines(log_paths[i], n_max=100))
    if(length(first_line)>0) {

      last_line=grep(pattern = "^\\w+", read_lines(log_paths[i], skip = first_line, n_max=100))[1]
    
      tags_list[[i]]<-tabulate_section(log_paths[i], first_line, last_line,
                                       col_names=c("Tag","n","Species")) %>%
        mutate(`Run ID`=log_names_abbr[i])
    }
    
  ## get restrictions
    first_line=grep(pattern = "Restrictions:", read_lines(log_paths[i], n_max=Inf))
    
    if(length(first_line)>0) {
      last_line=grep(pattern = "^\\w+", read_lines(log_paths[i], skip = first_line, n_max=100))[1]
      
      restrictions_list[[i]]<-tabulate_section(log_paths[i], first_line, last_line,
                                               col_names=c("Transition",log_names_abbr[i]))
    }
  
    ## get priors
    first_line=grep(pattern = "Prior Information:", read_lines(log_paths[i], n_max=Inf))
    
    if(length(first_line)>0) {
      last_line=grep(pattern = "^\\w+", read_lines(log_paths[i], skip = first_line, n_max=100))[1]
      
      priors_list[[i]]<-tabulate_section(log_paths[i], first_line, last_line,
                                         col_names=c("Transitions",log_names_abbr[i])) %>%
        drop_na()
    }

    
    
    
    ## get tree info
    first_line=grep(pattern = "Tree Information", read_lines(log_paths[i], n_max=Inf))
    
    if(length(first_line)>0) {
      last_line=grep(pattern = "^\\w+", read_lines(log_paths[i], skip = first_line, n_max=100))[1]
      
      tree_list[[i]]<- tabulate_section(log_paths[i], first_line, last_line,
                                        col_names=c("Parameter",log_names_abbr[i]))
    }
      
    ## get reconstruction/fossilisation info
    
    first_line=grep(pattern = "Node reconstruction / fossilisation:", read_lines(log_paths[i], n_max=Inf))
    
    if(length(first_line)>0) {
      last_line=grep(pattern = "^\\w+", read_lines(log_paths[i], skip = first_line, n_max=100))[1]
      
      recon_list[[i]]<- tabulate_section(log_paths[i], first_line, last_line,
                                        col_names=c("Parameter",log_names_abbr[i])) %>%
        separate(Parameter,into=c("node", "Node", "Tag"), sep=" ") %>%
        select(-node)
    }
    
    
    ## get chain info
    chain_list[[i]]<-read_tsv(log_paths[i],
                              skip=grep(pattern = "Iteration\\tLh", read_lines(log_paths[i], n_max=Inf))-1,
                              col_names = TRUE,
                              na=c("",NA, "--")) %>%
      purrr::discard(~all(is.na(.)))
    
    # re-define columns for discrete:independent model
    if(all( c("alpha1","alpha2", "beta1","beta2") %in% colnames(chain_list[[i]]))){
      chain_list[[i]]<-chain_list[[i]] %>%
        mutate(q12=alpha2,
               q13=alpha1,
               q21=beta2,
               q24=alpha1,
               q31=beta1,
               q34=alpha2,
               q42=beta1,
               q43=beta2) %>%
        select(-starts_with(c("alpha","beta")))
    }
    
    
  }

  
    
  
  ## add file names to chains and bind rows into a single df
  names(chain_list)<-log_names_abbr
  chain_df<-bind_rows(chain_list, .id="Run ID") # appends chains

  
  ### Join section lists into a single df
  header_df<-header_list %>% reduce(full_join, by="Options")  
  restrictions_df<-restrictions_list %>% reduce(full_join, by="Transition")
  priors_df<- priors_list %>% reduce(full_join, by="Transitions")
  tree_df<-tree_list %>% reduce(full_join,by="Parameter")
  if(length(tags_list)>0) {
    tags_df<-bind_rows(tags_list) %>%
      pivot_wider(names_from = `Run ID`, values_from=`Run ID`,values_fn = ~ 1)
  }
  if(length(recon_list)>0) recon_df<-recon_list %>% reduce(full_join, by=c("Node","Tag"))
  
  #### return as list object
  df_list<-list("header"=header_df,
       "restrictions"=restrictions_df,
       "priors"=priors_df,
       "tree"=tree_df,
       "chain"=chain_df)
  
  # append optional ones
  if(length(tags_list)>0) {
    df_list<-append(df_list, list("tags"=tags_df))
  }
  if(length(recon_list)>0) {
    df_list<-append(df_list, list("recon"=recon_df))
  }
       
  return(df_list)
}

