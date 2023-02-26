#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



########### WHEN RUNNING FOR THE FIRST TIME

# install.packages(shiny)
# install.packages(shinyjs)
# install.packages(shinyBS)
# install.packages(shinyWidgets)
# install.packages(shinythemes)
# install.packages(shinycssloaders)
# install.packages(dplyr)
# install.packages(leaflet)

library(shiny)
library(shinyjs)
library(shinyBS)
library(shinyWidgets)
library(shinythemes)
library(shinycssloaders)
library(dplyr)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  useShinyjs(),
  title='Isochrone vis app',
  div(class = "title-panel","ISOCHRONE VISUALIZATION APP"),
  #titlePanel('Isochrone vis app'), 
  windowTitle = 'ISOCHRONES',
  theme = shinytheme('yeti'), 
  tabPanel(title = 'Isochrones vis app',
           # map panel ########################################################################################################
           div(class = 'outer',
               # additional css
               tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'styles.css')),
               tags$head(tags$link(rel = 'stylesheet', type = 'text/css', href = 'ion.rangeSlider.skinSquare.css')),
               # coordinate panel
               absolutePanel(id = 'coord_panel', top = 30, right = 8, width = 'auto',
                             pre(id = 'coords', '48.858132, 2.294515')),
               
               
               # app help and information
               popup_boxes(),
               
               # map
               leafletOutput('map', width = '100%', height = '100%'),
               # spinner
               div(id = 'spinner',
                   div() %>% withSpinner(type = 8, proxy.height = '400px', color = '#333d47')
               )
           ),
           # sidebar panel ####################################################################################################
           fixedPanel(top = 0, left = 0, width = 500, height = '100%',
                      sidebar_panel()
           )
  )))
