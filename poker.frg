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
                p not in pre.players => p not in post.players
                p in post.players => {
                    evaluateHand[p, post]
                    some p.hand.score[post]
                }
                some i : Int | (pre.bstate != preFlop) => {
                    i >= 0 and i <= 5 and pre.bet = i
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
                p not in pre.players => p not in post.players
                p in post.players => {
                    evaluateHand[p, post]
                    some p.hand.score[post]
                }
                some i : Int | (pre.bstate != preFlop) => {
                    i >= 0 and i <= 5 and pre.bet = i
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
                p not in pre.players => p not in post.players
                p in post.players => {
                    evaluateHand[p, post]
                    some p.hand.score[post]
                }
                some i : Int | (pre.bstate != preFlop) => {
                    i >= 0 and i <= 5 and pre.bet = i
                    #{pre.players} = 0 => i = 0
                }
            }
            all disj p1, p2 : post.players | {
                p1.hand.score[post] > p2.hand.score[post] => post.winner = p1
            } 
        }
    }
    all p : Player | {
        p not in pre.players => p not in post.players
        p in post.players <=> p in pre.players
    }
    //     some i : Int | (pre.bstate != preFlop) => {
    //         i >= 0 and i <= 5 and pre.bet = i
    //         #{pre.players} = 0 => i = 0
    //         // i >= 0 and i <= 3 and pre.bet = i and pre.pot = multiply[i, #{pre.players}]
    //         // p in post.players => (i in p.bets and p in pre.players)
    //         // p not in post.players => i not in p.bets
    //     }
    // }
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
        #{r : Rank | r in hand.rank and r = rank1} = 2
    }
}

/**
* This predicate checks if the player's best hand is a two pair.
* Param: p - a player
*/
pred hasTwoPair[hand: set Card] {
    some disj rank1, rank2 : Rank | {
        #{r : Rank | r in hand.rank and r = rank1} = 2 and #{r : Rank | r in hand.rank and r = rank2} = 2
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
        #{s : Suit | s in hand.suit and s = suit1} > 4
    }
}

/**
* This predicate checks if the player's best hand is a royal flush.
* Param: p - a player
*/
pred hasRoyalFlush[hand: set Card] {
    some i1, i2, i3, i4, i5 : Int | {
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
        #{r : Rank | r in hand.rank and r = rank1} = 4
    }
}

/**
* This predicate checks if the player's best hand is a three of a kind.
* Param: p - a player
*/
pred hasThreeofaKind[hand: set Card] {
    some rank1 : Rank | {
        #{r : Rank | r in hand.rank and r = rank1} = 3
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
    let bAndH = r.board + p.hand | {
        hasRoyalFlush[bAndH] => p.hand.score[r] = 5
        hasStraightFlush[bAndH] => p.hand.score[r] = 4 
        hasFourOfaKind[bAndH] => p.hand.score[r] = 3 
        hasFullHouse[bAndH] => p.hand.score[r] = 2
        hasFlush[bAndH] => p.hand.score[r] = 1
        hasStraight[bAndH] => p.hand.score[r] = 0
        hasThreeofaKind[bAndH] => p.hand.score[r] = -1
        hasTwoPair[bAndH] => p.hand.score[r] = -2
        hasPair[bAndH] => p.hand.score[r] = -3
    }

}

/**
* This instance is used to optimize the conversion between the rank and value of a card.
*/
inst optimize_rank {
    Rank = `Two + `Three + `Four + `Five + `Six + `Seven + `Eight + `Nine + `Ten + `Jack + `Queen + `King + `Ace
    Two = `Two
    `Two.value = (-8)
    Three = `Three
    `Three.value = (-7)
    Four = `Four
    `Four.value = (-6)
    Five = `Five
    `Five.value = (-5)
    Six = `Six
    `Six.value = (-4)
    Seven = `Seven
    `Seven.value = (-3)
    Eight = `Eight
    `Eight.value = (-2)
    Nine = `Nine
    `Nine.value = (-1)
    Ten = `Ten
    `Ten.value = (0)
    Jack = `Jack
    `Jack.value = (1)
    Queen = `Queen
    `Queen.value = (2)
    King = `King
    `King.value = (3)
    Ace = `Ace
    `Ace.value = (4)
}

run {
    uniqueCards
    wellformedCards
    playerRotation
    traces
} for exactly 13 Card, 4 Player, 5 Int for optimize_rank
