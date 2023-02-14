#' popup_boxes
#' 
#' Popup boxes containing information about the application.
#' 
#' @return HTML

popup_boxes = function() {
    div(
        # help #########################################################################################################
        absolutePanel(id = 'clear_panel', bottom = 6, left = 510,
            dropdownButton(icon = icon('question'), size = 'sm', up = TRUE, width = '700px', inputId = 'help',
                h2('Map isolines for anywhere in the world!'),
                hr(),
                div(style = 'display: inline-block; vertical-align: bottom; min-width: 100%;',
                    column(6, style = 'padding-left: 0',
                        h4('What is an isoline?', style = 'margin-top: 0;'),
                        p('The prefix "iso", draws its meaning from Ancient Greek meaning "same" or "equal". Each line \
                          on an isoline map shares the same value. An isochrone is a special type of isoline that \
                          visualizes travel time. This application shows lines of equal travel time or equal network \
                          distance for mode choices of driving or walking. Click anywhere on the map and see \
                          isochrones!', style = 'font-size: 14px;')
                    ),
                    column(6,
                        img(src = 'example.png', style = 'height: 250px; display: block; margin-bottom: 20px; \
                                                         margin-right: auto; margin-left: auto;')
                    )
                )               
            )
        ),
        #  about #######################################################################################################
        absolutePanel(id = 'clear_panel', bottom = 6, left = 560,
            dropdownButton(icon = icon('info'), size = 'sm', up = TRUE, width = '700px',
                h2('About this application'),
                hr(),
                div(style = 'display: inline-block; vertical-align: bottom; min-width: 100%;',
                   column(12, style = 'padding-left: 0',
                        h4('Data source', style = 'margin-top: 0;'),
                        tags$span('This application sends requests to the ', 
                                  tags$a('TRAVELTIME isochrone API.',href = paste0('https://traveltime.com/features/isochrones'),
                                                                            target = '_blank'),
                                  'Responses are then post-processed before displaying on the map.',
                                  style = 'font-size: 14px;'),
                            h4('Application author', style = 'margin-top: 10px;'),
                            tags$span('Hi,we are',
                                      tags$a('Gabriel Fiastre', href = 'https://www.linkedin.com/in/gabriel-fiastre-4b5085184/',
                                      target = '_blank'),
                                      ' & ',
                                      tags$a('Shane Hoeberichts', href = 'https://www.linkedin.com/in/shane-hoeberichts-b249001b8/',
                                             target = '_blank'),
                                      'We are Machine learning & applied statistics students (M2 MASH) at Paris Dauphine & ENS. 
                                      This shiny app was part of a data visualization project.', style = 'font-size: 14px;')
                    ),
                    #column(6,
                    #    img(src = 'travelTime_color.png', style = 'align:middle;height: 50px; display: block; margin-top:25%; \
                    #                                  margin-right: auto; margin-left: auto;')
                    #)
                )
            )
        )
    )
}