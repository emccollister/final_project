#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(janitor)
library(stargazer)
library(tidyverse)


pitchers_shiny <- read_csv("pitchers_shiny.csv")
names<- unique(pitchers_shiny$name)

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("readable"),
        
    navbarPage("Pitching Trends, 2012-2018",
   
   tabPanel("Player Trends",
      sidebarLayout(
        sidebarPanel(
         selectizeInput("name",
                     "Select a Player:",
                     choices = names,
                     selected = "Chris Sale"),
         br(),
         
         radioButtons("metric",
                     "Select a pitching metric:",
                     choices = c("Pitch Usage" = "Percent",
                                 "Pitch Velocity" = "Velocity")),
         br(),
         
         checkboxInput("add_success",
                       "Add a success variable?",
                       value = FALSE),
         
         selectInput("success",
                     label = NULL,
                      choices = c("K/9 innings" = "k_9",
                                  "Swinging Strike %" = "sw_str_pct",
                                  "Strike %" = "str_pct"))
                     
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("playerPlot")
              )
            )
          ),
   tabPanel("League-Wide Models",
      sidebarLayout(
        sidebarPanel(
          radioButtons("type",
                       "Position:",
                       choices = c("Starter" = "SP",
                                    "Reliever" = "RP")),
          selectInput("pitch",
                      "Select a pitch",
                      choices = c("Fastball" = "fastball",
                                  "Cutter" = "cutter",
                                  "Splitter" = "splitter",
                                  "Curveball" = "curveball",
                                  "Slow Curve" = "slow_curve",
                                  "Changeup" = "changeup",
                                  "Sinker" = "sinker",
                                  "Slider" = "slider",
                                  "Screwball" = "screwball",
                                  "Knuckleball" = "knuckleball")),
          selectInput("response",
                      "Select a response variable:",
                      choices = c("K/9 innings" = "k_9",
                                  "Swinging Strike %" = "sw_str_pct",
                                  "Strike %" = "str_pct"))),
          mainPanel(
            htmlOutput("leagueModel")
          )
        )
      )     
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  title_label <- reactive({
    req(input$name)
    title_label <- input$name
  })
  
  
  y2_label <- reactive({
    req(input$success)
    if(input$success == "k_9"){
      y2_label <- "Strikeouts per 9 Innings [Count]"
    } else if(input$success == "sw_str_pct"){
      y2_label <- "Swinging Strike Percentage [%]"
    } else if(input$success == "str_pct"){
      y2_label <- "Strike Percentage [%]"
    }}) 
  
  output$playerPlot <- renderPlot({
      
     if (input$add_success == TRUE) {
       pitchers_shiny %>%
         filter(name == input$name) %>% 
         ggplot(aes(x = year)) +
         geom_point(aes_string(y = input$metric, col = "pitch")) +
         geom_line(aes_string(y = input$metric, col = "pitch")) +
         geom_line(aes_string(y = input$success), col = "black") +
         scale_y_continuous(limits = c(0, 110), sec.axis = sec_axis(~. * 1, name = y2_label())) +
         scale_x_continuous(limits = c(2012, 2018)) +
         labs(title = title_label(),
              x = "Year",
              col = "Pitch")
     }
     
     else {
       pitchers_shiny %>%
         filter(name == input$name) %>% 
         ggplot(aes(x = year)) +
         geom_point(aes_string(y = input$metric, col = "pitch")) +
         geom_line(aes_string(y = input$metric, col = "pitch")) +
         scale_y_continuous(limits = c(0, 110)) +
         scale_x_continuous(limits = c(2012, 2018)) +
         labs(title = title_label(),
              x = "Year",
              col = "Pitch")
     }
   })
   
   output$leagueModel <- renderUI({
     
     fit_data <- pitchers_shiny %>%
       filter(type == input$type,
              pitch == input$pitch)
     
     
    if (input$response == "k_9")   {
      HTML(stargazer(lm(data = fit_data, 
                    k_9 ~ Percent + Velocity + Movement_X + Movement_Y), 
                    type = "html",
                    dep.var.labels = "Strikeouts per 9 Innings"
          )
      )
  }
     else if (input$response == "sw_str_pct")   {
       HTML(stargazer(lm(data = fit_data, 
                      sw_str_pct ~ Percent + Velocity + Movement_X + Movement_Y), 
                      type = "html",
                      dep.var.labels = "Swinging Strike Percentage"
          )
       )
    }
     
     else if (input$response == "str_pct")   {
       HTML(stargazer(lm(data = fit_data, 
                      str_pct ~ Percent + Velocity + Movement_X + Movement_Y), 
                      type = "html",
                      dep.var.labels = "Srike Percentage"
          )
       )
    }
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

