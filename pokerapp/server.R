library(shiny)

#  This file contains the WinningHand code which drives
#  most of the application
source("poker.R")

# begin the Shiny code
shinyServer(
  function(input, output) {
    output$bestHands <- renderPlot({
      # generate the data for the graph
      winGraph <- data.frame(Hand = "X", Value = 0, Wildcard = 0,
                           stringsAsFactors = FALSE)
      set.seed <- input$seed
      for (i in 1:input$iterations) {
        winGraph[i,1:3] <- WinningHand(input$players,input$game,
          ifelse(sum(input$wildcards == "jokers") == 0, FALSE, TRUE),
          ifelse(sum(input$wildcards == "suicideKing") == 0, FALSE, TRUE),
          ifelse(sum(input$wildcards == "oneEyedJacks") == 0, FALSE, TRUE), 
          ifelse(sum(input$wildcards == "deuces") == 0, FALSE, TRUE))
      }
      winFactors <- c("Tie", "hCard", "Pair","hPair", "2Pair", 
              "h2Pair", "3Kind", "h3Kind", "Straight", 
              "hStraight", "Flush", "hFlush", "FullHs", 
              "hFullHs", "4Kind", "h4Kind", "StrFlush", 
              "hStrFlush", "5Kind", "h5Kind")
      wildCards <- unique(winGraph$Wildcard)
      winCount <- table(factor(winGraph$Hand, levels = winFactors))
      winConf <- cumsum(winCount/input$iterations)

      # plot the graph
      par(las=2, cex.axis = .9, cex.lab=1)
      barplot(winConf, ylab = "Confidence",  col = "Beige",
              sub = paste("Dealt",input$iterations, 
                         "hands with seed =", input$seed), 
              main = paste(input$game,"with", input$players,
                           "players &", wildCards, "Wildcards"))
      abline(h=.2, col="red", lwd=2)
      text(x=1.5,y=.17,label="Fold", col = "Red")
      abline(h=.4, col="orange", lwd=2)
      text(x=1.8,y=.37,label="Bluffing", col = "Orange")
      abline(h=.6, col="magenta", lwd=2)
      text(x=1.8,y=.57,label="Careful", col = "Magenta")
      abline(h=.8, col="purple", lwd=2)
      text(x=2.1,y=.77,label="Solid Hand", col = "Purple")
      abline(h=1, col="blue", lwd=4)
      text(x=2.1,y=.95,label="Sure Thing", col = "Blue") })
  }
)