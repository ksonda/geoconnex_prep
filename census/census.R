#-----------------------------------------------------
# Title: Census
# Author: Kyle Onda (kyle.onda@duke.edu)
# Purpose: Prepare census boundary files
# for integration with geoconnex.us through
# landing content at info.geoconnex.us and
# PIDs at https://geoconnex.us
#-----------------------------------------------------


library(sf)
library(utils)
library(tidyverse)

#functions
get_census <- function()

# Download files

###Set URLs for files to download (may need to be updated annually to get current version)

#### base urls
base<-"https://www2.census.gov/geo/tiger/GENZ2019/shp/"
pid_base<-"https://geoconnex.us/ref/"

region<-c("region","cb_2019_us_region_500k")
division<-c("division","cb_2019_us_division_500k")
state<-c("state","cb_2019_us_state_500k")
county<-c("county", "cb_2019_us_county_500k")
aiannh<-c("aiannh","cb_2019_us_aiannh_500k")
cbsa<-c("cbsa","cb_2019_us_cbsa_500k")
ua10<-c("ua10","cb_2019_us_ua10_500k")

list<-list(region,division,state,county,aiannh,cbsa,ua10)


# regions 
for (i in list){
  temp <- tempfile()
  exdir=paste0(getwd(),"/",i[1])
  download.file(url=paste0(base,i[2],".zip"),temp)
  unzip(temp, exdir=exdir)
  file <- st_read(dsn=paste0(exdir,"/",i[2],".shp"),stringsAsFactors = FALSE)
  list.files(exdir)
  sapply(paste0(exdir,"/",list.files(exdir)),unlink)
  st_write(file,dsn=paste0(getwd(),"/",i[1],"/",i[1],".gpkg"))
}