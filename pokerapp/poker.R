################################################################################
BestStraight <- function(hand) {
#  This is a utility function used to calculate if a straight
#  is possible, and if possible, the highest card in the straight
#
#  inputs - a "hand" data frame from WinningHand function
# 
#  outputs - 0 if a straight is not possible, otherwise
#            a number from 6 to 14, indicating the top card
#  
  sWild <- sum(hand$value == "W")
  sNum <- sort(as.numeric(unique(hand[hand$value != "W",]$value)))
  bStraight <- 0
  if ((length(sNum) + sWild) >= 5) {
    for (i in length(sNum):(5-sWild)) {
      if ((sNum[i] - sNum[i-4+sWild]) <= 4) {
        bStraight <- sNum[i] + sWild
      } # end test to allow a straight 
    } # end loop through top cards in hand
  } # not enough unique cards for straight
  # if higher than 14, return 14
  ifelse(bStraight > 14, 14, bStraight)
} # End function BestStraight ##################################################

WinningHand <- function(players, game = "7 Card Stud", 
                        jokers = FALSE, suicideKing = FALSE, 
                        oneEyedJacks = FALSE, deuces = FALSE) {
#  This program calculates the winning hand in several forms of popular
#  poker, assuming every player at the table stays in until the final card.
#  A wide variety of wildcards are allowed, but draw poker is not, as it
#  involves tactics in the draw and would need extra logic.
#
#  inputs - # of players, type of game, several wild card booleans
# 
#  outputs - a list with two columns:
#            Hand: is a short description of the best hand.  It is
#                  prefixed with "h" if the second best hand was of
#                  the same type, but not as strong
#                  For analysis, use this for ordered factor labels:
#                      c("Tie", "hCard", "Pair","hPair", "2Pair", 
#                        "h2Pair", "3Kind", "h3Kind", "Straight", 
#                        "hStraight", "Flush", "hFlush", "FullHs", 
#                        "hFullHs", "4Kind", "h4Kind", "StrFlush", 
#                        "hStrFlush", "5Kind", "h5Kind")
#            Value: A unique numeric value used to break ties within
#                   hands.  If identical between first and second
#                   rank player, the "Hand" variable is set to "Tie"
#  

                        
  deck <- data.frame(card=as.vector(c(replicate(4,c(2:10,"J","Q","K","A")),
                                      "W","W")),
                     value=as.vector(c(replicate(4,2:14),"W","W")),
                     suit=c(replicate(13,"H"), replicate(13,"D"),
                            replicate(13,"S"), replicate(13,"C"),"W","W"))

  # Adjust the deck for wildcards
  dsize <- ifelse(jokers,54,52)
  if(suicideKing) {
    deck[12,] <- "W"
  }
  if (oneEyedJacks) {
    deck[c(10,36),] <- "W"
  }
  if (deuces) {
    deck[deck$card == "2",] <- "W"
  }
  wildCards <- sum(deck[1:dsize,]$card == "W")

  # Deal the hands
  hands <- deck[1,]
  hands<- NULL
  if(game =="Texas Hold-Em") {
    cards <- deck[sample(1:dsize,3*players+4),]
    for (i in 1:players) {
      hands[[i]] <- cards[c(1:4,(4+i*3-2):(4+i*3)),] 
    }
  } else {
    draw <- ifelse(game == "5 Card Stud",5,7)
    cards <-  deck[sample(1:dsize,draw*players),]
    for (i in 1:players) {
      hands[[i]] <- cards[(i*draw-draw+1):(i*draw),] 
    }
  }
  bestHand <- data.frame(Hand = replicate(players,NA),
                         Value = replicate(players,0))

  for (i in 1:players) {
  # Debug Code
  #   print(hands[[i]])
  ## calculate "number of a kind" type hands
    wild <- sum(hands[[i]]$value == "W")
    if (wild >= 5) {
      ofKind <- c(5, 14)
    } else {
      knam <- names(table(hands[[i]]$value))
      kind <- table(hands[[i]]$value)[knam[knam != "W"]] + wild
      kind <- kind[kind == max(kind)]
      ofKind <- c(kind[1], max(as.numeric(names(kind))))
      kknam <- knam[knam != "W" & knam != ofKind[2]]
      kicker <- data.frame(num = table(hands[[i]]$value)[kknam],
                           value = as.numeric(kknam))
    }
    names(ofKind) <- c("num", "value")
  ## test 5 of a kind
    if (ofKind["num"] == 5) {
      bestHand$Hand[i] <- "5Kind"
      bestHand$Value[i] <- 9000 + 50*ofKind["value"]
      next
    }

  ## test straightflush 
    suits <- table(hands[[i]]$suit)
    if (!is.na(suits["W"])) {
     suits <- suits[1:(length(suits)-1)] + suits["W"]
    }
    flSuits <- suits[suits >= 5]
    if (length(flSuits) > 0) {
      flHand <- hands
      flHand <- NULL
      sfHand <- flHand
      for (j in 1:length(flSuits)) {
        flHand[[j]] <- hands[[i]][hands[[i]]$suit %in% 
                                c("W",names(flSuits[j])), ]
        # 3 wildcard case only applies to straight flushes,
        # because 4 kind trumps flush.  Unlike a straight flush,
        # values can't be duplicated so the straight value alone
        # determines how good the straight-flush can be.
        if (wild == 3) {
          # only 2 real values remain, "W" sorts to end of vector
          gap <- as.numeric(as.vector(sort(flHand[[j]]$value)[1:2]))
          if ((max(gap) - min(gap)) > 4) {
            sfHand[[j]] <- 0
          } else  {
            # with this many wildcards, the smallest real card 
            # sets the value of the straight's highest card
            sfHand[[j]] <- ifelse(min(gap)+5 > 14, 14, min(gap)+5)
          } 
        } else {
          sfHand[[j]] <- BestStraight(flHand[[j]])
        }
      }
      if (max(sfHand) > 0) {
        bestHand$Hand[i]  <- "StrFlush"
        bestHand$Value[i] <- 8000 + max(sfHand)
        next
      }
    }


  ## calculate "4Kind"
    if (ofKind["num"] == 4) {
        bestHand$Hand[i]  <- "4Kind"
        bestHand$Value[i] <- 7000 + 50*ofKind["value"] + max(kicker["value"])
        next
    }  

  ## test"fullHouse"
    if (ofKind["num"] == 3 & max(kicker[,"num"]) > 1) {
       maxkicker <- max(kicker[kicker$num > 1, ]$value)
       bestHand$Hand[i] <- "FullHs"
       bestHand$Value[i] <- 6000 + 50*ofKind["value"] + maxkicker
       next
    } 

    ## test "Flush"
    if (length(flSuits) > 0) {
      flSum <- replicate(length(flSuits), 0)
      for (j in 1:length(flSuits)) {
        flHand[[j]] <- hands[[i]][hands[[i]]$suit %in% 
                                c("W",names(flSuits[j])), ]
        if (wild > 0) {
          flHand[[j]][flHand[[j]]$suit == "W",]$value <- 14
        }
        flNum <- sort(as.numeric(as.vector(flHand[[j]]$value)),
                    decreasing = TRUE)
        flSum[j] <- sum(flNum[1:5] * c(60,5.5,.5,.045,.004))
      }
      bestHand$Hand[i] <- "Flush"
      bestHand$Value[i] <- 5000 + max(flSum[j])
      next
    } 
    ## calculate "Straight"
    bsSum <- BestStraight(hands[[i]])
    if(bsSum > 0) {
      bestHand$Hand[i] <- "Straight"
      bestHand$Value[i] <- 4000 + bsSum
      next
    }

    ## calculate 3 of a kind  
    if (ofKind["num"] == 3) {
      kicker <- sort(kicker$value, decreasing = TRUE)
      bestHand$Hand[i] <- "3Kind"
      bestHand$Value[i] <- 3000 + 50*ofKind["value"] + sum(kicker[1:2])
      next
    }

    ## calculate 2 pair
    if (ofKind["num"] == 2  & max(kicker[,"num"]) > 1) {
      lowpair <- max(kicker[kicker$num > 1, ]$value)
      kicker <- kicker[kicker$value != lowpair, ] 
      kicker <- sort(kicker$value,decreasing = TRUE)
      bestHand$Hand[i] <- "2Pair"
      bestHand$Value[i] <- 2000 + 50*ofKind["value"] + 
                           10*lowpair + max(kicker)
      next
    }
  
  ## calculate pair  
    if (ofKind["num"] == 2) {
      kicker <- sort(kicker$value, decreasing = TRUE)
      bestHand$Hand[i] <- "Pair"
      bestHand$Value[i] <- 1000 + 50*ofKind["value"] + sum(kicker[1:3])
    } else {  # High Cards in sequence take the pot
      handNum <- sort(as.numeric(as.vector(hands[[i]]$value)),
                  decreasing = TRUE)[1:5]
      bestHand$Hand[i]  <- "Card"
      bestHand$Value[i] <- sum(handNum * c(60,5.5,.5,.045,.004))
    }
  } # end loop through players
  bestHand <- bestHand[order(-bestHand$Value), ]
  winHand <- bestHand[1, ]
  if (bestHand$Value[1] == bestHand$Value[2]) {
    winHand$Hand[1] <- "Tie"
  } else  {
    if (bestHand$Hand[1] == bestHand$Hand[2]) {
      winHand$Hand[1] <- paste("h",bestHand$Hand[1],sep="")
    }  # end of check for same hand higher value
  }  # end of check for tie
  winHand$Wildcard <- wildCards
  winHand
} #  end of Winning Hand function



