This document shows what needs to happen for HMW pages. HMW pages now have persistent identifiers corresponding to every NHDPlusV2 HUC12, of pattern https://geoconnex.us/epa/hmw/{HUC12}



The actual HMW pages currently generate this HTML <head><\head> block:

```{html}
<!doctype html>
<html class="js" lang="en" dir="ltr">
	<head>
		<meta charset="utf-8"/>
		<meta http-equiv="ImageToolbar" content="false"/>
		<meta http-equiv="cleartype" content="on"/>
		<meta name="HandheldFriendly" content="true"/>
		<link rel="shortcut icon" href="https://www.epa.gov/sites/all/themes/epa/favicon.ico" type="image/vnd.microsoft.icon"/>
		<meta name="MobileOptimized" content="width"/>
		<meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"/>
		<meta name="DC.description" content="An application for learning the condition of local streams, lakes and other waters anywhere in the US... quickly and in plain language."/>
		<meta name="description" content="An application for learning the condition of local streams, lakes and other waters anywhere in the US... quickly and in plain language."/>
		<meta name="DC.title" content="How's My Waterway?"/>
		<meta name="keywords" content="Clean Water Act (CWA), Safe Drinking Water Act (SDWA), pollution, impaired waterbodies"/>
		<link rel="canonical" href=""/>
		<link rel="shortlink" href=""/>
		<meta name="DC.language" content="en"/>
		<meta name="DC.Subject.epachannel" content="Learn the Issues"/>
		<meta name="DC.type" content="Data and Tools"/>
		<meta name="DC.creator" content="US EPA"/>
		<meta name="theme-color" content="#0071bc">
			<title>How’s My Waterway? | US EPA</title>
			<link rel="manifest" href="/site.webmanifest" crossorigin="use-credentials">
				<link rel="stylesheet" href="https://www.epa.gov/sites/all/libraries/standalone/css/core/style.css"/>
			<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto|Roboto+Slab|Source+Sans+Pro:700i&display=swap">
				<link rel="stylesheet" href="https://js.arcgis.com/4.12/esri/css/main.css"/>
			<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
				<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.0/css/all.css" integrity="sha384-lZN37f5QGtY3VHgisS14W3ExzMWZxybE1SJSEsQp9S+oqd12jhcu+A56Ebc1zFSJ" crossorigin="anonymous"/>
			<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
			<link rel="manifest" href="/site.webmanifest">
			<link rel="mask-icon" href="/safari-pinned-tab.svg" color="#ffffff">
				<meta name="msapplication-TileColor" content="#2b5797">
				<meta name="theme-color" content="#ffffff">
					<style>.epa-search .form-text{display:inline-block;margin-top:0}.main-footer .region-footer .row{margin:0}.main-footer .region-footer .col:first-of-type{padding-left:0}.main-footer .region-footer .col:last-of-type{padding-right:0}</style>
					<script>!function(e,t,a,n,g){e[n]=e[n]||[],e[n].push({"gtm.start":(new Date).getTime(),event:"gtm.js"});var m=t.getElementsByTagName(a)[0],r=t.createElement(a);r.async=!0,r.src="//www.googletagmanager.com/gtm.js?id=GTM-L8ZB",m.parentNode.insertBefore(r,m)}(window,document,"script","dataLayer")</script>
					<script>if(function(t,e,a,n,o,i,c){t.GoogleAnalyticsObject=o,t.ga=t.ga||function(){(t.ga.q=t.ga.q||[]).push(arguments)},t.ga.l=1*new Date,i=e.createElement(a),c=e.getElementsByTagName(a)[0],i.async=1,i.src="//www.google-analytics.com/analytics.js",c.parentNode.insertBefore(i,c)}(window,document,"script",0,"ga"),window.isIdSet=!1,document.location.hostname.indexOf("epa.gov")>-1?(ga("create","UA-32633028-1","auto"),ga("send","pageview"),isIdSet=!0):"mywaterway-stage.app.cloud.gov"===document.location.hostname?(ga("create","UA-37504877-4","auto"),ga("send","pageview"),isIdSet=!0):"mywaterway-dev.app.cloud.gov"!==document.location.hostname&&"localhost"!==document.location.hostname||(ga("create","UA-37504877-3","auto"),ga("send","pageview"),isIdSet=!0),isIdSet){let t;"function"==typeof Event?t=new Event("locationchange"):(t=document.createEvent("Event"),t.initEvent("locationchange",!1,!1)),window.addEventListener("locationchange",(function(t){ga("set","page",window.location.pathname),ga("send","pageview")}));var pushState=history.pushState;history.pushState=function(){pushState.apply(history,arguments),window.dispatchEvent(t)};var replaceState=history.replaceState;history.replaceState=function(){replaceState.apply(this,arguments),window.dispatchEvent(t)},window.addEventListener("popstate",(function(){window.dispatchEvent(t)})),document.addEventListener("click",(function(t){if(t.target.onclick&&t.target.textContent){const e=t.target.title?"ow-hmw2-"+t.target.textContent+" - "+t.target.title:"ow-hmw2-"+t.target.textContent;ga("send","event","buttonClick",e,window.location.pathname)}if("a"===t.target.tagName.toLowerCase()&&"_blank"===t.target.target){const e=t.target.href;let a="Web-service";if(document.location.hostname===t.target.hostname){const t=e.split(".").pop;a=".pdf"===t||".zip"===t?"Download":"Internal"}else a="External";ga("send","event",a,"ow-hmw2-"+t.target.text,e)}}))}</script>
					<link href="/static/css/2.f1c8785f.chunk.css" rel="stylesheet">
				<link href="/static/css/main.8afc9e08.chunk.css" rel="stylesheet">
	</head>

```

The following 2 changes would be sufficient in the short term:

1. Change the line ```<link rel="canonical" href=""/>``` to include the PID (e.g. ```<link rel="canonical" href="https://geoconnex.us/epa/hmw/020700110204"/>```). This ensures that when search engines crawl the geoconnex PIDs, it indexes the pages they redirect to.

2. Insert the following <script></script> block within this head block (modified as appropriate for each HUC12/ pid). This will help improve search indexes return structured/ highlighted content to users. For geoconnex purposes, the key is to include ```"@id": "<pid>"``` and ```"about:" "<nhdplusv2 pid>"```. Eventually, we hope to build an "internet of water" crawler that will be able to crawl all the pages with geoconnex PIDs, and infer and store relationships between web resources like HMW and persistently identified features in a search index. We can then use this index to create a more generalized discovery tool with all kinds of semantic and hydrologic search parameters. 

```
<script type="application/ld+json">
{
 "@context": [   
  "https://schema.org"
 ],
 "@id": "https://geoconnex.us/epa/hmw/020700110204",
 "@type": "WebPage,
 "name": "Accokeek Creek (020700110204)",
 "provider": "https://epa.gov",
 "description": "EPA How's My Waterway Community as Twelve-Digit Hydrologic Unit",
 "about": "https://geoconnex.us/nhdplusv2/huc12/020700110204"
}
</script>

```
