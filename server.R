library(shiny)
if(!require(plyr)){install.packages("plyr");require(plyr)}
if(!require(dplyr)){install.packages("dplyr");require(dplyr)}
if(!require(data.table)){install.packages("data.table");require(data.table)}
if(!require(stringr)){install.packages("stringr");require(stringr)}
if(!require(ggplot2)){install.packages("ggplot2");require(ggplot2)}
if(!require(leaflet)){install.packages("leaflet");require(leaflet)}
if(!require(sp)){install.packages("sp");require(sp)}
if(!require(ggmap)){if(!require("devtools")){install.packages("devtools");require(devtools)};devtools::install_github("dkahle/ggmap", dep=F);require(ggmap)}
# ggmap version 2.7+ required, use devtools::install_github('dkahle/ggmap', dep=F)

if(!require(rgeos)){install.packages("rgeos");require(rgeos)}
if(!require(maptools)){install.packages("maptools");require(maptools)}
if(!require(broom)){install.packages("broom");require(broom)}
if(!require(httr)){install.packages("httr");require(httr)}
if(!require(rgdal)){install.packages("rgdal");require(rgdal)}
if(!require(spData)){install.packages("spData");require(spData)}
if(!require(tigris)){install.packages("tigris");require(tigris)}
#To run app, just click "Run App" or "Reload App" in top right of text editor of RStudio
# Define server logic required to draw a histogram
#To stop server, click "STOP" in the top right of the console

options(warn=-1)

crime_data <- read.csv("dt_with_neighborhoods.csv",header = TRUE)
r <- GET('http://data.beta.nyc//dataset/0ff93d2d-90ba-457c-9f7e-39e47bf2ac5f/resource/35dd04fb-81b3-479b-a074-a27a37888ce7/download/d085e2f8d0b54d4590b1e7d1f35594c1pediacitiesnycneighborhoods.geojson')
nyc_neighborhoods <- readOGR(content(r,'text'), 'OGRGeoJSON', verbose = F)

selectedX <- "123"
selectedY <- "456"

shinyServer(function(input, output) {
  output$map <- renderPlot({
    crime_data_dates <- crime_data[as.Date(crime_data$RPT_DT,"%m/%d/%Y") >= as.Date(input$time[1],"%Y-%m-%d") & as.Date(crime_data$RPT_DT,"%m/%d/%Y") <= as.Date(input$time[2],"%Y-%m-%d"),]

    crime_data_input <- crime_data_dates[crime_data_dates$LAW_CAT_CD %in% input$cb,]
    
    #if(nrow(crime_data_input)>0) {
      points <- crime_data_input[,c("Latitude","Longitude")]
      points <- points[which(!is.na(points$Latitude)),]
      points <- points[which(!is.na(points$Longitude)),]
      
      points_spdf <- points
      coordinates(points_spdf) <- ~Longitude + Latitude
      proj4string(points_spdf) <- proj4string(nyc_neighborhoods)
      matches <- over(points_spdf, nyc_neighborhoods)
      points <- cbind(points, matches)
      
      points_by_neighborhood <- points %>%
        group_by(neighborhood) %>%
        dplyr::summarize(num_points=n())
      
      register_google(key = Sys.getenv("GOOGLE_KEY")) # ggmap version 2.7+ required, use devtools::install_github('dkahle/ggmap', dep=F)
      
      manhattan_map <- get_map(location = c(lon = input$lon, lat = input$lat), zoom = input$zoom)
      
      plot_data <- tidy(nyc_neighborhoods, region="neighborhood") %>%
        left_join(., points_by_neighborhood, by=c("id"="neighborhood")) %>%
        filter(!is.na(num_points))
      
      ggmap(manhattan_map) + 
        geom_polygon(data=plot_data, aes(x=long, y=lat, group=group, fill=num_points), alpha=0.75) + 
        scale_fill_gradient(low="yellow", high="red") + ggtitle("Total Crimes of Selected Type Over the Selected Time Period per Neighborhood in NYC") +
        xlab("Longitude") + ylab("Latitude") + labs(fill="Number of Crimes")
    #}
  },width=850,height=850)
})