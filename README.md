# FinalProject

Description of the structure of the model:

Answer goes here.

What did the model prove?

We tested 5 different strategies in our model:
1. Player that never folds no matter what hand.
2. If after flop, you have only high card, then fold.
3. If after flop, you have straight or better, then never fold.
4. If you have best hand in the game before or after river, then never fold.
5. Player that stays in game no matter what until postRiver and then folds or raises based on hand (maybe 3 of a kind or better)

We then compared how these strategies perform against each other when being tested for different properties that the player's hand can have. The first property is isWinner. There, we check if there is any possible scenario where the player uses this strategy, and is able to win. The second property is alwaysWinner. There, we check if using this strategy the player will always win. The third property is neverFolds. There, we check if using that strategy there is a situation where the player can go all the way, and doesnt have to fold. The fourth property is alwaysNeverFolds. There, we check if using this strategy the player will always go until the last round. The Fifth property is low chance of winning, where, depending on the stage of the game and the score of the players hand, we give them a probability of winning, where a hand of strength below -2 is considered to give you a low chance of success.

Here are the main findings:

    1. The player that never folds no matter what hand, actually ends up winning a couple amount of times, as there were several instances for this case where the player won with a pair or highcard, mainly because the other players had really bad hands. Strategy number 5 is just a better version of never folding, because if you have a bad hand, then  you will fold and not 'waste your money'.
    2. We were reassured about the fact that if you have a strong hand, you have to go all the way through no matter what, even if here and there there is another player that beats you, you will win most of the time. We only got a couple of instances where a straight lost to a flush, but that was it. 
    3. The strategy of folding if you only have high card after the flop is not really effective. There were many instances were the player got a pair on the turn, or a flush after the river card, which would have made him win the hand. A lot can happen with the last two cards on the board, so ALWAYS folding when you only have a high card after the flop is not a good strategy.



What tradeoffs did you make in choosing your representation? What else did you try that didn’t work as well?

We made many different tradeoffs in our representation, usually after trying to implement a feature that was not working or realistic. One tradeoff we had to make was setting our representation to always be the initial round of a game of poker, where all players have the same amount of chips. We came with the initial idea that our model should be able to model any round of poker and all player's chips should be a random number, but upon trying to implement this idea it added a ton of complexity to betting, and caused too many bugs and setbacks for us to justify its implementation. Another tradeoff we made was completely scrapping the idea of using temporal forge to model our project. We spent the first one to two weeks attempting to utiliize temporal forge, but upon running into many bugs regarding transitioning between states, we switched to relational. Other things that we tried but were eventually unable to include in our model (usually due to bugs), were more robust player betting (allowing for re-raising, all-in'ing and split pots), including and tracking player's and the table's stacks of chips and implementing ante's and specific poker positions on a table.

What assumptions did you make about scope? What are the limits of your model?

Assumption answer goes here.

There are quite a few limits of our model that we acknowledge or even chose to include. One of our limits is that unfortunately in our model there is no difference between a pair of Kings and a pair of Two's. This is a very large part of real life poker, but given the time constraints we de-prioritized this functionality and were not able to eventually implement it. Another limit of our model, which we previously mentioned is that the betting mechanics are not fully realized. While betting works, in real life poker this is a big difference between raising and re-raising, but in our model those are essentially the same thing, as a value of the round bet is set and player's must either match it or fold.

Did your goals change at all from your proposal? Did you realize anything you planned was unrealistic, or that anything you thought was unrealistic was doable?

Our goals did change quite a bit from our proposal. Initially, our reach goal was to perfectly model a whole game of poker with everysingle rule and nuance that a game of Texas hold'em entails. However, upon beginning our work and especially after switching from temporal to relational forge, we realized this goal was massively unrealistic. We switched our goal to a more realistic target of modelling a single round of poker. Then inside of this singular round of poker we quickly realised that the ideal scenario of modelling niche rules (such as split pots or straddles) were unrealistic and we should focus our time and effort in implementing the core functionalities of Texas hold'em.

How should we understand an instance of your model and what your visualization shows (whether custom or default)?

In the default vizualizer, our model is extremely difficult to understand if you look at the graph tab. We highly recommend analyzing our model through the table tab, as this becomes much easier to read and understand (while still confusing at first). The main sigs to keep in mind are the fields of a RoundState. The players tell you which players remain in the round at which stages. You should notice that all 4 players are in the game at the beginning of the round (preFlop), but many of them have left the game (folded) at same point in the round, with often only having 1 or 2 players remaining in the game at (postFlop). Another thing to track is the score and hand tables as these tables tell you which hand belongs to which player and then also how strong each player's hand is (positive numbers correlate to strong hands, while negative numbers are weaker hands). Another important field to track is the winner field as this field indicates which player wins the game and in which roundstate they won. Another important field is the bet field. this fields value tells you what happened in regards to player's betting for that round. If the bet is 0, then all players checked, else if bet is not zero then a player raised, and all those that are remaining in the next state matched that bet. Finally the board and deck fields are important because these fields tell you which cards are shared by all players (the cards on the board) and the potential cards that could eventually be put on the board (cards in the deck). 

Custom vizualizer paragraph goes here.

Answer goes here.

Link to project video goes here:

Link

Screenshots of instances goes here: APPARENTLY THIS IS VERY IMPORTANT TO TIM FOR BOTH README AND FINAL PRESENTATION (at least 1 with only 1 player remaining postRiver (that player being the winner), at least 1 with multiple players remaining postRiver (and one with strongest hand being the winner), 1-2 screenshots of instances of the strategies mentioned above, 1-2 screenshots of interesting instances (something like royal flush is drawn or all players fold on postFlop so 1 player instantly wins)). We can and should rig these using specific run statements, but still need to show them. 

Screenshots

Screenshot of all tests passing: ALSO VERY IMPORTANT TO TIM ESPECIALLY BECAUSE TEST FILE TAKES FOREVER TO RUN (TIM USUALLY HAS PEOPLE RUN THE TEST FILE IN THE FINAL DEMO IN FRONT OF HIM)

Screenshots