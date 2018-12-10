#
# Engineering Code Challenge
# 
# Create an R+Shiny web application that would help a user understand which
# US wind farms are most efficient. 

if (!requireNamespace('data.table')) {install.packages('data.table')}
if (!requireNamespace('shiny'))      {install.packages('shiny')}
if (!requireNamespace('leaflet'))    {install.packages('leaflet')}
if (!requireNamespace('dplyr'))    {install.packages('dplyr')}
library('data.table')
library('shiny')
library('leaflet')
library('dplyr')


prj <- readRDS(file.path('data', 'WebApplicationEngineer.rds'))

## Calculate 'net capacity factor':
prj$NetCapacityFactor <- prj[ ,GenerationMWhPerYear/(CapacityMW * 8760)]
prj$NetCapacityFactorPerc <- paste0(round(prj$NetCapacityFactor,2),"%")
prj$AverageGenerationMW <- prj[ ,GenerationMWhPerYear/8760]
prj$PopupInfo <- prj[ ,paste('<b>Name:</b>', Name, '<br>',
                            '<b>Average Generation (MW):</b>', round(AverageGenerationMW, 2), '<br>',
                            '<b>Maximum Capacity (MW):</b>', round(CapacityMW, 2), '<br>',
                            '<b>Net capacity factor:</b>', round(NetCapacityFactor,2))]

## Order by net capacity factor for plotting (the most efficienct farms will show up on the top):
setorder(prj, NetCapacityFactor, na.last=FALSE)

## Set color palette for plotting:
pal <- colorNumeric(
  palette = 'viridis',
  domain = prj$NetCapacityFactor
)


## Application UI:
ui <- fluidPage(
   
  ## Application title
  titlePanel('Dashboard: Wind Farm Efficiency'),
  
  p(paste0('Welcome! This dashboard shows the efficiency of wind farms in the ',
           'United States as defined by net capacity factor. The '),
    strong('net capacity factor '),
    paste0('of a farm is the average power it generates divided by the its ',
           'maximum power capacity. The larger the factor, the more ',
           'efficient the wind farm. Click on a given farm in the map to see more information, or ',
           'use the filtering options below the map to refine your search.')),
  
  leafletOutput('map'),
  
  hr(),
  
  fluidRow(
    column(12,
           h4('Map Filters')
    ),
    column(6,
           sliderInput('netCapacityFactor', 'Net Capacity Factor', 
                       min=round(min(prj$NetCapacityFactor, na.rm=TRUE),2), max=round(max(prj$NetCapacityFactor, na.rm=TRUE),2), 
                       value=c(round(min(prj$NetCapacityFactor, na.rm=TRUE),2), round(max(prj$NetCapacityFactor, na.rm=TRUE),2)), 
                       width='90%'),
           sliderInput('averageGenerationMW', 'Average Power Generation (MW)', 
                       min=floor(min(prj$AverageGenerationMW, na.rm=TRUE)), max=ceiling(max(prj$AverageGenerationMW, na.rm=TRUE)), 
                       value=c(floor(min(prj$AverageGenerationMW, na.rm=TRUE)), ceiling(max(prj$AverageGenerationMW, na.rm=TRUE))), 
                       width='90%'),
           sliderInput('capacityMW', 'Maximum Capacity (MW)', 
                       min=floor(min(prj$CapacityMW, na.rm=TRUE)), max=ceiling(max(prj$CapacityMW, na.rm=TRUE)), 
                       value=c(floor(min(prj$CapacityMW, na.rm=TRUE)), ceiling(max(prj$CapacityMW, na.rm=TRUE))), 
                       width='90%')
    ),
    column(5, offset = 0, 
           selectInput('windFarmName', 'Name', sort(unique(prj$Name)), multiple = TRUE, width='90%'),
           br(),
           p(strong('Missing Data Option:')),
           checkboxInput('allowMissing', 
                         paste0('Include wind farms with missing net capacity factors (these farms are ',
                                'not subject to filtering by average power generation or maximum capacity.)'),
                         width='100%')        
    )
  )
)

## Application server:
server <- function(input, output) {
   
  output$map <- renderLeaflet({

    if(input$allowMissing) {
      prj_filtered <- prj %>%
       dplyr::filter(is.na(NetCapacityFactor) |
                     (NetCapacityFactor >= input$netCapacityFactor[1] & NetCapacityFactor <= input$netCapacityFactor[2] &
                      AverageGenerationMW >= input$averageGenerationMW[1] & AverageGenerationMW <= input$averageGenerationMW[2] &
                      CapacityMW >= input$capacityMW[1] & CapacityMW <= input$capacityMW[2])
      )
    } else {
      prj_filtered <- prj %>%
        dplyr::filter(NetCapacityFactor >= input$netCapacityFactor[1] & NetCapacityFactor <= input$netCapacityFactor[2] &
                      AverageGenerationMW >= input$averageGenerationMW[1] & AverageGenerationMW <= input$averageGenerationMW[2] &
                      CapacityMW >= input$capacityMW[1] & CapacityMW <= input$capacityMW[2]
      )      
    }
    
    if(!is.null(input$windFarmName)) {
      prj_filtered <- prj_filtered %>%
        dplyr::filter(Name %in% input$windFarmName)
    }

    if(nrow(prj_filtered) > 0) {
      prj_filtered %>%
      leaflet() %>%
      addTiles() %>%
      addCircleMarkers(radius = ~ 6, 
                       lng = ~ Longitude, lat = ~ Latitude,
                       popup = ~ PopupInfo,
                       color = ~ pal(NetCapacityFactor),
                       stroke = ~ ifelse(!is.na(NetCapacityFactor), TRUE, FALSE),
                       fillOpacity = 0.5) %>%
      addLegend("bottomright", pal = pal, values = ~ NetCapacityFactor,
                title = "Net Capacity Factor",
                opacity = 1)
    } else{
      prj_filtered %>%
        leaflet() %>%
        addTiles()
    }

  })
}


## Run the application:
shinyApp(ui = ui, server = server)


