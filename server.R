#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

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

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  # reactive values
  results = reactiveValues(data = list())
  progress = reactiveValues(status = NULL)
  
  # display lat/lng on map load
  js_code = 'function(el, x) {
                    this.addEventListener("mousemove", function(e) {
                        document.getElementById("coords").innerHTML = e.latlng.lat.toFixed(6) + ", " + e.latlng.lng.toFixed(6);
                    })
                }'
  
  # show the help popup on applicatio startup
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
    #is_valid = validate_inputs(session, input$origin, input$departure, input$min, input$max, input$step)
    is_valid=TRUE
    
############################################################
## Code a modif pour iso
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
        isoline(str_remove(input$origin, ' '), departure = departure,
                range = isoline_sequence[x], mode = mode)
      })
############################################################
## Need to return layers being a spatial polygons Dataframe
      # Use code in global.r to get result df
      # change the return value to spatial polygons well ordered
## Find a solution for island and holes : 
      # store islands and plot separately
      # how to plot holes ?
## Then change other parts of the code to get different inputs for example
############################################################
      
      #print(layers[[1]]@polygons)
      
      if(all(sapply(layers, class) == 'SpatialPolygonsDataFrame')) {
        ###### Colors picked randomly ?
        colors = magma(length(layers), end = 0.8) %>% str_trunc(width = 7, side = 'right', ellipsis = '')
        sapply(length(layers):1, function(x) {
          leafletProxy('map') %>% addPolygons(data = layers[[x]], weight = 2, color = colors[x],
                                              opacity = 0.6, fillOpacity = 0.3, fillColor = colors[x],
                                              smoothFactor = 0,
                                              highlightOptions = highlightOptions(weight = 3),
                                              popup = paste0("Range : ",seq(input$min, input$max, input$step)[x],
                                                             " minutes<br>Area : ",round(layers[[x]]@data$area_m2/10^6,3)," km^2"),
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
      } else {
        request_error = layers[sapply(layers, class) != 'SpatialPolygonsDataFrame'] %>% unlist() %>% unique()
        error_message(session, tags$span('Isoline API failed with the following error: ', request_error))
      }
      
    } else {
      progress$status$set(message = 'Invalid input parameters!')
      Sys.sleep(1)
    }
    delay(ms = 200, { shinyjs::hide('spinner') })
    progress$status$close()
  })
  
  # download data ####################################################################################################
  output$download = downloadHandler(filename = function() { paste('output', 'zip', sep = '.') },
                                    content = function(f) {
                                      tmp = tempdir()
                                      old_shapefiles = list.files(tmp, pattern = '.*\\.(shp|dbf|prj|shx)$')
                                      file.remove(paste0(tmp, '/', old_shapefiles))
                                      sapply(1:length(results$data), function(x) {
                                        out = do.call('rbind', results$data[[x]])
                                        writeOGR(out, dsn = tmp, layer = paste0('isochrone_', x), driver = 'ESRI Shapefile', overwrite = TRUE)
                                      })
                                      zip_files = list.files(tmp, pattern = '.*\\.(shp|dbf|prj|shx)$')
                                      zip_files = paste0(tmp, '/', zip_files)
                                      zip(zipfile = f, files = zip_files, flags = '-j')
                                    },
                                    contentType = 'application/zip'
  )
  
  # clear map ########################################################################################################
  observeEvent(input$clear_map, {
    results$data = list()
    updateTextInput(session, 'origin', value = '')
    leafletProxy('map') %>% clearShapes() %>% clearControls()
    shinyjs::hide('clear_panel')
    shinyjs::hide('download')
  })
  
  # add crosshair cursor to map
  shinyjs::runjs('document.getElementById("map").style.cursor = "crosshair"')
  
})
