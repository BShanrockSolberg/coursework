library(shiny)

# Text used in the UI later
gameList <- c("Texas Hold-Em","5 Card Stud","7 Card Stud")
spiel <- "This application is intended to show which hand will win a poker"
spiel <- paste(spiel,"game if all players stay in.  The number of")
spiel <- paste(spiel,"players, wild cards and type of game all have")
spiel <- paste(spiel,"a significant effect.  In a casino, watch the")
spiel <- paste(spiel,"changes in player numbers.  In a weekend game")
spiel <- paste(spiel,"with friends the changes in wild cards are")
spiel <- paste(spiel,"more likely to suddenly affect the odds.")
hhand <- "If only the highest hand won, it is prefixed with a lower"
hhand <- paste(hhand, "case h.  For example, 3Kind means nobody else")
hhand <- paste(hhand, "had a 3 of a Kind, but h3Kind means there was")
hhand <- paste(hhand, "at least one more at the table, so higher cards")
hhand <- paste(hhand, "were needed to win.  If you have less than Aces")
hhand <- paste(hhand, "be more cautions if in a high hand situation.")
confd <- "For example, confidence for a Straight includes its own wins,"
confd <- paste(confd, "as well as wins from 3Kind, 2Pair, Pair, etc.")

# Begin Shiny UI
shinyUI(pageWithSidebar(
  headerPanel("Hold Them or Fold Them - Stud Poker with Wildcards"),
  sidebarPanel(
    h2("Set up the Game"),
    selectInput("game", label = "Name the Game", choices = gameList),
    numericInput("players", "How Many Players? (2-7)", 
                  4, min = 2, max = 7, step = 1),
    checkboxGroupInput("wildcards", "Pick the Wildcards",
      c("Jokers (+2 Cards to Deck)" = "jokers",
        "Suicide King (King of Hearts)" = "suicideKing",
        "One-Eyed Jacks (Jack of Hearts & Spades)" = "oneEyedJacks",
        "Deuces (every suit of 2)" = "deuces" )),
    h2("Statistical Settings"),
    numericInput("iterations", "Number of Hands (per player)", 
                  100, min = 50, max = 1000, step = 50),
    p(" - note: results will take longer as hands & players increase"),
    numericInput("seed", "Stack the Deck (random # seed)", 
                  50, min = 1, max = 100, step = 1)
  ),
  mainPanel(
    h3("What makes a good Poker hand?"),
    p(spiel),
    h4("In the graph below, hands get stronger from left to right"),
    p(hhand),
    h4("Confidence Bar = % chance that type of hand would win"),
    p(confd),
    plotOutput("bestHands")
  )
))