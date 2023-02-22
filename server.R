#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


########### WHEN RUNNING FOR THE FIRST TIME

# install.packages(shiny)
# install.packages(traveltimeR)
# install.packages(leaflet)
# install.packages(sp)
# install.packages(htmlwidgets)
# install.packages(stringr)
# install.packages(lutz)
# install.packages(lubridate)
# install.packages(smoothr)
# install.packages(sf)
# install.packages(viridis)
# install.packages(geosphere)
# install.packages(AlphaPart)
# install.packages(rgdal)
# install.packages(readr)

library(shiny)
library(traveltimeR)
library(leaflet)
library(sp)
library(htmlwidgets)
library(stringr)
library(lutz)
library(lubridate)
library(smoothr)
library(sf)
library(viridis)
library(geosphere)
library(AlphaPart)
library(rgdal)
library(readr)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  # reactive values
  results = reactiveValues(data = list())
  statistics = reactiveValues(data_csv = data.frame())
  progress = reactiveValues(status = NULL)
  
  # display lat/lng on map load
  js_code = 'function(el, x) {
                    this.addEventListener("mousemove", function(e) {
                        document.getElementById("coords").innerHTML = e.latlng.lat.toFixed(6) + ", " + e.latlng.lng.toFixed(6);
                    })
                }'
  
  # show the help popup on application startup
  toggleDropdownButton('help')
  
  # initialize map ###################################################################################################
  # show spinner
  shinyjs::show('spinner')
  output$map = renderLeaflet({
    leaflet(options = leafletOptions(minZoom = 4, maxZoom = 18, zoomControl = FALSE)) %>%
      addTiles(urlTemplate = paste0('https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}@2x?',
                                    'access_token=pk.eyJ1IjoiYnlvbGxpbiIsImEiOiJjanNleDR0enAxOXZ5NDRvYXMzYWFzejA',
                                    '2In0.GGB4yI6z0leM1_BwGEYfiQ'),
               attribution = '<a href="https://www.mapbox.com/about/maps/" title="Mapbox" target="_blank"> \
                                   Mapbox ©</a> | Map data provided by \
                                   <a href="https://www.openstreetmap.org/copyright" \
                                   title="OpenStreetMap Contributors" target="_blank"> \
                                   OpenStreetMap © Contributors</a>') %>%
      setView(lng = 2.294515, lat = 48.858132, zoom = 12) %>% onRender(js_code)
  })
  # hide spinner
  delay(ms = 200, { shinyjs::hide('spinner') })
  
  # map click ########################################################################################################
  observeEvent(input$map_click, {
    lat = round(input$map_click$lat, 6)
    lng = round(input$map_click$lng, 6)
    updateTextInput(session, 'origin', value = paste0(lat, ', ', lng))
  })
  
  # update origin input ##############################################################################################
  observeEvent(input$origin, ignoreInit = TRUE, {
    if(validate_coords(input$origin)) {
      lat = str_replace(input$origin, ' ', '') %>% str_split(',')
      lat = lat[[1]][1] %>% as.numeric()
      lng = str_replace(input$origin, ' ', '') %>% str_split(',')
      lng = lng[[1]][2] %>% as.numeric()
      leafletProxy('map') %>% addAwesomeMarkers(lng = lng, lat = lat, layerId = 'origin',
                                                icon = makeAwesomeIcon(icon = 'circle', markerColor = 'black',
                                                                       library = 'fa', iconColor = '#fff'),
                                                popup = paste0(lat,', ', lng),
                                                popupOptions = popupOptions(closeButton = FALSE))
    } else {
      leafletProxy('map') %>% removeMarker('origin')
    }
  })
  
  # confirm request ##################################################################################################
  observeEvent(input$request, {
    
    # show spinner
    shinyjs::show('spinner')
    
    # initialize new progress indicator
    progress$status = Progress$new(session)
    progress$status$set(message = 'Validating inputs...')
    Sys.sleep(1)

    
    # validate inputs
    is_valid = validate_inputs(session, input$origin, input$departure, input$min, input$max, input$step)
    #is_valid=TRUE
    
############################################################
## Isochrones computation
############################################################
   
    if(is_valid) {
      
      progress$status$set(message = 'Requesting...')
      
      departure = paste0(input$departure, ' ',input$time, ':00:00')
      mode = switch(input$mode, 'driving' = 'driving', 'public_transport'='public_transport', 'cycling'='cycling','walking' = 'walking')
      isoline_sequence = seq(input$min, input$max, input$step) * 60 %>% sort()
      unit = ' minutes'
      layers = sapply(1:length(isoline_sequence), function(x) {
        progress$status$inc(amount = 1/length(isoline_sequence),
                            message = paste0('Processing request ', x, ' of ', length(isoline_sequence)))
        
        tryCatch(isoline(str_remove(input$origin, ' '), departure = departure,
                range = isoline_sequence[x], mode = mode),
                error=function(e){
                  progress$status$set(message = 'API request failed !')
                  Sys.sleep(1)
                }
        )
      })
############################################################
## Got response from API as a spatial polygons Dataframe
## Layers for each range, for each layer mutliple shells 
      # (isochrones with holes / islands)
## Now display of the isochrnes on the map
############################################################
      
      # To access an isochrone : 
      #print(layers[[1]]@polygons)
      
      if(all(sapply(layers, class) == 'SpatialPolygonsDataFrame')) {
        # Colors
        colors = magma(length(layers), end = 0.8) %>% str_trunc(width = 7, side = 'right', ellipsis = '')
        sapply(length(layers):1, function(x) {
          leafletProxy('map') %>% addPolygons(data = layers[[x]], weight = 2, color = colors[x],
                                              opacity = 0.6, fillOpacity = 0.3, fillColor = colors[x],
                                              smoothFactor = 0,
                                              highlightOptions = highlightOptions(weight = 3),
                                              popup = paste0("Range : ",seq(input$min, input$max, input$step)[x],
                                                             " minutes<br>Island area : ",layers[[x]]@data$area_km2," km^2<br>Total Area : ",layers[[x]]@data$total_area, " km^2"),
                                              popupOptions = popupOptions(closeButton = FALSE,
                                                                          closeOnClick = TRUE))
        })
        leafletProxy('map') %>% addLegend('bottomright', pal = colorNumeric(colors, domain = 1:2),
                                          values = 1:2, title = tools::toTitleCase(unit), opacity = 1,
                                          layerId = 'legend', group = 'legend',
                                          labFormat = function(type, cuts, p) {
                                            n = length(cuts)
                                            cuts[n] = 'Longer'
                                            for(i in 2:(n - 1)) {
                                              cuts[i] = ""
                                            }
                                            cuts[1] = 'Shorter'
                                            paste0(cuts[-n], cuts[-1])
                                          })
        results$data[[length(results$data) + 1]] = layers
        shinyjs::show('clear_map')
        shinyjs::show('download')
        
        # Storing extra statistics per isochrone
        data_csv=data.frame()  
        for (x in 1:length(layers)) {
          y=layers[[x]]@data
          y$layer=x
          y$n_shapes=nrow(y)
          data_csv=rbind(data_csv,y)
        }
        statistics$data_csv=data_csv
        
        
      } else {
        request_error = HTML("<b>API request failed. Check your API key file and your API usage limit and retry</b>")
        error_message(session, tags$span('Isoline API failed with the following error : ', request_error))
      }
      
    } else {
      progress$status$set(message = 'Invalid input parameters!')
      Sys.sleep(1)
    }
    delay(ms = 200, { shinyjs::hide('spinner') })
    progress$status$close()
  })
  
  
  # download data ####################################################################################################
  
  output$download = downloadHandler(filename = function() { paste('results', 'zip', sep = '.') },
                                    content = function(f) {
                                      tmp = tempdir()
                                      old_shapefiles = list.files(tmp, pattern = '.*\\.(shp|dbf|prj|shx)$')
                                      file.remove(paste0(tmp, '/', old_shapefiles))
                                      sapply(1:length(results$data), function(x) {
                                        out = do.call('rbind', results$data[[x]])
                                        writeOGR(out, dsn = tmp, layer = paste0('isochrone_', x), driver = 'ESRI Shapefile', overwrite = TRUE)
                                      })
                                      zip_files = list.files(tmp, pattern = '.*\\.(shp|dbf|prj|shx)$')

                                      
                                      path=file.path(tmp,"results.csv")
                                      write_csv(data.frame(statistics$data_csv), file=path)

                                      zip_files = paste0(tmp, '/', zip_files)
                                      zip_files = append(zip_files,path)

                                      zip(zipfile = f, files = zip_files, flags = '-j')
                                    },
                                    contentType = 'application/zip'
  )
  
  # clear map ########################################################################################################
  observeEvent(input$clear_map, {
    results$data = list()
    updateTextInput(session, 'origin', value = '')
    leafletProxy('map') %>% clearShapes() %>% clearControls()
    #shinyjs::hide('clear_panel')
    shinyjs::hide('download')
  })
  
  # add crosshair cursor to map
  shinyjs::runjs('document.getElementById("map").style.cursor = "crosshair"')
  
})
