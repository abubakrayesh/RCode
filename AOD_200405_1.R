%
library(doParallel)  #Foreach Parallel Adaptor 
library(foreach)     #Provides foreach looping construct
library(sp)
library(raster)
library(lubridate)
library(rgdal)
library(lattice)
library(latticeExtra)
library(RColorBrewer) # can go to this website
library(rasterVis)
library(foreign)
library(rgeos)
library(maptools)
library(maps)
library(rbenchmark)
library(data.table)
library(zoom)
library(readstata13)
library(spdep) 
library(classInt)
library(tmap)
library(sf)
library(dplyr)
library(spData)
library(spDataLarge)
library(leaflet) # for interactive maps
library(mapview) # for interactive maps
library(ggplot2) # tidyverse vis package
library(shiny)   # for web applications
library(shinyjs)
library(prioritizr)
library(exactextractr)
install.packages("snow")
memory.limit(size=100000000)


AOD_path <- "C:\\Users\\abuba\\Dropbox\\Smog- air pollution\\Data\\Air Quality\\AOD"

AOD <- list.files(path=paste0(AOD_path,"\\2004-05\\AOD Punjab-20200527T222907Z-001\\AOD Punjab"), 
                  pattern =".tif" , full.names=TRUE)
AOD <- stack(AOD)
#names(AOD)

DistPunjab <- st_read(dsn=(paste0("C:\\Users\\abuba\\Dropbox\\Smog- air pollution\\Data\\Air Quality\\Pak_SHP")), 
                      layer="pak_admbnda_adm3_ocha_pco_gaul_20181218")

rstprj <- proj4string(AOD)      
DistPunjab <- st_transform(DistPunjab, rstprj)


for(i in seq(1, nlayers(AOD), 13)) {
  dir=names(AOD[[i]])     #name of the first band of each tif file saved here
  cut1 = substring(dir, 10, 16)
  cut2 = substring(dir, 42, 46)
  aod_sum <- exact_extract(AOD[[i]], DistPunjab,'sum')   #sums the values of each tif file's first band, for each district
  aod_count <- exact_extract(AOD[[i]], DistPunjab,'count')   #counts the values of each tif file's first band, for each district
  DistPunjab[[paste(cut1, cut2, "_sum", sep = "")]] <- aod_sum   #pastes the sum calculated in previous line on the shape file
  DistPunjab[[paste(cut1, cut2, "_count", sep = "")]] <- aod_count   #pastes the count calculated in previous line on the shape file
}


DistPunjab_sp <- as(DistPunjab, "Spatial")    #shapefile converted into sp from st
DistPunjab_sp_data <- DistPunjab_sp@data      #stores shapefile data in tabular form

## Now save shapefile with district level weighted flood shock variables added ##
writeOGR(DistPunjab_sp, dsn=paste0("C:\\Users\\abuba\\Dropbox\\Smog- air pollution\\Data\\Air Quality\\New_shapefile"), layer="DistPunjab_200405_AOD_1", driver="ESRI Shapefile", overwrite_layer = TRUE)

# define data frame #
DistPunjab_sp_df <- data.frame(DistPunjab_sp)

# Write stata file #
write.dta(DistPunjab_sp_df, paste0("C:\\Users\\abuba\\Dropbox\\Smog- air pollution\\Data\\Air Quality\\Stata\\smog_200405_1.dta"))



