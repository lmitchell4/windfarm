if (!requireNamespace('data.table')) {install.packages('data.table')}
if (!requireNamespace('maps'))       {install.packages('maps')}
library('maps')

"
RESURETY ENGINEERING CODE CHALLENGE ============================================

Thank you for your interest in the REsurety Web Applications Engineer Position.
We create some pretty cool visualizations in R using Shiny, Leaflet, and data.table.
Here's a chance for you to show your skills with a sample wind energy dataset.

DELIVERABLE ====================================================================

Create an R+Shiny web application that would help a user understand which
US wind farms are most efficient. The way you present this information is up to you,
but we recommend that it have some sort of mapping component to show off geographical
trends.  Hosting the application is optional but preferred.

We recommend that you spend no more than 2 hours on this task.  When you
are done, send a screenshot, the source code, and (if hosted) a URL 
to Karl Critz <kcritz@resurety.com>. We'll then get back to you with next steps.

SOURCE DATA ====================================================================

The linked .rds file is a data.table with characteristics of every US wind farm.

* ID - a numeric unique ID
* Name - the name of the farm
* Latitude/Longitude - GPS coordinate
* CapacityMW - maximum possible 'nameplate capacity' power generation in MW
* GenerationMWhPerYear - average annual energy generation in MW-hours

A farm's efficiency is defined by its 'net capacity factor', which is
generation / (capacity * time).  In this case, time is 1 year or 8760 hours.
Because the wind doesn't always blow, wind farms tend to produce ~30-50% 
of their maximum potential.

# DOWNLOAD DATA ================================================================

You can download the data from the web or read it directly from the URL:
"

fil <- 'WindProjects.rds'
if (!file.exists(fil)) {
  url <- 'https://www.dropbox.com/s/wml500mkw89ah38/REsuretyWebApplicationEngineer.rds?raw=1'
  download.file(url, fil)
}
prj <- readRDS(fil)
data.table::setDT(prj) # refresh the data.table pointer
print(prj)

"
SAMPLE VISUALIZATION ==========================================================

Here's a way to show the nameplate capacity of the projects on a static map.
"
maps::map('state', col = 'grey')
prj[, points(Longitude, Latitude, pch = 19, col = CapacityMW)]
