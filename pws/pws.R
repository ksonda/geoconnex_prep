
library(httr)
library(utils)
library(tidyverse)
library(pidsvcBackup)
library(sf)

root <- "https://geoconnex.us/ref/pws/"


### Download SDWIS list
download.file("https://echo.epa.gov/files/echodownloads/SDWA_downloads.zip","SDWA.zip")

## Download state boundaries
states <- st_read("../census/states/states.gpkg")
states <- st_transform(states, 4326)
places <- st_read("../census/places/places.gpkg")
ai <- st_read("../census/aiannh/aiannh.gpkg")
## Make PIDS


d <- read_csv("data/SDWA_PUB_WATER_SYSTEMS.csv.zip")%>%
        group_by(PWSID)%>%
        filter(FISCAL_YEAR==max(FISCAL_YEAR))%>%ungroup()



pids <- d%>%
          mutate(id=paste0(root,PWSID),
                 target=paste0("https://info.geoconnex.us/collections/pws/items/",
                              PWSID),
                 creator="kyle.onda@duke.edu",
                 description="Public Water Systems",
                 c1_type="QueryString",
                 c1_match="f=.*",
                 c1_value=paste0(target,"?f=${C:f:1}"))%>%
          select(id,target,creator,description,c1_type,c1_match,c1_value)


## Make Gpkg
## If there are boundaries, use them, if not, use state boundaries
pws_sf_strip<-function(sf){
  sf <- select(sf,PWSID,NAME,ST,url,PROVIDER)
  return(sf)

}

## CA
ca_shp <- "https://opendata.arcgis.com/datasets/fbba842bf134497c9d611ad506ec48cc_0.zip"
download.file(ca_shp, "data/ca.zip")
unzip("data/ca.zip",exdir="data/ca_shp")
ca <- st_read("data/ca_shp/DDW_SABL_dev.shp")
ca <- ca %>% select(PWSID,NAME)
ca$PROVIDER = "https://gis.data.ca.gov/datasets/waterboards::california-drinking-water-system-area-boundaries"
ca$url = ""
ca$ST="CA"
ca <- pws_sf_strip(ca)

## NC
nc <- st_read("data/NC_statewide_CWS_areas.gpkg")
nc <- st_transform(nc,4326)
nc$PWSID <- gsub("-","",nc$PWSID)
nc$PWSID <- paste0("NC",nc$PWSID)
nc$NAME <- nc$SystemName
nc <- select(nc,PWSID,NAME)
nc$PROVIDER = "https://about-us.internetofwater.dev"
nc$url = ""
nc$ST="NC"
nc<-pws_sf_strip(nc)
nc$geometry:sfc_MULTIPOLYGON <- nc$`geom :sfc_MULTIPOLYGON`
nc$geom<-NULL

#st_write(nc,dsn="data/NC_PWS_2019.geojson")

## PA
download.file("http://www.pasda.psu.edu/json/PublicWaterSupply2020_04.geojson", "data/pa.geojson")
pa<-st_read("data/pa.geojson")
pa$PWSID<-paste0("PA",pa$PWS_ID)
pa$PROVIDER = "http://www.pasda.psu.edu/uci/DataSummary.aspx?dataset=1090"
pa$url=""
pa$ST="PA"
pa<-pws_sf_strip(pa)

## NJ
download.file("https://opendata.arcgis.com/datasets/00e7ff046ddb4302abe7b49b2ddee07e_13.zip","data/nj.zip")
unzip("data/nj.zip",exdir="data/nj_shp")
nj <- st_read("data/nj_shp/Purveyor_Service_Areas_of_New_Jersey.shp")
nj$PROVIDER = "https://njogis-newjersey.opendata.arcgis.com/datasets/00e7ff046ddb4302abe7b49b2ddee07e_13"
nj$PWSID = nj$PWID
nj$url = nj$AGENCY_URL
nj$ST="NJ"
nj$NAME=nj$SYS_NAME
nj<-pws_sf_strip(nj)

## TX
unzip("TX_PWS.zip",exdir="data/TX_PWS")
tx <- st_read("data/TX_PWS/PWS_Export.shp")
tx <- st_transform(tx, 4326)
tx$PWSID = tx$PWSId
tx$NAME = tx$pwsName
tx$PROVIDER = "https://www3.twdb.texas.gov/apps/WaterServiceBoundaries"
tx$url=""
tx$ST="TX"
tx<-pws_sf_strip(tx)


boundaries<-bind_rows(ca,nc,nj,pa,tx)

## Assign state polygon if no boundary
d$SOURCE_WATER[which(d$SOURCE_WATER=="GW")]<-"Ground water"
d$SOURCE_WATER[which(d$SOURCE_WATER=="SW")]<-"Surface water"

pws <- d%>%
          mutate(uri=paste0(root,PWSID),
                  SDWIS=paste0("https://enviro.epa.gov/enviro/sdw_report_v3.first_table?pws_id=",
                  PWSID,
                  "&state=",
                  STATE_CODE,
                  "&source=",
                  SOURCE_WATER,
                  "&population=",
                  POPULATION_SERVED_COUNT))

states$ST_uri = states$uri
states<-select(states,ST_uri,STUSPS)
states$geometry<-states$geom
states$geom<-NULL
st_uri<-states
st_uri$geom<-NULL
st_uri$geometry<-NULL

pws_boundary <- left_join(boundaries,pws,by="PWSID",add=TRUE)
pws_boundary <- left_join(pws_boundary,st_uri,by=c("ST"="STUSPS"))
pws_boundary$BOUNDARY_TYPE="Service Area Boundary"

pws_state <- anti_join(pws,boundaries,by="PWSID")
pws_state <- left_join(states,pws_state,by=c("STUSPS"="STATE_CODE"))
pws_state$BOUNDARY_TYPE="Unknown Service Area - Using State Boundary to Represent PWS"



PWS <- bind_rows(pws_boundary,pws_state)
PWS <- select(PWS,PWSID,NAME,BOUNDARY_TYPE,CITY_SERVED,STATE_CODE,ST_uri,SDWIS,uri)

st_write(PWS,dsn="out/pws.gpkg")
write_csv(pids,"out/pws.csv")
