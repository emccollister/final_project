library(shiny)
library(janitor)
library(stargazer)
library(shinythemes)
library(tidyverse)


pitchers_shiny <- read_csv("pitchers_shiny.csv")

# Create list of every player name that appears in the data set, using unique
# as each name appears for every year there is data for it
names<- unique(pitchers_shiny$name)

# Define UI for final project app - investigating trends in pitching data
ui <- fluidPage(theme = shinytheme("yeti"),
   
  # Use navbarPage to create separate tabs with both unique inputs and outputs                   
  navbarPage("Pitching Trends, 2012-2018",
   
    # Tab comparing individual players with a sidebar layout, creating a side panel
    # for inputs and a main panel for outputs        
   tabPanel("Player Trends",
      sidebarLayout(
        sidebarPanel(
          
        # Used selectize input to allow for searching across entire list of names
        # This is useful given how many choices there are for this input
         selectizeInput("name",
                     "Select a Player:",
                     choices = names,
                     selected = "Chris Sale"),
        
          # br() adds vertical spacing 
         br(),
         
         # As there are only two choices, it seemed appropriate to use radio buttons 
         # instead of selectInput()
         radioButtons("metric",
                     "Select a pitching metric:",
                     choices = c("Pitch Usage" = "Percent",
                                 "Pitch Velocity" = "Velocity")),
         
         # Help text to provide user with mor information
          tags$h6(helpText("\"Pitch Usage\" shows how often a pitcher throws a certain pitch. \"Pitch Velocity\" refers to the speed at which a pitch is thrown, measured when it is released.")),
         
         # br() adds vertical spacing
         br(),
         
         # CheckboxInput() allows user to add an additional line of a success metric
         # Initially set to FALSE for aesthetic clarity
         checkboxInput("add_success",
                       "Add a metric for success?",
                       value = FALSE),
         
         # Allows user to add an additional line of a "success" metric
         selectInput("success",
                     label = "Chosen variable is plotted to the right in black",
                      choices = c("Strikeouts per 9 Innings" = "k_9",
                                  "Swinging Strike %" = "sw_str_pct",
                                  "Strike %" = "str_pct")),
         
         # Added text to clarify statistics and reasoning behind their inclusion
         tags$h6(helpText("Strikeouts per 9 innings is the most commonly used measure of a pitcher's ability to miss bats. Swinging Strike Percentage (measured out of total pitches) gives arguably a more 'true' statistic of this. Strike percentage gives an imperfect measure of a pitcher's accuracy.")),
         tags$h6(helpText("All three available measures are admittedly subjective and inherently flawed measures of success. Additionally, they aim to more address the dominance of the pitches themselves rather than the dominance of the pitcher. While the two are almost always correlated they are not necessarily the same. A great overall pitcher could, for example, have low strikeout or swing-and-miss numbers.")),
        
         # br() adds vertical spacing   
         br(),    
         
        tags$h6(helpText("All data from fangraphs.com"))
      ),
      
      # Show a plot of the generated plot
      mainPanel(
         plotOutput("playerPlot")
              )
            )
          ),
   
   # Creating a new tab of inputs/outputs for League Models
   tabPanel("League-Wide Models",
      sidebarLayout(
        sidebarPanel(
          
          # Filter for pitcher type
          radioButtons("type",
                       "Position:",
                       choices = c("Starter" = "SP",
                                    "Reliever" = "RP")),
       
          # Add clarifying text for user
          tags$h6(helpText("Positions are classified by whichever situation they've thrown more innings in.")),
          tags$h6(helpText("Starting pitchers begin games and aim to throw around 6 or more innings and 90 to 100 pitches. Relief pitchers will pitch anything from 1 at-bat to a few innings at a time.")),
          
          # br() creates vertical spacing
          br(),
          
          # Filter for pitch type
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
          
          br(),
          
          # Filter for a response variable
          selectInput("response",
                      "Select a response variable:",
                      choices = c("K/9 innings" = "k_9",
                                  "Swinging Strike %" = "sw_str_pct",
                                  "Strike %" = "str_pct")),
        
        # Add same clarifying text as from first tab
        tags$h6(helpText("Strikeouts per 9 innings is the most commonly used measure of a pitcher's ability to miss bats. Swinging Strike Percentage (measured out of total pitches) gives arguably a more 'true' statistic of this. Strike percentage gives an imperfect measure of a pitcher's accuracy.")),
        tags$h6(helpText("All three available measures are admittedly subjective and inherently flawed measures of success. Additionally, they aim to more address the dominance of the pitches themselves rather than the dominance of the pitcher. While the two are almost always correlated they are not necessarily the same. A great overall pitcher could, for example, have low strikeout or swing-and-miss numbers."))
      ),   
       # Creates main panel with the regression output
         mainPanel(
            htmlOutput("leagueModel")
          )
        )
      )     
    )
)


# Define server logic for app
server <- function(input, output) {
  
  # Reactively change plot title to match player name
  title_label <- reactive({
    req(input$name)
    title_label <- input$name
  })
  
  # Reactively change the second y-axis label to match chosen response variable
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
      
    # Employs if/else logic to add a line for a chosen success variable.
    # I put mapping into the geom_ function so as to creates separate mappings for pitch data
    # and success data. I've also graphed pitch data with both geom_point and geom_line 
    # so that pitches which only appear in one year (with rookies, for example) will still be visible.
    # I force the y-axis to go up to 110 so that the range of the graph will stay the same for every player
    # while still ensuring that the highest data (100+ MPH fastballs) will not be excluded. I added a second axis
    # when the checkbox is TRUE with a reactive variable name y2_label().
    
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
     
     # Filters data prior to model-fitting based on user-inputted position and pitch.
     fit_data <- pitchers_shiny %>%
       filter(type == input$type,
              pitch == input$pitch)
     
    # Employs if/else logic to create a model and regression output for each potential 
     # response variable
    if (input$response == "k_9")   {
      HTML(stargazer(lm(data = fit_data, 
                    k_9 ~ Percent + Velocity + Movement_X + Movement_Y), 
                    type = "html",
                    dep.var.labels = "Strikeouts per 9 Innings",
                    notes = "It is difficult to draw any significant conclusions from these models, as they are admittedly flawed. Judging from the R^2 values, none of the pitches are particularly explanatory to any of the response variables. This in not unsurprising, as, after all, we're regressing one pitch at a time. Unfortunately, it was not possible to regress all the pitches at once due to issues with multicollinearity.",
                    notes.align = "c"
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
                      dep.var.labels = "Strike Percentage"
          )
       )
    }
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

