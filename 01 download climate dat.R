

# Load libraries ----------------------------------------------------------
require(pacman)
p_load(terra, sf, tidyverse, gtools, rgeos, geodata, fs, glue, stringr, remotes)

remotes::install_github("mikejohnson51/climateR")
library(climateR)

# Load data ---------------------------------------------------------------
bsin <- st_read('shp/TEM_HIDRO_CUENCAS_HIDROGRAFICAS.shp')
peru <- gadm(country = 'PER', level = 1, path = './tmpr')
jnin <- peru[peru$NAME_1 == 'Junín',]
jnin <- st_as_sf(jnin)
jnin <- st_transform(jnin, crs = st_crs(4326))
peru <- st_as_sf(peru)

head(bsin)
unique(sort(bsin$NOMBRE))
param_meta$terraclim

# To download -------------------------------------------------------------

# Terraclimate ------------------------------------------------------------
prec <- getTerraClim(AOI = peru, param = 'prcp', startDate = '1958-01-01', endDate = '2020-12-31')
prec <- prec$terraclim_prcp

tmax <- getTerraClim(AOI = peru, param = 'tmax', startDate = '1958-01-01', endDate = '2020-12-31')
tmax <- tmax$terraclim_tmax

tmin <- getTerraClim(AOI = peru, param = 'tmin', startDate = '1958-01-01', endDate = '2020-12-31')
tmin <- tmin$terraclim_tmin

# Directory output --------------------------------------------------------
dout <- './tif/tc/peru'
dir_create(dout)

terra::writeRaster(x = prec, filename = glue('{dout}/prec.tif'), overwrite = TRUE)
terra::writeRaster(x = tmax, filename = glue('{dout}/tmax.tif'), overwrite = TRUE)
terra::writeRaster(x = tmin, filename = glue('{dout}/tmin.tif'), overwrite = TRUE)

rm(prec, tmax, tmin)

# Download worldclim ------------------------------------------------------

# 1 kilometer
prec <- geodata::worldclim_country(country = 'PER', var = 'prec', path = './tmpr')
tmax <- geodata::worldclim_country(country = 'PER', var = 'tmax', path = './tmpr')
tmin <- geodata::worldclim_country(country = 'PER', var = 'tmin', path = './tmpr')

dout <- './tif/wc/peru'
dir_create(dout)

terra::writeRaster(x = prec, filename = glue('{dout}/prec_1km.tif'), overwrite = TRUE)
terra::writeRaster(x = tmax, filename = glue('{dout}/tmax_1km.tif'), overwrite = TRUE)
terra::writeRaster(x = tmin, filename = glue('{dout}/tmin_1km.tif'), overwrite = TRUE)

# 5 kilometer
prec <- geodata::worldclim_global(res = 2.5, var = 'prec', path = './tmpr')
prec <- terra::crop(prec, vect(peru)) %>% terra::mask(., vect(peru))
tmax <- geodata::worldclim_global(res = 2.5, var = 'tmax', path = './tmpr')
tmax <- terra::crop(tmax, vect(peru)) %>% terra::mask(., vect(peru))
tmin <- geodata::worldclim_global(res = 2.5, var = 'tmin', path = './tmpr')
tmin <- terra::crop(tmin, vect(peru)) %>% terra::mask(., vect(peru))

terra::writeRaster(x = prec, filename = glue('{dout}/prec_5km.tif'), overwrite = TRUE)
terra::writeRaster(x = tmax, filename = glue('{dout}/tmax_5km.tif'), overwrite = TRUE)
terra::writeRaster(x = tmin, filename = glue('{dout}/tmin_5km.tif'), overwrite = TRUE)
