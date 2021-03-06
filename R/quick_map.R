#' Function to make quick leaflet maps of spatial data
#' @param plot_data An sp, sf or rasterLayer object to plot
#' @param value_field Names of column corresponding to values to plot
#' @param colors Optional set of hexcolors to create a color palette from
#' @import leaflet sf sp raster wesanderson
#' @export

quick_map <- function(plot_data, value_field=NULL, colors=NULL, circle_size = 3, 
                      raster_legend_title = NULL){
  
  if(is.null(plot_data)){
    stop("'plot_data' not defined")
  }
  
  # if(is.null(value_field)){
  #   stop("'value_field' not defined")
  # }
  
  # Define basemap
  basemap <- leaflet() %>% addProviderTiles("CartoDB.Positron") 

  if(is.null(colors)){
  colors <- wes_palette("Zissou1", 10, type = "continuous")[1:10]
  }
  
  # Figure out whether points, polys or raster
  if(class(plot_data)[1] == "RasterLayer"){
    
    if(!is.null(raster_legend_title)){
      title <- raster_legend_title
    }else{
      title <- names(plot_data)
    }
    
    col_pal <- colorNumeric(colors,
                 values(plot_data), na.color = NA)
    map <- basemap %>% addRasterImage(plot_data, col_pal, opacity = 0.7) %>%
      addLegend(pal=col_pal, values=values(plot_data), title = title)
  }
  
  if(class(plot_data)[1] == "SpatialPolygonsDataFrame" |
       class(plot_data)[1] == "SpatialPolygons"){
    
    col_pal <- colorNumeric(colors,
                            plot_data[[value_field]], na.color = NA)
    map <- basemap %>% addPolygons(data=plot_data, col = col_pal(plot_data[[value_field]]),
                            fillOpacity = 0.7)%>%
      addLegend(pal=col_pal, values=plot_data[[value_field]], title = value_field)
  }  
  
  if(class(plot_data)[1] == "SpatialPointsDataFrame" |
     class(plot_data)[1] == "SpatialPoints"){
    col_pal <- colorNumeric(colors,
                            plot_data[[value_field]], na.color = NA)
    basemap %>% addCircleMarkers(data=plot_data, col = col_pal(plot_data[[value_field]]),
                            fillOpacity = 0.7, radius = circle_size) %>%
      addLegend(pal=col_pal, values=plot_data[[value_field]], title = value_field)
  }  
  
  if(class(plot_data)[1] == "sf"){
    
    if(st_geometry_type(plot_data)[1] == "POLYGON"){
      col_pal <- colorNumeric(colors,
                              plot_data[[value_field]], na.color = NA)
      map <- basemap %>% addPolygons(data=plot_data, col = col_pal(plot_data[[value_field]]),
                              fillOpacity = 0.7) %>%
        addLegend(pal=col_pal, values=plot_data[[value_field]], title = value_field)
  }    
  
    if(st_geometry_type(plot_data)[1] == "POINT"){
      col_pal <- colorNumeric(colors,
                              plot_data[[value_field]], na.color = NA)
      map <- basemap %>% addCircleMarkers(data=plot_data, col = col_pal(plot_data[[value_field]]),
                                   fillOpacity = 0.7, radius = circle_size) %>%
        addLegend(pal=col_pal, values=plot_data[[value_field]], title = value_field)
    }
    
  
  }
  return(map)
}