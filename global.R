library(RJSONIO)
library(traveltimeR)

# ui modules
source('modules/ui/inline_block_css.R')
source('modules/ui/input_ui.R')
source('modules/ui/popup_boxes.R')
source('modules/ui/sidebar_panel.R')

# server modules
source('modules/server/error_message.R')
source('modules/server/isoline.R')
source('modules/server/validate_coords.R')
source('modules/server/validate_inputs.R')


# read api keys
keys = if(file.exists('api_keys.json')) {
  fromJSON('api_keys.json')   
} else {
  list('id' = NULL, 'key' = NULL)
}

#store your credentials in an environment variable
Sys.setenv(TRAVELTIME_ID = keys["id"])
Sys.setenv(TRAVELTIME_KEY = keys["key"])

#test
#departure_search <-
#  make_search(id = "public transport from Trafalgar Square",
#              departure_time = strftime(as.POSIXlt(Sys.time(), "UTC"), "%Y-%m-%dT%H:%M:%SZ"),
#              travel_time = 70,
#              coords = list(lat = 51.507609, lng = -0.128315),
#              transportation = list(type = "public_transport"),
#              properties = list('is_only_walking'))

#result <- time_map(departure_searches = departure_search)
#print(result)