#Define UI for shiny app
shinyUI(fluidPage(
  
  # Application title
  titlePanel("DS Project Nico, Alex"),
  titlePanel("Interactive Crime Statistics Visualization"),
  
  # Sidebar with an example slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("time",
                  "Time Interval:",
                  min = as.Date("2015-01-01","%Y-%m-%d"),
                  max = as.Date("2015-12-31","%Y-%m-%d"),
                  value = c(as.Date("2015-01-01","%Y-%m-%d"), as.Date("2015-12-31","%Y-%m-%d"))),
      sliderInput("lat",
                  "Center of Focus (Latitude):",
                  min = 40.5,
                  max = 40.9,
                  value = 40.7),
      sliderInput("lon",
                  "Center of Focus (Longitude):",
                  min = -74.3,
                  max = -73.7,
                  value = -73.95),
      sliderInput("zoom",
                  "Zoom Level",
                  min = 8,
                  max = 12,
                  value = 10),
      checkboxGroupInput("cb","Types of Crime",c("FELONY", "MISDEMEANOR", "VIOLATION"),selected = c("FELONY","MISDEMEANOR","VIOLATION"))
    ),
    
    # Show a plot of the generated map
    mainPanel(
      plotOutput("map")
    )
  )
))