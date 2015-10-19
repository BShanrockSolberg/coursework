---
title       : Hold Them or Fold Them
subtitle    : Analyzing Stud Poker With Wildcards
author      : Bradley Shanrock-Solberg
job         : Freelance Data Scientist
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : zenburn       # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
--- 
<style> 
  .title-slide {
  background-image: url(http://pokernewsboy.com/wordpress/wp-content/uploads/2011/06/7-card-stud.jpg);
  background-repeat: repeat-x; 
  background-color: #0B6138; /*#0B6121 #0B610B;#0B3B17*/
  }
  .title-slide hgroup > h1, 
  .title-slide hgroup > h2,
  .title-slide hgroup > p
  {
    color: goldenrod;
  }
  body {
    background-color: #0B6138;
  }
  slide {
    background-color: #E6F8E0;
  }
</style>
## Hand Value in Stud Poker - the Key to Victory

### Basic Poker Strategy -  requires accurate Hand Value estimation
* My Hand:  How good is my hand already, and what are the odds of making it better?
* Expense:  Is my hand good enough to put more money in the pot and draw another card?  
* Other Hands:  Are any hands either already better or likely to beat me if they keep drawing?
* Stud Poker's 4-5 betting rounds & visible cards leaves more scope for skill 
than [Draw Poker](https://en.wikipedia.org/wiki/Draw_poker)

### What affects Hand Value?
* [5 card stud](https://en.wikipedia.org/wiki/5_Card_Stud) wins with much weaker hands 
than  [7 card stud](https://en.wikipedia.org/wiki/Seven-card_stud)
or [Texas Hold-Em](https://en.wikipedia.org/wiki/Texas_hold_'em)
* In a professional/casino game, # of players can shift suddenly, wildcards are banned
* in a private "friendly" game, # of wildcards can shift suddenly, but players are fixed
* The [Hold Them or Fold Them](https://solbergb.shinyapps.io/pokerapp) application explores
how Stud Poker hand values change

--- &twocol w1:40% w2:60%
## Example: Testing Hand Value by Game 
[Hold Them or Fold Them](https://solbergb.shinyapps.io/pokerapp)
tests [5 card stud](https://en.wikipedia.org/wiki/5_Card_Stud) 
vs  [Texas Hold-Em](https://en.wikipedia.org/wiki/Texas_hold_'em) with 4 players
and 0 wildcards.

*** =left

![plot of chunk unnamed-chunk-1](assets/fig/unnamed-chunk-1-1.png) 


*** =right

![plot of chunk unnamed-chunk-2](assets/fig/unnamed-chunk-2-1.png) 

--- &twocol w1:40% w2:60%
## Example: Testing Hand Value by Number of Players 
[Hold Them or Fold Them](https://solbergb.shinyapps.io/pokerapp)
tests 2 vs 7 players of [7 card stud](https://en.wikipedia.org/wiki/Seven-card_stud) 
with 0 wildcards.

*** =left

![plot of chunk unnamed-chunk-3](assets/fig/unnamed-chunk-3-1.png) 


*** =right

![plot of chunk unnamed-chunk-4](assets/fig/unnamed-chunk-4-1.png) 

--- &twocol w1:40% w2:60%
## Example: Testing Hand Value by Wildcards 
[Hold Them or Fold Them](https://solbergb.shinyapps.io/pokerapp)
tests 4 players of [Texas Hold-Em](https://en.wikipedia.org/wiki/Texas_hold_'em), 
normal vs Jokers & Dueces Wild.

*** =left

![plot of chunk unnamed-chunk-5](assets/fig/unnamed-chunk-5-1.png) 


*** =right

![plot of chunk unnamed-chunk-6](assets/fig/unnamed-chunk-6-1.png) 

