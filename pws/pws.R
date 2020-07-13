
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
#ca_shp <- "https://opendata.arcgis.com/datasets/fbba842bf134497c9d611ad506ec48cc_0.zip"
#download.file(ca_shp, "data/ca.zip")
#unzip("data/ca.zip",exdir="data/ca_shp")
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
#nc$geometry <- nc$geom
#nc$geom<-NULL

#st_write(nc,dsn="data/NC_PWS_2019.geojson")

## PA
#download.file("http://www.pasda.psu.edu/json/PublicWaterSupply2020_04.geojson", "data/pa.geojson")
pa<-st_read("data/pa.geojson")
pa$PWSID<-paste0("PA",pa$PWS_ID)
pa$PROVIDER = "http://www.pasda.psu.edu/uci/DataSummary.aspx?dataset=1090"
pa$url=""
pa$ST="PA"
pa<-pws_sf_strip(pa)

## NJ
#download.file("https://opendata.arcgis.com/datasets/00e7ff046ddb4302abe7b49b2ddee07e_13.zip","data/nj.zip")
#unzip("data/nj.zip",exdir="data/nj_shp")
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

nc2<-st_read("nc.geojson")
boundaries<-rbind(ca,nc2,nj,pa,tx)

## Assign state polygon if no boundary
d$SOURCE_WATER[which(d$SOURCE_WATER=="GW")]<-"Ground water"
d$SOURCE_WATER[which(d$SOURCE_WATER=="SW")]<-"Surface water"

pws <- d%>%
          mutate(uri=paste0(root,PWSID),
                  SDWIS=URLencode(paste0("https://enviro.epa.gov/enviro/sdw_report_v3.first_table?pws_id=",
                  PWSID,
                  "&state=",
                  STATE_CODE,
                  "&source=",
                  SOURCE_WATER,
                  "&population=",
                  POPULATION_SERVED_COUNT)))

states$ST_uri = states$uri
states<-select(states,ST_uri,STUSPS)
st_write(states,dsn="states.geojson",append=FALSE)
states<-st_read("states.geojson")
st_geometry(states)<-st_geometry(st_centroid(states))
states<-distinct(states,.keep_all=TRUE)
#states$geometry<-states$geom
st_uri<-states
st_uri$geom<-NULL
st_uri$geometry<-NULL

pws_boundary <- left_join(boundaries,pws,by="PWSID",add=TRUE)
pws_boundary <- left_join(pws_boundary,st_uri,by=c("ST"="STUSPS"))
pws_boundary$BOUNDARY_TYPE="Service Area Boundary"




pws_state <- anti_join(pws,boundaries,by="PWSID")
pws_state <- left_join(states,pws_state,by=c("STUSPS"="STATE_CODE"))
pws_state$BOUNDARY_TYPE="Unknown Service Area or City - Using State Boundary to Represent PWS"


#st_geometry(pws_state)<-st_geometry(st_centroid(pws_state))
PWS <- bind_rows(pws_boundary,pws_state)
PWS$ST[which(is.na(PWS$ST))] = PWS$STUSPS[which(is.na(PWS$ST))]


PWS<- PWS%>%mutate(SDWIS=URLencode(paste0("https://enviro.epa.gov/enviro/sdw_report_v3.first_table?pws_id=",
                       PWSID,
                       "&state=",
                       ST,
                       "&source=",
                       SOURCE_WATER,
                       "&population=",
                       POPULATION_SERVED_COUNT)))
                   
                   
PWS <- select(PWS,PWSID,NAME,BOUNDARY_TYPE,CITY_SERVED,ST,ST_uri,SDWIS,PROVIDER,POPULATION_SERVED_COUNT,SYSTEM_SIZE,uri)



pws_boundaries <- filter(PWS,BOUNDARY_TYPE=="Service Area Boundary")
pws_noboundaries <- filter(PWS, BOUNDARY_TYPE!="Service Area Boundary")
pws_noboundaries <- st_drop_geometry(pws_noboundaries)


pl <- places%>%select(uri,NAME,STATEFP)%>%mutate(ST_uri=paste0("https://geoconnex.us/ref/states/",STATEFP)) 
pl$CITY_SERVED=pl$NAME
pl <- select(pl,uri,CITY_SERVED,ST_uri)
pl<-st_transform(pl,4326)
st_write(pl,dsn="data/pl.gpkg")
pl<-st_read("data/pl.gpkg")

