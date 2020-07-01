This document shows what needs to happen for HMW pages. HMW pages now have persistent identifiers corresponding to every NHDPlusV2 HUC12, of pattern https://geoconnex.us/epa/hmw/{HUC12}



The actual HMW pages currently have this content:

```{html}


```

Need to insert in <head></head>

```
<script type="application/ld+json">
{
 "@context": [   
  "https://schema.org"
 ],
 "@id": "https://geoconnex.us/epa/hmw/020700110204",
 "@type": "WebPage,
 "name": "Accokeek Creek (020700110204)",
 "description": "EPA How's My Waterway Community as Twelve-Digit Hydrologic Unit",
 "about": "https://geoconnex.us/nhdplusv2/huc12/020700110204"
}
</script>

```
