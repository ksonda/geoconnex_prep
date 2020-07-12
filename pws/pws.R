
library(httr)
library(utils)
library(tidyverse)
library(pidsvcBackup)


download.file("https://echo.epa.gov/files/echodownloads/SDWA_downloads.zip","SDWA.zip")


d <- read_csv("data/SDWA_PUB_WATER_SYSTEMS.csv.zip")%>%
        group_by(PWSID)%>%
        filter(FISCAL_YEAR==max(FISCAL_YEAR))
        View(d)



pids <- d%>%
          mutate(id=paste0(root,PWSID),
                  target=paste("https://enviro.epa.gov/enviro/sdw_report_v3.first_table?pws_id=",
                  PWSID,
                  "&state=",
                  STATE_CODE,
                  "&source=",
                  SOURCE_WATER,
                  "&population=",
                  POPULATION_SERVED_COUNT),
                  creator="kyle.onda@duke.edu",
                  description="Public Water Systems",
                  c1_type=NA,
                  c1_match=NA,
                  c1_value=NA)%>%
          select(id,target,creator,description,c1_type,c1_match,c1_value)


states<-st_read("https://info.geoconnex.us/collections/states/items?limit=100&f=json",stringsAsFactors=FALSE)

ca_shp <- "https://opendata.arcgis.com/datasets/fbba842bf134497c9d611ad506ec48cc_0.zip"
download.file(ca_shp, "data/ca.zip")
unzip("ca.zip")
ca <- st_read("ca.shp")
unzip("ca.zip","ca_shp")
?unzip
unzip("ca.zip",exdir="ca_shp")
ca <- st_read("ca_shp/ca.shp")
ca <- st_read("ca_shp/DDW_SABL_dev.shp")
ca
View(ca)
unzip("TX_PWS.zip",exdir="TX_shp")
tx <- st_read("TX_shp/PWS_Export.shp")
pa<-st_read("http://www.pasda.psu.edu/json/PublicWaterSupply2020_04.geojson")
download.file("http://www.pasda.psu.edu/json/PublicWaterSupply2020_04.geojson", "pa.geojson")
pa<-st_read("pa.geojson")
