file_path<-c("../bayestrace_shiny/BayesTrace/examples/Bird_covarion/BirdTerritory_covarionOFF_run2.Stones.txt","../bayestrace_shiny/BayesTrace/examples/Bird_covarion/BirdTerritory_covarionON_run1.Stones.txt")

log_path=c("../bayestrace_shiny/BayesTrace/examples/Artiodactyl_multistates_anc_states/Artiodactyl_multistate_run1.Schedule.txt")

test<-read_bt_log(file_path)
test

test<-read_bt_stones(file_path)

str(test)


test$header
test$stones
test$`marginal likelihood`


render_bayestrace(file_path = "/Users/christophliedtke/Documents/git_projects/bayestrace/bayestrace_shiny/BayesTrace/examples/Artiodactyl_multistates_anc_states")

setwd("~/Desktop/")
getwd()
