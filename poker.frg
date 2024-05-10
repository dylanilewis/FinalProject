#lang forge 

// This sig represents the state of a round of poker. It contains the players, the deck, the board, the pot, the highest bet, the turn, and the next round state.
sig RoundState {
    bstate: one BoardState,
    players: set Player,
    deck: set Card,
    board: set Card,
    // pot: one Int,
    turn: one Player,
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
    hand: one Hand,
    // chips: one Int,
    // bets: set Int,
    nextPlayer: one Player
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
    // r.pot = 0
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
            #{post.players} > 1
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
                p1.hand.score[post] > p2.hand.score[post] => post.winner = p1
            } 
        }
    }
    all p : Player | {
        p not in pre.players => p not in post.players
        // p in post.players <=> p in pre.players
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
        some p : Player | {
            (#{r.players} = 1 and p in r.players) => r.winner = p
        }
        (r.bstate != postRiver) => validTransition[r, r.next]
        // (r.winner != none or #{r.players} = 0 or r.bstate != postRiver) => validTransition[r, r.next]
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
* This predicate checks that all players are reachable from each other, meaning there is a cycle of players.
*/
pred playerRotation {
    all p1, p2 : Player | {
        reachable[p1, p2, nextPlayer]
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
    some r1 : Rank | some c1, c2, c3, c4, c5 : Card | {
        {c1 in hand and c1.rank = r1
        c2 in hand and c2.rank.value = add[r1.value, 1]
        c3 in hand and c3.rank.value = add[r1.value, 2]
        c4 in hand and c4.rank.value = add[r1.value, 3]
        c5 in hand and c5.rank.value = add[r1.value, 4]}
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
    some c1, c2, c3, c4, c5 : Card | {
        {hasStraightFlush[hand]
        c1 in hand and c1.rank = Ace
        c2 in hand and c2.rank = King
        c3 in hand and c3.rank = Queen
        c4 in hand and c4.rank = Jack
        c5 in hand and c5.rank = Ten}
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

/**
* This instance is used to optimize the conversion between the rank and value of a card.
*/
inst optimize_rank {
    Rank = `Two0 + `Three0 + `Four0 + `Five0 + `Six0 + `Seven0 + `Eight0 + `Nine0 + `Ten0 + `Jack0 + `Queen0 + `King0 + `Ace0
    Two = `Two0
    `Two0.value = (-8)
    Three = `Three0
    `Three0.value = (-7)
    Four = `Four0
    `Four0.value = (-6)
    Five = `Five0
    `Five0.value = (-5)
    Six = `Six0
    `Six0.value = (-4)
    Seven = `Seven0
    `Seven0.value = (-3)
    Eight = `Eight0
    `Eight0.value = (-2)
    Nine = `Nine0
    `Nine0.value = (-1)
    Ten = `Ten0
    `Ten0.value = (0)
    Jack = `Jack0
    `Jack0.value = (1)
    Queen = `Queen0
    `Queen0.value = (2)
    King = `King0
    `King0.value = (3)
    Ace = `Ace0
    `Ace0.value = (4)
}

run {
    uniqueCards
    wellformedCards
    playerRotation
    traces
} for exactly 13 Card, 4 Player, 5 Int for optimize_rank


// Example of a strategy that we need to create (if start with any pocket pair, then never fold)
// (I am not fully confident this works, i.e I have not checked this runs, but this is the idea and it will be close to functional)
// run {
//     uniqueCards
//     wellformedCards
//     playerRotation
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