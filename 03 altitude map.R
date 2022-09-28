
# Load libraries ----------------------------------------------------------
require(pacman)
p_load(terra, sf, tidyverse, GmAMisc, ggnewscale, elevatr, gtools, rgeos, geodata, fs, glue, stringr, remotes)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999, warn = -1)

# Load data ---------------------------------------------------------------
srtm <- terra::rast('./tif/dem/srtm_mantaro_37m_fill.tif')
terrain.colors(n = 10)

bsin <- sf::st_read('./gpkg/mantaro_geo.gpkg')

plot(srtm)
plot(bsin, add = TRUE)

# Get the hillshade -------------------------------------------------------
slpe <- terra::terrain(x = srtm, v = 'slope')
aspc <- terra::terrain(x = srtm, v = 'aspect')
hlls <- terra::shade(slope = slpe, aspect = aspc, angle = 40, direction = 270)

# Extract by mask ---------------------------------------------------------
bsin <- terra::vect(bsin)

# Altitude
srtm <- crop(srtm, bsin) %>% mask(., bsin)

# Hillshade
hlls <- raster::raster(hlls)
hlls <- raster::crop(hlls, as(bsin, 'Spatial'))
hlls <- raster::mask(hlls, as(bsin, 'Spatial'))
hlls <- terra::rast(hlls)

terra::writeRaster(hlls, './tif/dem/hillshade.tif')

# Terrain (altitude + hillshade)
trrn <- c(srtm, hlls)

# Raster to table ---------------------------------------------------------
tble <- terra::as.data.frame(trrn, xy = TRUE) %>% as_tibble %>% setNames(c('x', 'y', 'srtm', 'hill'))

# To make the map ---------------------------------------------------------

gmap <- ggplot() + 
  geom_tile(data = tble, aes(x = x, y = y, fill = srtm)) + 
  scale_fill_gradientn(colors = terrain.colors(n = 10)) + 
  geom_sf(data = st_as_sf(bsin), fill = NA, col = 'grey70', lwd = 0.5) +
  coord_sf() + 
  ggtitle(label = 'Modelo de elevación digital para la Cuenca Mantaro', 
          subtitle = 'Resolución ~37 meters') +
  labs(x = 'Lon', y = 'Lat', caption = 'Fuente: CSI - SRTM') +
  theme_minimal() + 
  theme(legend.position = 'right', 
        legend.text = element_text(family = 'serif'), 
        plot.title = element_text(family = 'serif', face = 'bold', hjust = 0.5), 
        plot.subtitle = element_text(family = 'serif', face = 'bold', hjust = 0.5),
        plot.caption = element_text(family = 'serif'),
        axis.text.y = element_text(family = 'serif', angle = 90, hjust = 0.5),
        axis.text.x = element_text(family = 'serif'), 
        axis.title.x = element_text(family = 'serif', face = 'bold'), 
        axis.title.y = element_text(family = 'serif', face = 'bold'),
        legend.key.height = unit(4, 'line'))

ggsave(plot = gmap, filename = './png/maps/srtm.png', units = 'in', width = 9, height = 7, dpi = 300)




