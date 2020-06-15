#-----------------------------------------------------
# Title: CUAHSI
# Author: Kyle Onda (kyle.onda@duke.edu)
# Purpose: Post CUAHSI HIS PIDs to geoconnex.us PIDsvc
#-----------------------------------------------------


#### Load required packages and functions ####
library(utils)
library(httr)
library(xml2)
library(tidyverse)
source("../functions/make_mapping.R")
source("../functions/write_xml.R")
source("../functions/post_pids.R")
batch_size=2000

####   ####

list<-list.files(path="his",full.names = TRUE)

for (i in list){
  file <- read_csv(i) %>% mutate(batch = floor((row_number()-1)/batch_size))
  data_split <- split(file, list(file$batch))
#  data_split$batch <- NULL
  for (batch in names(data_split)){
     
   d2<-data_split[[batch]]
   d2$batch<-NULL 
   write_csv(d2,path="temp.csv")
   write_xml(in_f="temp.csv", out_f="temp.xml", root="https://geoconnex.us")
   post_pids(in_f="temp.xml", user="user", password="password", root="https://geoconnex.us")
   unlink("temp.csv")
   unlink("temp.xml")
 }
  
}
