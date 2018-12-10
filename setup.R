## Run this code once to download data.

# Download data -----------------------------------------------------------

fil <- 'REsuretyWebApplicationEngineer.rds'
if (!file.exists(fil)) {
  url <- 'https://www.dropbox.com/s/wml500mkw89ah38/REsuretyWebApplicationEngineer.rds?raw=1'
  download.file(url, file.path('data', fil))
}
# prj <- readRDS(file.path('data', fil))
# data.table::setDT(prj) # refresh the data.table pointer
# print(prj)

