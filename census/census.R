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
library(pidsvcBackup)

#functions
#get_census <- function()

# Download files

###Set URLs for files to download (may need to be updated annually to get current version)

#### base urls
base<-"https://www2.census.gov/geo/tiger/GENZ2019/shp/"
pid_base<-"https://geoconnex.us/ref/"
landing_base<-"https://info.geoconnex.us/collections/"
creator<-"kyle.onda@duke.edu"

#region<-c("region","cb_2019_us_region_500k","GEOID")
#division<-c("division","cb_2019_us_division_500k","GEOID")
states<-c("states","cb_2019_us_state_500k","GEOID")
counties<-c("counties", "cb_2019_us_county_500k","GEOID")
aiannh<-c("aiannh","cb_2019_us_aiannh_500k","GEOID")
cbsa<-c("cbsa","cb_2019_us_cbsa_500k","GEOID")
ua10<-c("ua10","cb_2019_us_ua10_500k","GEOID10")
places<-c("places","cb_2019_us_place_500k","GEOID")

list<-list(states,counties,aiannh,cbsa,ua10,places)

batch_size=2000

for (i in list){
  
  # download, extract, read boundary files, delete shapefiles
  temp <- tempfile()
  exdir=paste0(getwd(),"/",i[1])
  download.file(url=paste0(base,i[2],".zip"),temp)
  unzip(temp, exdir=exdir)
  file <- st_read(dsn=paste0(exdir,"/",i[2],".shp"),stringsAsFactors = FALSE)
  list.files(exdir)
  sapply(paste0(exdir,"/",list.files(exdir)),unlink)
  
  # assign PIDs and write SQLiteGeoPackage files
  file$uri<-paste0(pid_base,i[1],"/",file[[i[3]]])
  file$ALAND<-NULL
  file$AWATER<-NULL
  if (i[1] %in% c("states", "counties", "places")){
    file$census_profile<-paste0("https://data.census.gov/cedsci/profile?g=",file$AFFGEOID)
  }
  st_write(file,dsn=paste0(getwd(),"/",i[1],"/",i[1],".gpkg"))
  
  # write csv
  data<-as.data.frame(file[c("uri")])
  data <- data%>%mutate(
    geometry = NULL,
    id = uri,
    uri = NULL,
    target = paste0(landing_base,i[1],"/items/",file[[i[3]]]),
    creator = creator,
    description = paste0("Census ",i[1]," reference geographies"),
    c1_type = "QueryString",
    c1_match = "f?=.*",
    c1_value = paste0(target,"?f=${C:f:1}"),
    grp = floor((row_number()-1)/batch_size)
  )
  
  
  
  data_split <- split(data, list(data$grp))
  data$grp<-NULL
  write_csv(data,path=paste0(i[1],"/",i[1],".csv"))
  
  for (grp in names(data_split)){
    
    d2<-data_split[[grp]]
    d2$grp<-NULL 
    write_csv(d2,path="temp.csv")
    write_xml(in_f="temp.csv", out_f="temp.xml", root="https://geoconnex.us")
    post_pids(in_f="temp.xml", user="iow", password="nieps", root="https://geoconnex.us")
    unlink("temp.csv")
    unlink("temp.xml")
  }

  #data$target<-paste0(landing_base,i[1],file)
}



