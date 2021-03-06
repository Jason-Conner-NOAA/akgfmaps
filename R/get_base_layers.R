#' Function to get base layers for plotting
#' 
#' This function loads often-used layers used for plotting the eastern Bering Sea continental shelf.
#' 
#' @param select.region Character vector indicating which region. Options = bs.south', 'bs.all'
#' @param set.crs Which coordinate reference system should be used? If "auto", an Albers Equal Area coordinate reference system is automatically assigned. Default = "+proj=longlat +datum=NAD83"
#' @return Returns a list containing sf objects land, bathymetry, survey area, a data frame of feature labels, coordinate reference system for all objects, and a suggested boundary.

get_base_layers <- function(select.region, set.crs = "+proj=longlat +datum=NAD83") {
  
  # Automatically set CRS---------------------------------------------------------------------------
  if(set.crs == "auto") {
    region.crs <- c("+proj=aea +lat_1=55 +lat_2=60 +lat_0=57.5 +lon_0=-170 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs",
                    "+proj=aea +lat_1=57 +lat_2=63 +lat_0=59 +lon_0=-170 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")
    set.crs <- region.crs[match(select.region, c("bs.south", "bs.all"))]
  }
  
  # Land shapefile----------------------------------------------------------------------------------
  akland <- sf::st_read(system.file("data", "ak_russia.shp", package = "akgfmaps"), quiet = TRUE)
  
  # SEBS--------------------------------------------------------------------------------------------
  if(select.region == "bs.south") {
    survey.area <- sf::st_read(system.file("data", "ebs_south_survey_boundary.shp", package = "akgfmaps"), quiet = TRUE)
    bathymetry <- sf::st_read(system.file("data", "npac_0-200_meters.shp", package = "akgfmaps"), quiet = TRUE)
    plot.boundary <- akgfmaps::transform_data_frame_crs(data.frame(x = c(-177.3, -154.3), 
                                                                   y = c(54.5, 63.15)), 
                                                        out.crs = set.crs)
    graticule <- st_graticule(lat = seq(54,64,2), 
                              lon = seq(-180,-140, 5), 
                              margin = 1e-5)
    lon.breaks <- seq(-180, -154, 5)
    lat.breaks <- seq(54,64,2)
  }
  
  # NEBS+SEBS---------------------------------------------------------------------------------------
  if(select.region == "bs.all") {
    survey.area <- sf::st_read(system.file("data", "ebs_south_and_north_survey_boundary.shp", package = "akgfmaps"), quiet = TRUE)
    bathymetry <- sf::st_read(system.file("data", "ebs_south_and_north_bathymetry.shp", package = "akgfmaps"), quiet = TRUE)
    plot.boundary <- akgfmaps::transform_data_frame_crs(data.frame(x = c(-177.8, -154.7), 
                                                                   y = c(54, 65.1)), 
                                                        out.crs = set.crs)
    graticule <- st_graticule(lat = seq(54,68,2), 
                              lon = seq(-180,-140, 5), 
                              margin = 1e-5)
    lon.breaks <- seq(-180, -154, 5)
    lat.breaks <- seq(54,66,2)
  }
  
  # Set CRS-----------------------------------------------------------------------------------------
  if(tolower(class(set.crs)) != "crs") {
    set.crs <- sf::st_crs(set.crs)
  }
  
  akland <- akland %>% sf::st_transform(crs = set.crs)
  survey.area <- survey.area %>% sf::st_transform(crs = set.crs)
  bathymetry <- bathymetry %>% sf::st_transform(crs = set.crs)

  
  # Get place labels--------------------------------------------------------------------------------
  place.labels <- read.csv(file = system.file("data", "placenames.csv", package = "akgfmaps")) %>%
    dplyr::filter(region == select.region) %>%
    akgfmaps::transform_data_frame_crs(out.crs = set.crs)
  
  return(list(akland = akland,
              survey.area = survey.area,
              bathymetry = bathymetry,
              place.labels = place.labels,
              graticule = graticule,
              crs = set.crs,
              plot.boundary = plot.boundary,
              lon.breaks = lon.breaks,
              lat.breaks = lat.breaks))
}