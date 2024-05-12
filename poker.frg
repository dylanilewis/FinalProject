#lang forge 

// This sig represents the state of a round of poker. It contains the players, the deck, the board, the pot, the highest bet, the turn, and the next round state.
sig RoundState {
    bstate: one BoardState,
    players: set Player,
    deck: set Card,
    board: set Card,
    next: lone RoundState,
    winner: lone Player,
    bet: one Int
}

abstract sig BoardState{}

// These sigs represent the different states of a round of poker.
one sig preFlop, postFlop, postTurn, postRiver extends BoardState {}

// This sig represents a card. It contains a suit and a rank.
sig Card {
    suit: one Suit,
    rank: one Rank
}

// This sig represents a suit.
abstract sig Suit {}

// These sigs represent the different suits of a deck of cards.
one sig Clubs, Diamonds, Hearts, Spades extends Suit {}

// This sig represents a rank, which is a value from 2 to Ace.
abstract sig Rank {
    value: one Int
}

// These sigs represent the different ranks of a deck of cards.
one sig Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace extends Rank {}

// This sig represents a player. It contains a hand, chips, a bet, and the next player.
sig Player {
    hand: one Hand
}

// This sig represents a hand. It contains a set of cards and a score.
sig Hand {
    cards: set Card,
    score: pfunc RoundState -> Int
}

/**
* This predicate checks that all cards are unique.
*/
pred uniqueCards {
    all disj c1, c2 : Card | {
        not (c1.rank = c2.rank and c1.suit = c2.suit)
    }
}

/**
* This predicate ensures that all players are dealt 2 cards.
*/
pred dealCards {
    all p : Player | {
        some disj c1, c2 : Card | {
            p.hand.cards = c1 + c2
        }
        #{p.hand.cards} = 2
    }
    //all players have two different cards. Cards cannot be repeated among players
    all disj p1, p2 : Player | {
        p1.hand != p2.hand
        all c : Card | {
            (c in p1.hand.cards => c not in p2.hand.cards) and (c in p2.hand.cards => c not in p1.hand.cards)
        }
    }
    all r : RoundState | {
        all p : Player | {
            p.hand.cards = p.hand.cards
        }
    }
}

/**
* This predicate implements the logic of initializing a round of poker. It ensures the board is empty, the highest bet and pot are 0, 
* the players are dealt cards, the players have the correct amount of chips, and the turn is set to the first player.
* Param: r - a round state
*/
pred initRound[r : RoundState] {
    all p : Player | {
        p in r.players
        #{r.players} = 4
        evaluateHand[p, r]
        some p.hand.score[r]
    }
    r.bstate = preFlop
    r.board = none
    r.winner = none
    dealCards
    r.bet = 0
}

/**
* This predicate checks that a transition is valid. All players must have made a valid move and then the
* round state is updated to the next round state depending on the pre round state.
* Param: pre - the current round state
* Param: post - the next round state
*/
pred validTransition[pre : RoundState, post : RoundState] {
    pre.next = post
    all p: Player | {
        p not in pre.players => p not in post.players
    }
    some disj c1, c2, c3, c4, c5 : Card | {
        pre.bstate = preFlop implies {
            c1 + c2 + c3 in pre.deck
            post.bstate = postFlop
            post.board = c1 + c2 + c3
            #{post.board} = 3
            post.deck = pre.deck - c1 - c2 - c3
            post.winner = none
            #{pre.players} > 1 => #{post.players} >= 1
            all p : Player | {
                p in post.players => {
                    evaluateHand[p, post]
                    some p.hand.score[post]
                } else no p.hand.score[post]
                some i : Int | (pre.bstate != preFlop) => {
                    i >= 0 and i <= 5 and pre.bet = i
                    i = 0 => post.players = pre.players
                    #{pre.players} = 0 => i = 0
                }
            }
        }
        pre.bstate = postFlop implies {
            c4 in pre.deck
            post.bstate = postTurn
            post.board = pre.board + c4
            #{post.board} = 4
            post.deck = pre.deck - c4
            post.winner = none
            #{pre.players} > 1 => #{post.players} >= 1
            all p : Player | {
                p in post.players => {
                    evaluateHand[p, post]
                    some p.hand.score[post]
                } else no p.hand.score[post]
                some i : Int | (pre.bstate != preFlop) => {
                    i >= 0 and i <= 5 and pre.bet = i
                    i = 0 => post.players = pre.players
                    #{pre.players} = 0 => i = 0
                }
            }
        }
        pre.bstate = postTurn implies {
            c5 in pre.deck
            post.bstate = postRiver
            post.board = pre.board + c5
            #{post.board} = 5
            post.deck = pre.deck - c5
            #{pre.players} > 1 => #{post.players} >= 1
            all p : Player | {
                p in post.players => {
                    evaluateHand[p, post]
                    some p.hand.score[post]
                } else no p.hand.score[post]
                some i1, i2 : Int | (pre.bstate != preFlop) => {
                    i1 >= 0 and i1 <= 5 and i2 >= 0 and i2 <= 5 and pre.bet = i1 and post.bet = i2
                    i1 = 0 => post.players = pre.players
                    #{pre.players} = 0 => i1 = 0
                    #{post.players} = 0 => i2 = 0
                }
            }
            all disj p1, p2 : post.players | {
                p1.hand.score[post] >= p2.hand.score[post] => post.winner = p1
            } 
        }
    }
}

