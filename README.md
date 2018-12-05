# Final Project
Gov 1005 Final Project - Analyzing Pitching Trends from 2012 to 2018

## Topic: 
This project compares trends in pitch usage and velocity versus various measures of pitcher success.

## Motivation:
I wanted to provide both player-specific and league-wide visualization and analysis of pitch data. While the motivation for the player-specific section was largely to create an interesting exploratory tool, I also developed a few hypotheses for the league-wide data. I expected velocity to be a more significant predictor of success for relievers than starters given their decreased need for stamina. I expected pitch movement to be a more significant predictor of success for breaking balls than fast balls, and expected velocity to be more significant for fastballs than breaking balls. I also expected movement in the x and y axes to be more significant for different pitches depending on the way they are typically thrown.

## Background Information:
All the data used in this project comes from the website fangraphs.com. It is derived (with adjustments) from Pitch f/x data, which is the result of a relatively new and groundbreaking project in Major League Baseball in which varies measures are collected on every single pitch thrown in every single game. More info on Pitch f/x can be found [here](https://www.fangraphs.com/library/misc/pitch-fx/). A source of inspiration for the player-specific section of my app is [Brooks Baseball](http://www.brooksbaseball.net/velo.php?player=519242&time=&startDate=03/30/2007&endDate=12/05/2018&s_type=2), which is an incredible resource on pitch data.

## Findings
In some ways, it's challenging to sum up specifc findings for the player-specific section of my app. After all, there are over 1,040 pitchers represented, and each invidual's data says something about how they approach the game. With that said, a few things stand out. Sliders seem to be increasingly common, while sinkers are becoming less popular. Pitchers rely more on off-speed and breaking balls as they get farther into their career (and get older).Increasing non-fastball usage rates seem to lead to more strikeouts, although there are signifant exceptions to this as well. In terms of the league-wide data, I found it largely impossible to draw any real conclusions, as none of the pitches showed a R^2 value when used to explain a success variable. In retrospect, this is relativly unsurprising, as I was forced to look at at one pitch at a time. While theoretically it would have been better to put all pitches in a multiple regression model together, this was impossible due to massive issues with multicollinearity.

## Link to Shiny App Website
[https://emccollister.shinyapps.io/Pitching_Trends_2012_to_2018/](https://emccollister.shinyapps.io/Pitching_Trends_2012_to_2018/)
