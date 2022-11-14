#' isoline
#' 
#' Sends an isoline request to the Traveltime API.
#' 
#' @param origin origin coordinates
#' @param departure departure time
#' @param range range provide units in seconds
#' @param mode transportation mode, either car or pedestrian
#' @param app_id app_id provided by HERE
#' @param app_code app_code provided by HERE
#' 
#' @return SpatialPolygonsDataFrame

isoline = function(origin, departure, range, mode) {
    format_time = function(x, origin) {
        tz = tz_lookup_coords(str_split(origin, ',', simplify = TRUE)[1] %>% as.numeric(),
                              str_split(origin, ',', simplify = TRUE)[2] %>% as.numeric(), warn = FALSE)
        ymd_hms(x, tz = tz) %>% format('%Y-%m-%dT%H:%M:%SZ', tz = tz)
    }
    
    formatted_departure = format_time(departure, origin)
    formatted_origin = str_split(origin,",")[[1]] %>% as.numeric()
    options(digits = 12)
    print(formatted_origin)
    
    departure_search <-
      make_search(id = paste0("travel time from ",str(origin)),
                  departure_time = formatted_departure,
                  travel_time = range,
                  coords = list(lat = formatted_origin[1], lng = formatted_origin[2]),
                  transportation = list(type = mode),
                  single_shape=TRUE
                  )
    
    result <- time_map(departure_searches = departure_search)
    
    lat<-c()
    lng<-c()
    i<-1
    #rajouter boucle sur i for pour les ilots
    for (e in result$contentParsed$results[[1]]$shapes[[i]]$shell) {
      lat<-append(lat,e$lat)
      lng<-append(lng,e$lng)
    }
    print("")
    print("resultat API : ")
    print(result$contentParsed$results[[1]]$shapes[[i]]$shell)
    print("")
    print("Et en listé lat puis lng")
    print(lat)
    print(lng)
    
    poly_test = list(Polygon(as.matrix(data.frame(lng, lat)))) %>% Polygons(ID = 1)
    poly_test = list(poly_test)
    #poly_test =list(poly_test@Polygons)
    print("")
    print("Et sous poly")
    #print(poly_test[[1]]@Polygons[[1]]@coords)
    
    
    df = data.frame('origin' = rep(origin, length(data)), 'departure' = rep(departure, length(data)),
    'range' = rep(range, length(data)))
    # comprendre cette ligne
    
    
    data = SpatialPolygons(poly_test, proj = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))
    #data = SpatialPolygons(poly_test, proj = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')) %>%
    #smooth(method = 'ksmooth', smoothness = 3)
    
    print("spatial poly df")
    data = SpatialPolygonsDataFrame(data, data = df, match.ID = FALSE)
    return(data)
}
