# Isochrone Project - Communicating Data & Statistics

## Description

Isochrones delimit lines of equal travel time from an origin. They are important to investigate how well connected a location is and have many applications, from improving transport networks to any location-based optimisation, This project presents a visualization tool that plots isochrones from an origin using a set of user-defined parameters. The isochrones are generated using the TravelTime API (https://traveltime.com/). 


## Usage
To use the interactive map, run the server.R file. This will generate a window presenting a map and the user menu on the left, as seen in the picture below. 

![image](https://user-images.githubusercontent.com/73693706/220354645-8d04dccf-9ca8-4e46-a2bc-ffa989b5252c.png)


The menu allows the user to select 
- Origin of the isochrone (latitude-longitude coordinates or by clicking on the map), 
- Mode of transport (among driving, public transport, cycling, and walking),
- Departure time (takes into account traffic and scheduled public transport), 
- Times associated with the desired isochrones (minimum range representing the smallest isochrone, maximum the largest, and interval size the minute interval between these ranges for which the user wants isochrones). 

Once these parameters are set, use the request isolines button to generate the visualisation.


## Results