pl$CITY_SERVED = toupper(pl$CITY_SERVED)
pl$CITY_SERVED_uri = pl$pl_uri
pl$pl_uri<-NULL

pl2<-st_drop_geometry(pl)

pws_boundaries <- left_join(pws_boundaries,pl2,by=c("CITY_SERVED","ST_uri"))
pws_placeboundaries <- inner_join(pl,pws_noboundaries,by=c("CITY_SERVED","ST_uri"))
pws_noboundaries2 <- anti_join(pws_noboundaries,pws_placeboundaries,by=c("CITY_SERVED","ST_uri"))
pws_noboundaries2 <- left_join(states,pws_noboundaries2,by="ST_uri")
pws_noboundaries2$CITY_SERVED_uri <- NA

pws_boundaries<- select(pws_boundaries,PWSID,NAME,BOUNDARY_TYPE,CITY_SERVED,CITY_SERVED_uri,ST,ST_uri,SDWIS,PROVIDER,POPULATION_SERVED_COUNT,SYSTEM_SIZE,uri)
pws_placeboundaries <- select(pws_placeboundaries,PWSID,NAME,BOUNDARY_TYPE,CITY_SERVED,CITY_SERVED_uri,ST,ST_uri,SDWIS,PROVIDER,POPULATION_SERVED_COUNT,SYSTEM_SIZE,uri)
pws_noboundaries2 <- select(pws_noboundaries2,PWSID,NAME,BOUNDARY_TYPE,CITY_SERVED,CITY_SERVED_uri,ST,ST_uri,SDWIS,PROVIDER,POPULATION_SERVED_COUNT,SYSTEM_SIZE,uri)

pws_boundaries$BOUNDARY_TYPE <- "Water Service Area - As specified in PROVIDER"
pws_placeboundaries$BOUNDARY_TYPE <- "Unknown Service Area - Using City Served Boundary (U.S. Census Places Cartogrpahic Boundary Polygon) to Represent PWS"
pws_noboundaries2$BOUNDARY_TYPE <- "Unknown Service Area - Centroid of State U.S. Census Cartographic Boundary Polygon to Represent PWS"

st_write(pws_placeboundaries,dsn="data/pws_placeboundaries.gpkg")

pwpb<-st_read("data/pws_placeboundaries.gpkg")
names(pwpb)<-names(pws_boundaries)
st_geometry(pwpb)<-"geometry"

PWS2<-rbind(pws_boundaries,pwpb,pws_noboundaries2)
#st_write(PWS2,dsn="out/pws.gpkg")

sdwis<-select(pws,uri,PWSID,STATE_CODE,SOURCE_WATER,POPULATION_SERVED_COUNT)%>%ungroup()
sdwis$SDWIS=paste0("https://enviro.epa.gov/enviro/sdw_report_v3.first_table?pws_id=",
                                               sdwis$PWSID,
                                               "&state=",
                             sdwis$STATE_CODE,
                                               "&source=",
                             sdwis$SOURCE_WATER,
                                               "&population=",
                             sdwis$POPULATION_SERVED_COUNT)
  

sdwis$SDWIS = gsub(" ", "%20",sdwis$SDWIS)
sdwis <- select(sdwis,uri,SDWIS)
PWS2$SDWIS<-NULL
PWS2<-left_join(PWS2,sdwis,by="uri")

PWS$uri <- paste0(root,PWS$PWSID)






st_write(PWS2,dsn="out/pws.gpkg")
write_csv(pids,"out/pws.csv")


batch_size=1000

####   ####



  file <- pids %>% mutate(batch = floor((row_number()-1)/batch_size))
  data_split <- split(file, list(file$batch))
  #  data_split$batch <- NULL
  for (batch in names(data_split)){
    
    d2<-data_split[[batch]]
    d2$batch<-NULL 
    write_csv(d2,path="temp.csv")
    write_xml(in_f="temp.csv", out_f="temp.xml", root="https://geoconnex.us")
    post_pids(in_f="temp.xml", user="iow", password="nieps", root="https://geoconnex.us")
    unlink("temp.csv")
    unlink("temp.xml")
  }
  


