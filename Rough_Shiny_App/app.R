
library(shiny)
library(tidyverse)
pitchers_all <- read_csv("pitchers_all.csv")
# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Fastball Velocity by Year"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         selectInput(inputId = "year",
                     label = "Year:",
                     choices = c("2018",
                                 "2017",
                                 "2016",
                                 "2015",
                                 "2014",
                                 "2013",
                                 "2012"))
      ),          
         # selectInput(inputId = "pitch_type",
         #             label = "Pitch",
         #             choices = names(pitchers_all)
         #               #pitchers_all %>%
         #                         # select(v_fa_pfx:v_kn_pfx)
      
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("veloPlot")
      )
   )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$veloPlot <- renderPlot({
     
      x <- pitchers_all %>%
              filter(year == input$year) %>%
              select(v_fa_pfx)
      
      ggplot(data = x, aes(x = v_fa_pfx)) +
        geom_histogram(binwidth = 1.5, na.rm = TRUE) + 
        geom_vline(aes(xintercept = mean(v_fa_pfx, na.rm = TRUE)), show.legend = TRUE, col = "red", size = 2) +
        scale_x_continuous(limits = c(85, 105)) +
        labs(x = "Fastball Velocity (MPH)",
             y = "Count",
             title = "Fastball Velocity by Year",
             caption = "Red line represents mean velocity")
      
   })
}


# Run the application 
shinyApp(ui = ui, server = server)

