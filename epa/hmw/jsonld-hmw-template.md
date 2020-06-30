This document shows what needs to happen for HMW pages. HMW pages now have persistent identifiers corresponding to every NHDPlusV2 HUC12, of pattern https://geoconnex.us/epa/hmw/{HUC12}



The actual HMW pages currently have this content:

```{html}


```

Need to insert in <head></head>

```
<script type="application/ld+json">
{
 "@context": [   need to inline everything relevant
  "https://opengeospatial.github.io/ELFIE/contexts/elfie-2/elf.jsonld",
  "https://opengeospatial.github.io/ELFIE/contexts/elfie-2/hy_features.jsonld",
  "https://opengeospatial.github.io/ELFIE/contexts/elfie-2/elf-spatial.jsonld",
  {
   "gsp": "http://www.opengeospatial.org/standards/geosparql/"
  }
 ],
 "@id": "https://geoconnex.us/epa/hmw/020700110204",
 "@type": ###something###,
 "name": "Accokeek Creek (020700110204)",
 "description": "EPA How's My Waterway Community as Twelve-Digit Hydrologic Unit",
 "about": "https://geoconnex.us/nhdplusv2/huc12/020700110204"
 "gsp:intersects": ["https://geoconnex.us/ref/places/5102112","https://geoconnex.us/ref/counties/51179","https://geoconnex.us/ref/states/51]
 "geo": [
  {
   "@type": "schema:GeoCoordinates",
   "schema:latitude": 38.3509973927964,
   "schema:longitude": -77.3048611435762
  },
  {
   "@type": "schema:GeoShape",
   "schema:url": "https://labs.waterdata.usgs.gov/api/nldi/linked-data/huc12pp/020700110204/basin",
  }
 ]
}


</script>

```
