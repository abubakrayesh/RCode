install.packages("raster")
library(doParallel)  #Foreach Parallel Adaptor 
library(foreach)     #Provides foreach looping construct
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
library(sp)
install.packages("snow")
memory.limit(size=100000000)

setwd("C:\\Users\\abuba\\Dropbox\\Smog- air pollution\\Data\\Wind")


#####   Importing the tehsil shapefile      #####

tehsilPak <- st_read(dsn=(paste0("C:\\Users\\abuba\\Dropbox\\Smog- air pollution\\Data\\Air Quality\\Pak_SHP")), 
                     layer="pak_admbnda_adm3_ocha_pco_gaul_20181218")


#####   Importing the 100m wind u data   #####
GRIB <- brick("100windu.grib", values=TRUE) 

GRIB_array<-as.array(GRIB) 

GRIB[] <- 1:length(GRIB)

rstprj <- proj4string(GRIB)      
tehsilPak <- st_transform(tehsilPak, rstprj)

cropwindu_100 <- crop(GRIB, extent(tehsilPak))       #crop to restrict to polygon area
maskwindu_100 <- mask(cropwindu_100, tehsilPak)   #copy the relevant values from original raster to the new cropped raster

#plot(maskPak)
#plot(tehsilPak, add=TRUE, lwd=2)


for(i in seq(1, nlayers(maskwindu_100), 1))  {
  dir = names(maskwindu_100[[i]])
  windu100_sum <- exact_extract(maskwindu_10[[i]], tehsilPak,'sum')
  windu100_count <- exact_extract(maskwindu_10[[i]], tehsilPak,'count')
  tehsilPak[[paste(dir, "_sum", sep = "")]] <- windu100_sum
  tehsilPak[[paste(dir, "_count", sep = "")]] <- windu100_count
}



tehsilPak_sp <- as(tehsilPak, "Spatial")    #shapefile converted into sp from st
tehsilPak_sp_data <- tehsilPak_sp@data      #stores shapefile data in tabular form

## Now save shapefile with tehsil level wind 100u variable added ##
writeOGR(tehsilPak_sp, dsn=paste0("C:\\Users\\abuba\\Dropbox\\Smog- air pollution\\Data\\Wind\\New_shapefile"), 
         layer="windu_100", driver="ESRI Shapefile", overwrite_layer = TRUE)

# define data frame #
tehsilPak_sp_df <- data.frame(tehsilPak_sp)

# Write stata file #
write.dta(tehsilPak_sp_df, paste0("C:\\Users\\abuba\\Dropbox\\Smog- air pollution\\Data\\Wind\\Stata\\windu_100.dta"))

