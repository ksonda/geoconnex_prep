FROM geopython/pygeoapi:latest

RUN MKDIR /ext_data
ADD https://www.hydroshare.org/resource/5f665b7b82d74476930712f7e423a0d2/data/contents/wade_sites.gpkg /ext_data

COPY ./pygeoapi.config.yml /pygeoapi/local.config.yml
