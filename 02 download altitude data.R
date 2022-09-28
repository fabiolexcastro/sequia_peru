

# Load libraries ----------------------------------------------------------
require(pacman)
p_load(terra, sf, tidyverse, GmAMisc, elevatr, gtools, rgeos, geodata, fs, glue, stringr, remotes)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999, warn = -1)

# Load data ---------------------------------------------------------------
proj <- st_read('./shpf/TEM_HIDRO_CUENCAS_HIDROGRAFICAS.shp') %>% st_crs()
mntr <- st_read('./gpkg/mantaro_geo.gpkg')

srtm <- get_elev_raster(as(mntr, 'Spatial'), z = 12)
srtm
plot(srtm)
plot(st_geometry(mntr), add = TRUE, border = 'red')

res(srtm)[1] * res(srtm)[2]
(res(srtm)[1] * 111.11) * 1000

srtm_11 <- get_elev_raster(as(mntr, 'Spatial'), z = 11)
srtm_11
plot(srtm_11)
res(srtm)[1] * res(srtm)[2]

(res(srtm_11)[1] * 111.11) * 1000

srtm_11_2 <- srtm_11
srtm_11_2 <- round(srtm_11_2, digits = 0)

plot(srtm_11_2)

srtm_11_3 <- srtm_11_2
srtm_11_3[which(srtm_11_3[] > 6000)] <- 6000

srtm_11_3 <- reclassify(srtm_11_3, c(-1000, 5999, 0, 5999.1, Inf, 1))
table(srtm_11_3[])

dout <- './tif/dem'
dir_create(dout)
writeRaster(srtm_11, './tif/dem/srtm_mantaro_37m_raw.tif', overwrite = TRUE)
writeRaster(srtm, './tif/dem/srtm_mantaro_18m_raw.tif', overwrite = TRUE)

srtm_11 <- srtm_11 * 1
srtm_11

srtm_18 <- srtm
srtm_18 <- round(srtm_18, 0)

plot(srtm_18)


# SRTM --------------------------------------------------------------------
fles <- dir_ls('./tif/dem') %>% as.character() %>% grep('.tif$', ., value = T)
rstr <- fles[2]
rstr <- terra::rast(rstr)

rstr_proj <- terra::project(rstr, '+proj=utm +zone=18 +south +datum=WGS84 +units=m +no_defs +type=crs')

terra::writeRaster(rstr_proj, './tif/dem/srtm_mantaro_37m_fill_proj.tif')

clss <- landfClass(rstr, scale = 3)
