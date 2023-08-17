setwd("./BayesTrace/")
examples_path=c("~/Documents/amphibian_diversity_project/2021/code_availability/Liedtke_et_al_Nat_Comm_2022/BayesTraits/anura/")
examples_path=c("./examples/Bird_covarion/")
examples_path=c("./examples/Primates_discrete/")
examples_path="examples/Artiodactyl_multistates_fossilised/"

###

test<-read.nexus("examples/Primates_discrete/Primates.trees")
test
phytools::writeNexus(test,"examples/Primates_discrete/Primates2.trees")

## style piecharts

library(ggplot2)
library(ggrepel)
library(tidyverse)


###
library(data.table)
data.table:::fread(log_paths[[i]], nrows = last_line-1,sep="")

gsub(x=read_lines(log_paths[[i]]), pattern="Discrete: ", replace="Discrete:-") %>%
  read.delim(header = T,nrows = last_line-1, sep="")

read.delim(log_paths[[i]],header = T,nrows = last_line-1, sep="")



### make interactive tree


p1 <- ggtree::ggtree(tre)

metat <- p1$data %>%
  dplyr::inner_join(tibble(id=tre$tip.label), c('label' = 'id'))

p2 <- p1 +
  geom_point(data = metat,
             aes(x = x,
                 y = y,
                 label = label))


ggplotly(p2, tooltip = "label")


####

library(phytools)
library(ggtree)
library(ggimage)
data(anoletree)
x <- getStates(anoletree,"tips")
tree <- anoletree

cols <- setNames(palette()[1:length(unique(x))],sort(unique(x)))
fitER <- ape::ace(x,tree,model="ER",type="discrete")
ancstats <- as.data.frame(fitER$lik.anc)
ancstats$node <- 1:tree$Nnode+Ntip(tree)

pies <- nodepie(ancstats, cols = 1:6)
pies <- lapply(pies, function(g) g+scale_fill_manual(values = cols))


tree2 <- full_join(tree, data.frame(label = names(x), stat = x ), by = 'label')
p <- ggtree(tree2) + geom_tiplab() +
  geom_tippoint(aes(color = stat)) + 
  scale_color_manual(values = cols) +
  theme(legend.position = "right") + 
  xlim(NA, 8)


p2 <- p + geom_inset(pies, width = .05, height = .05) 

p2

ggplotly(p2)

plot_list(p1, p2, guides='collect', tag_levels='A')