/**
* This predicate handles the logic of the overall game. It first initializes the game in its preflop state, it then checks
* that there is a winner in its final postRiver state. Then for all states in the game, it checks that there is a valid
* transition to the next state. Finally, it checks that once there is a winner the game stops and there are no new states. 
*/
pred traces {
    one preFlop : RoundState | {
        initRound[preFlop]
    }
    all r : RoundState | {
        all p : Player | {
            (#{r.players} = 1 and p in r.players) => r.winner = p
        }
        (r.bstate != postRiver) => validTransition[r, r.next]
    }
}

/**
* This predicate checks the deck, board and all player's hands are formed correctly.
*/
pred wellformedCards {
    all c : Card | {
        all r : RoundState | {
            c in r.deck => {
                all p : Player | {
                    c not in p.hand.cards
                    c not in r.board
                }
            }
            all p : Player | {
                c in r.board => {
                    c not in p.hand.cards
                    c not in r.deck
                }
            }
            some p : Player | {
                c in p.hand.cards => {
                    c not in r.deck
                    c not in r.board
                }
                c in p.hand.cards or c in r.deck or c in r.board
            }
        }
    }
}

/**
* This predicate checks if the player's best hand is a pair.
* Param: p - a player
*/
pred hasPair[hand: set Card]{
    some rank1 : Rank | {
        #{c : Card | c in hand and c.rank = rank1} = 2
    } 
}

/**
* This predicate checks if the player's best hand is a two pair.
* Param: p - a player
*/
pred hasTwoPair[hand: set Card] {
    some disj rank1, rank2 : Rank | {
        #{c : Card | c in hand and c.rank = rank1} = 3 and #{c : Card | c in hand and c.rank = rank2} = 2
    }
}

/**
* This predicate checks if the player's best hand is a full house.
* Param: p - a player
*/
pred hasFullHouse[hand: set Card] {
    hasThreeofaKind[hand] and hasPair[hand]
}

/**
* This predicate checks if the player's best hand is a straight.
* Param: p - a player
*/
pred hasStraight[hand: set Card] {
    some r1, r2, r3, r4, r5 : Rank | {
        // #{c : Card | c in hand and c.rank = rank1} = 2
        {r1 in hand.rank and r2.value = add[r1.value,1]
        r2 in hand.rank and r3.value = add[r2.value,1]
        r3 in hand.rank and r4.value = add[r3.value,1]
        r4 in hand.rank and r5.value = add[r4.value,1]
        r5 in hand.rank}
    }
}

/**
* This predicate checks if the player's best hand is a flush.
* Param: p - a player
*/
pred hasFlush[hand: set Card] {
    some suit1 : Suit | {
        #{c : Card | c in hand and c.suit = suit1} > 4
    }
}

/**
* This predicate checks if the player's best hand is a royal flush.
* Param: p - a player
*/
pred hasRoyalFlush[hand: set Card] {
    some i1, i2, i3, i4, i5 : Int | {
        // #{c : Card | c in hand and c.rank = rank1} = 2
        {hasStraightFlush[hand]
        Ace in hand.rank
        King in hand.rank
        Queen in hand.rank
        Jack in hand.rank
        Ten in hand.rank}
    }
}

/**
* This predicate checks if the player's best hand is a four of a kind.
* Param: p - a player
*/
pred hasFourOfaKind[hand: set Card] {
    some rank1 : Rank | {
        #{c : Card | c in hand and c.rank = rank1} = 4
    }
}

/**
* This predicate checks if the player's best hand is a three of a kind.
* Param: p - a player
*/
pred hasThreeofaKind[hand: set Card] {
    some rank1 : Rank | {
        #{c : Card | c in hand and c.rank = rank1} = 3
    }
}

/**
* This predicate checks if the player's best hand is a straight flush.
* Param: p - a player
*/
pred hasStraightFlush[hand: set Card] {
    hasStraight[hand] and hasFlush[hand]
}

/**
* This predicate checks if the player's best hand is a high card.
* Param: p - a player
*/
// pred hasHighCard[p : Player, r : RoundState] {
//     {not hasRoyalFlush[p, r]
//     not hasStraightFlush[p, r]
//     not hasFourOfaKind[p, r]
//     not hasFullHouse[p, r]
//     not hasFlush[p, r]
//     not hasStraight[p, r]
//     not hasThreeofaKind[p, r]
//     not hasTwoPair[p, r]
//     not hasPair[p, r]}
// }

/**
* This predicate checks the hand a player has and sets the players hand to the type of hand they have.
* Param: p - a player
*/
pred evaluateHand[p : Player, r : RoundState] {
    let bAndH = r.board + p.hand.cards | {
        hasRoyalFlush[bAndH] => p.hand.score[r] = 5
        else hasStraightFlush[bAndH] => p.hand.score[r] = 4 
        else hasFourOfaKind[bAndH] => p.hand.score[r] = 3 
        else hasFullHouse[bAndH] => p.hand.score[r] = 2
        else hasFlush[bAndH] => p.hand.score[r] = 1
        else hasStraight[bAndH] => p.hand.score[r] = 0
        else hasThreeofaKind[bAndH] => p.hand.score[r] = -1
        else hasTwoPair[bAndH] => p.hand.score[r] = -2
        else hasPair[bAndH] => p.hand.score[r] = -3
        else p.hand.score[r] = -4
    }

}

inst optimize_rank {
    Rank = `TwoTest + `ThreeTest + `FourTest + `FiveTest + `SixTest + `SevenTest + `EightTest + `NineTest + `TenTest + `JackTest + `QueenTest + `KingTest + `AceTest
    Two = `TwoTest
    `TwoTest.value = (-8)
    Three = `ThreeTest
    `ThreeTest.value = (-7)
    Four = `FourTest
    `FourTest.value = (-6)
    Five = `FiveTest
    `FiveTest.value = (-5)
    Six = `SixTest
    `SixTest.value = (-4)
    Seven = `SevenTest
    `SevenTest.value = (-3)
    Eight = `EightTest
    `EightTest.value = (-2)
    Nine = `NineTest
    `NineTest.value = (-1)
    Ten = `TenTest
    `TenTest.value = (0)
    Jack = `JackTest
    `JackTest.value = (1)
    Queen = `QueenTest
    `QueenTest.value = (2)
    King = `KingTest
    `KingTest.value = (3)
    Ace = `AceTest
    `AceTest.value = (4)
    Suit = `ClubsTest + `DiamondsTest + `HeartsTest + `SpadesTest
    Clubs = `ClubsTest
    Diamonds = `DiamondsTest
    Hearts = `HeartsTest
    Spades = `SpadesTest
    Card = `Card1Test + `Card2Test + `Card3Test + `Card4Test + `Card5Test + `Card6Test + `Card7Test + `Card8Test + `Card9Test + `Card10Test + `Card11Test + `Card12Test + `Card13Test
    `Card1Test.suit = Clubs
    `Card1Test.rank = Two
    `Card2Test.suit = Clubs
    `Card2Test.rank = Three
    `Card3Test.suit = Diamonds
    `Card3Test.rank = Ten
    `Card4Test.suit = Hearts
    `Card4Test.rank = Ten
    `Card5Test.suit = Spades
    `Card5Test.rank = Queen
    `Card6Test.suit = Clubs
    `Card6Test.rank = Ten
    `Card7Test.suit = Diamonds
    `Card7Test.rank = Jack
    `Card8Test.suit = Hearts
    `Card8Test.rank = Queen
    `Card9Test.suit = Spades
    `Card9Test.rank = Six
    `Card10Test.suit = Clubs
    `Card10Test.rank = Six
    `Card11Test.suit = Diamonds
    `Card11Test.rank = Seven
    `Card12Test.suit = Spades
    `Card12Test.rank = Ten
    `Card13Test.suit = Spades
    `Card13Test.rank = Ace
    Player = `Player1Test + `Player2Test + `Player3Test + `Player4Test
    Hand = `Hand1Test + `Hand2Test + `Hand3Test + `Hand4Test
    `Player1Test.hand = `Hand1Test
    `Hand1Test.cards = `Card3Test + `Card4Test
    RoundState = `RoundState1Test + `RoundState2Test + `RoundState3Test + `RoundState4Test
    // BoardState = `preFlopTest + `postFlopTest + `postTurnTest + `postRiverTest
    // preFlop = `preFlopTest
    // `RoundState1Test.bstate = preFlop
    // postFlop = `postFlopTest
    // postTurn = `postTurnTest
    // postRiver = `postRiverTest
    // `RoundState2Test.bstate = postFlop
    // `RoundState3Test.bstate = postTurn
    // `RoundState4Test.bstate = postRiver
    `RoundState4Test.board = `Card8Test + `Card9Test + `Card10Test + `Card11Test + `Card12Test
}

// run {
//     uniqueCards
//     wellformedCards
//     traces
//     some r : RoundState | r.winner != none
// } for exactly 13 Card, 4 Player, 5 Int for optimize_rank


// Example of a strategy that we need to create (if start with any pocket pair, then never fold)
// (I am not fully confident this works, i.e I have not checked this runs, but this is the idea and it will be close to functional)
// run {
//     uniqueCards
//     wellformedCards
//     traces
//     all p : Player | some r : RoundState | {r = preFlop and p.hand.score[r] = -3} => {
//         all r : RoundState {
//             p in r.players
//         }
//     }
// } for exactly 13 Card, 4 Player, 5 Int

/* My ideas for other strategies that need to be created.

VERY IMPORTANT TO TIM:
Run like 10 instances of each strategy and record wins/losses and money gained/money lost overall, use the betting values * num of players in state to calculate.
(Can be done with all players or one player, yall's choice, maybe best for tracking wins with 1 player though)
Then write about best/most interesting ones in readme and include screenshots of an instance from a couple of them (make sure screenshots do not have bugs in them)
This is our property verification alongside writing tests for each predicate (also need to include screenshot of all tests passing in readme and have it preloaded for final presentation)

1. Player that never folds no matter what hand.
2. If after flop, you have only high card, then fold.
3. If ever get fullHouse or better for any roundstate never fold
4. If after flop, you have straight or better, then never fold.
5. Player that stays in game no matter what until postRiver and then folds or raises based on hand (maybe 3 of a kind or better)
6. Think of more strategies that can be implemented. (maybe some around mid hands like pair, 2 pair and 3 of a king)
*/

pred neverFolds[p: Player] {
    all r : RoundState | {
        p in r.players
    }
}

pred highCardFold[p: Player] {
        some r : RoundState | {
            r.bstate = postFlop
            p.hand.score[r] = -4
            p not in r.next.players
        }
    }

pred straightOrBetter[p: Player] {
        some r1: RoundState | {
            r1.bstate = postFlop
            p.hand.score[r1] >= 0
        }
        all r2: RoundState | {
            p in r2.players
        }
    }

pred bestHandInTheGame[p: Player] {
    some disj r1, r2 : RoundState | {
            r1.bstate = postFlop
            p.hand.score[r1] = 5
            r2.bstate = postRiver
            p in r1.next.players
            p in r2.players
        }
}

pred postRiverFold[p: Player] {
    some r : RoundState | {
        (r.bstate = postRiver and p.hand.score[r] < 0)
        p not in r.next.players

    }
}

pred strategyTesting{
    traces
    uniqueCards
    wellformedCards
    some r : RoundState | r.winner != none
}

run {
    uniqueCards
    wellformedCards
    traces
    some r : RoundState | r.winner != none
    // neverFolds
    // highCardFold
    // straightOrBetter
    // bestHandInTheGame
    // postRiverFold
} for exactly 13 Card, 4 Player, 4 Int for optimize_rank