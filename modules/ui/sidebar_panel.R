#' sidebar_panel
#' 
#' Sidebar panel for Shiny application.
#' 
#' @return HTML

sidebar_panel = function() {
    wellPanel(id = 'controls',
        # origin #######################################################################################################
        input_ui(input_id = 'origin',
                 input_element = textInput('origin', label = 'Origin:',
                                           placeholder = 'Origin (e.g., 48.858132, 2.294515)', width = '100%'),
                 help = paste0('Center of the isoline request. Isoline will cover all roads which can be reached from ',
                               'this point within given range. Click on the map to select an origin or type a ',
                               'latitude/longitude separated by a comma.')),
        # departure date ###############################################################################################
        input_ui(input_id = 'departure',
                 input_element = airDatepickerInput('departure', label = 'Departure date:', width = '100%',
                                                    value = Sys.Date()),
                 help = paste0('Date when travel is expected to start. Traffic speed and incidents are taken into ',
                               'account when calculating the route. Departure time can be past, present or future.')),
        # departure time ###############################################################################################
        input_ui(input_id = 'time',
                 input_element = sliderInput('time', 'Time range: ', min = 0, max = 23, post = ':00', step = 1,
                                             value = 17),
                 help = paste0('Time when travel is expected to start. Traffic speed and incidents are taken into ',
                               'account when calculating the route. Departure time can be past, present or future.'),
                 margin = 18),
        # mode #########################################################################################################
        input_ui(input_id = 'mode',
                 input_element = radioGroupButtons('mode', label = 'Mode:',
                                                   choices = c(`<img src="car.png", height = 14px>` = 'driving',
                                                               `<img src="transit2.png", height = 17px, style = "margin-top: -2px;margin-bottom: -1px">` = 'public_transport',
                                                               `<img src="bicycle.png", height = 30px, style = "margin-top: -8px;margin-bottom: -8px">` = 'cycling',
                                                               `<img src="ped.png", height = 16px, style = "margin-top: -2px;">` = 'walking'),
                                                   selected = 'driving', justified = TRUE, size = 'normal'),
                 help = 'This option controls the mode type. Possible values are driving (car), public_transport (Bus, Subway), cycling (bicycle)  or walking (pedestrian).',
                 margin = 8),
        
        # range ########################################################################################################
        div(style = inline_block_css(),
            column(5, style = 'padding-left: 0',
                numericInput('min', label = 'Minimum range:', min = 1, step = 1, value = 20)
            ),
            column(5, style = 'padding-left: 0; margin-left: 12px;',
                numericInput('max', label = 'Maximum range:', min = 1, step = 1, value = 35)
            ),
            column(1, style = 'margin-top: 4px; margin-left: 12px;',
                br(),
                actionButton('range_help', NULL, icon = icon('question', lib = 'font-awesome')),
                bsPopover('range_help', placement = 'right', trigger = 'focus', title = NULL,
                          content = 'Range of isoline. For distance the unit is miles. For time the unit is minutes.')
            )
        ),
        # step #########################################################################################################
        input_ui(input_id = 'step',
                 input_element = numericInput('step', label = 'Interval size:', min = 1, step = 1, value = 5),
                 help = paste0('Interval size between each isoline : the unit ',
                               'is minutes.')),
        actionButton('request', label = 'Request isolines', width = '100%'),
        downloadButton('download', label = 'Download results', class = list(width = '100%')) %>% hidden(),
        # clear map button (start hidden)
        actionButton('clear_map', label = 'Clear map', width = '100%') %>% hidden()
    )
}
