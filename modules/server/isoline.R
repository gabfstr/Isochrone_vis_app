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
                  #single_shape=TRUE,
                  level_of_detail=list(scale_type='simple', level='low')
                  )
    
    result <- time_map(departure_searches = departure_search)
    
    print(paste0("Length de shape : ",length(result$contentParsed$results[[1]]$shapes)))
    
    poly_test<-c()
    for(i in 1:length(result$contentParsed$results[[1]]$shapes)){
      #rajouter boucle sur i for pour les ilots
      lat<-c()
      lng<-c()
      for (e in result$contentParsed$results[[1]]$shapes[[i]]$shell) {
        lat<-append(lat,e$lat)
        lng<-append(lng,e$lng)
      }
    poly_1 = list(Polygon(as.matrix(data.frame(lng, lat)))) %>% Polygons(ID = i)
    poly_test<-append(poly_test,poly_1)
    #poly_test =list(poly_test@Polygons)
    #print(poly_test[[1]]@Polygons[[1]]@coords)
    #print(st_area(poly_test[[1]]@Polygon))
    }
    print("poly_test : ")
    print(poly_test)
    
    df = data.frame('origin' = rep(origin, length(poly_test)), 'departure' = rep(departure, length(poly_test)),
    'range' = rep(range, length(poly_test)))

    
    print(length(poly_test))
    data1 = SpatialPolygons(poly_test, proj = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))
    #data = SpatialPolygons(poly_test, proj = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')) %>%
    #smooth(method = 'ksmooth', smoothness = 3)
    
    data2 = SpatialPolygonsDataFrame(data1, data = df, match.ID = FALSE)

    
    df2 = data.frame('origin' = rep(origin, length(poly_test)), 'departure' = rep(departure, length(poly_test)),
                    'range' = rep(range, length(poly_test)), 'area_m2'=areaPolygon(data2))
    data3 = SpatialPolygons(poly_test, proj = CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'))
    data3 = SpatialPolygonsDataFrame(data3, data = df2, match.ID = FALSE)
    
    return(data3)
}
