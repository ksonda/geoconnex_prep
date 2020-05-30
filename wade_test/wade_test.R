library(tidyverse)
library(sf)

#splits wade into many files

x<-st_read(dsn="wade_sites.geojson") # read master file

#convert ot character
x$uri<- as.character(x$uri)
x$StateID <- as.character(x$StateID)

#add link
x$LINK <- paste0("https://wade-api-qa.azure-api.net/v1/SiteAllocationAmounts?SiteUUID=",x$id)

# get list of States
states<-unique(x$StateID)

for (i in 1:length(states)) {
  temp <- x[which(x$StateID==states[i]),]
  file <- paste0("wade_",tolower(states[i]),".geojson")
  st_write(temp,dsn=file,append=FALSE)
}
