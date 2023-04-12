# Isochrone Project - Communicating Data & Statistics

## &rarr; [Isochrone visualization App - Online version](http://gabriel-fiastre.shinyapps.io/Isochrone-vis-app?_ga=2.149344309.2094542299.1677432014-1284112226.1677265408)

## Description

Isochrones delimit lines of equal travel time from an origin. They are important to investigate how well connected a location is and have many applications, from improving transport networks to any location-based optimisation. This project presents a visualization tool that plots isochrones from an origin using a set of user-defined parameters and allows the export of the data as a basis for statistics. The isochrones are generated using the [TravelTime](https://traveltime.com/) API. The visualization is largely inspired by [Bethany Byollin's work](https://github.com/byollin/Isolines), but uses a more precise API, supports splitted isochrones (holes, islands) and provides additional data and computed statistics to the user such as the area of the isochrones.


## Usage
The app is available online [here](http://gabriel-fiastre.shinyapps.io/Isochrone-vis-app?_ga=2.149344309.2094542299.1677432014-1284112226.1677265408). It can also be run locally using the code provided in the repository : 
* Put your API key information (a free key can be obtained from the Traveltime website [here](https://traveltime.com/features/distance-matrix#sign-up-form)) in the **api_keys.json** file
* Run the server.R file 
* Tadam. This will generate a window presenting a map and the user menu on the left, as seen in the picture below. 

<img width="1470" alt="Capture d’écran 2023-02-28 à 00 06 26" src="https://user-images.githubusercontent.com/88781950/223112386-8955d3ea-7bd4-4390-b3b6-dc82b3d42e49.png">


The menu allows the user to select :
- **Origin** of the isochrone : latitude-longitude coordinates or by clicking on the map
- **Mode of transport** : among driving, public transport, cycling, and walking
- **Departure time** : takes into account traffic and scheduled public transport 
- **Time range** of the desired isochrones : minimum and maximum range representing respectively the smallest and largest isochrones, and interval size the intervals in minutes between these ranges for which the user wants isochrones. 

Once these parameters are set, use the **request isolines** button to generate the visualization.

The app will generate and plot the desired isochrones as seen in the image below. Isochrones are often composed of multiple polygons due to some areas being inaccessible during the set time (for instance here with the Seine splitting the isochrones in two parts). These polygons forming an isochrone are called **islands**. The area of each island, the total area of the isochrone and its associated time range are detailed when clicking on it.

<img width="1469" alt="Capture d’écran 2023-03-06 à 13 42 28" src="https://user-images.githubusercontent.com/88781950/223113612-46b84567-4ae4-4fcb-8311-1cc0ac346df3.png">

## Results
The data and computed statistics can also be exported using the **download results** button that appears once isochrones are generated. 
The data is exported as a zip file including the geographical data of the generated isochrones (**Spatial Polygon**), its parameters (**isochrone ID**, **origin**, **transport mode**, **departure time**, **time range**, ...) and the computed statistics. For now only the areas are supported but we are working on adding other metrics, in particular to quantify the symmetry or area distribution of isochrones.

The zip file contains 4 files in different formats containing the geographical data of the polygons composing the isochrones, and an additional results file in csv format with the isochrone parameters and statistics, each row representing an island.

### This data allows computation of basic statistics with many applications.
<img width="500" alt="plot_20min_transport" src=https://user-images.githubusercontent.com/88781950/231594915-60599f53-12ea-403b-8d96-bb6f625dd085.png>
Here is an (oversimplistic) example showing the evolution during a working day of the area reachable in 20min of public transports from the center of Paris.

## Authors
We are [Gabriel Fiastre](https://www.linkedin.com/in/gabriel-fiastre-4b5085184/) & [Shane Hoeberichts](https://www.linkedin.com/in/shane-hoeberichts-b249001b8/) , Machine learning & applied statistics students at Paris Dauphine & ENS (MASH master). This shiny app was part of a data visualization project for the course "Communicating Data & statistics" with [Andrew Gelman](http://www.stat.columbia.edu/~gelman/). We would like to thank [Bethany Yollin](https://github.com/byollin) as all of this work is largely inspired from her previous version.


