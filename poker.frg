#lang forge/temporal

// This sig represents the state of a round of poker. It contains the players, the deck, the board, the pot, the highest bet, the turn, and the next round state.
abstract sig RoundState {
    players: set Player,
    deck: set Card,
    board: set Card,
    pot: one Int,
    highestBet: one Int,
    turn: one Player
    // next: lone RoundState
}   

// These sigs represent the different states of a round of poker.
one sig preFlop, postFlop, postTurn, postRiver extends RoundState {}

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
    chips: one Int,
    bet: one Int,
    nextPlayer: one Player
}

// This sig represents a hand. It contains a set of cards and a score.
sig Hand {
    cards: set Card,
    score: one Int
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
        some c1,c2 : Card | {
            p.hand.cards = c1 + c2 implies {c1 != c2}
            }
        #(p.hand.cards) = 2
    }
        //all players have two different cards. Cards cannot be repeated among players
    all disj p1, p2 : Player | {
            p1.hand.cards != p2.hand.cards
        }
}

/**
* This predicate implements the logic of initializing a round of poker. It ensures the board is empty, the highest bet and pot are 0, 
* the players are dealt cards, the players have the correct amount of chips, and the turn is set to the first player.
* Param: r - a round state
*/
pred initRound[r : RoundState] {
    r = preFlop
    r.board = none
    r.highestBet = 0
    r.pot = 0
    dealCards
    // r' = postFlop
    all p : Player | {
        p.bet = 0
        p.chips = 5
    }
    one p : Player | {
        p = r.turn
    }
}

/**
* This predicate implements the needed constraints for a winner to be named. A player must either be the 
* last remaining player or have the best hand at the end of the round.
* Param: r - a round state
*/
pred winner[r : RoundState] {
    some p : Player {
        ((#(r.players) = 1) and (p in r.players)) or {
            all disj p1, p2 : Player | {
                r = postRiver
                p1.hand.score >= p2.hand.score
                p1.chips = add[p1.chips, r.pot]
            }
        }
        p.chips = add[p.chips, r.pot]
    }
}

/**
* This predicate checks that a turn is valid. If a player can play, they must play. If they cannot play, they must fold.
* After a move is made the turn is updated to the next player.
* Param: r - a round state
*/
pred validTurn[r : RoundState] {
    canPlay[r] implies playerAction[r] else playerFolds
    r.turn' = r.turn.nextPlayer
}

/**
* This predicate checks that a transition is valid. All players must have made a valid move and then the
* round state is updated to the next round state depending on the pre round state.
* Param: pre - the current round state
* Param: post - the next round state
*/
pred validTransition[pre : RoundState, post : RoundState] {
    all p : Player | {
        validTurn[pre]
    }
    pre' = post
    pre = preFlop implies post = postFlop
    pre = postFlop implies post = postTurn
    pre = postTurn implies post = postRiver
    some disj c1, c2, c3, c4, c5 : Card | {
        (pre = preFlop and post = postFlop) implies {
        pre.board = none
        (post.board = c1 + c2 + c3 and #(post.board) = 3)}
        (pre = postFlop and post = postTurn) implies (post.board = pre.board + c4 and #(post.board) = 4)
        (pre = postTurn and post = postRiver) implies (post.board = pre.board + c5 and #(post.board) = 5)
    }
    // pre = preFlop implies {
    //     pre.next = postFlop
    //     post = postFlop
    //     #{c : Card | c in pre.board} = 0
    //     #{c : Card | c in post.board} = 3
    // }
    // pre = postFlop implies {
    //     pre.next = postTurn
    //     post = postTurn
    //     #{c : Card | c in pre.board} = 3
    //     #{c : Card | c in post.board} = 4
    // }
    // pre = postTurn implies {
    //     pre.next = postRiver
    //     post = postRiver
    //     #{c : Card | c in pre.board} = 4
    //     #{c : Card | c in post.board} = 5
    // }
}

/**
* This predicate implements the constraints for a player to be able to play. It must be a players turn, 
* the player must still be in the game, and a player must either have more than 0 chips or their current bet must
* be equal to the highest bet.
* Param: r - a round state
*/
pred canPlay[r : RoundState] {
    some p: Player | {
        r.turn = p 
        p in r.players
        p.chips > 0 or p.bet = r.highestBet
    }
}

/**
* This predicate implements the logic of a player folding. The player is removed from the round state and will remain
* removed until the round is over.
*/
pred playerFolds {
    some p : Player | some r : RoundState | {
        r.players = r.players - p
    }
}

/**
* This predicate implements the logic of a player checking. Their current bet must be equal to the highest bet, and
* the players bet remains the same.
*/
pred playerChecks {
    some p : Player | some s : RoundState | {(p.bet = s.highestBet) {
        p.bet = p.bet
    }}
}

/**
* This predicate implements the logic of a player calling. The player must have more than 0 chips, and their bet is set
* to the highest bet. The players chips are updated and the pot is updated.
*/
pred playerCalls {
    some p : Player | some s : RoundState | {(p.chips > 0) and (subtract[s.highestBet, p.bet] <= p.chips) {
        p.bet = s.highestBet
        p.chips = add[subtract[p.chips, s.highestBet], p.bet]
        s.pot = subtract[add[s.pot, s.highestBet], p.bet]
    }}
}

/**
* This predicate implements the logic of a player raising. The player must have more than 0 chips, and their new bet must be 
* greater than the highest bet. The players chips are updated, the pot is updated, and the highest bet is updated.
*/
pred playerRaises {
    some p : Player | some s : RoundState | some i : Int | {(p.chips > 0) and (i > s.highestBet) and (i <= p.chips) {
        p.bet = i
        p.chips = subtract[p.chips, i]
        s.pot = add[s.pot, i]
        s.highestBet = i
    }}
}

/**
* This predicate implements the logic of a player going all in. The player must have more than 0 chips, and their bet is set
* to their remaining chips. The players remaining chips are set to 0 and the pot is updated.
*/
pred playerAllIns {
    some p : Player | some s : RoundState | {(p.chips > 0) {
        p.bet = add[p.bet, p.chips]
        p.chips = 0
        s.pot = add[s.pot, p.bet]
    }}
}

/**
* This predicate checks if the player has a valid action to take. Calling 4 of the above player action predicates. 
* Param: r - a round state
*/
pred playerAction[r : RoundState] {
    playerChecks or playerCalls or playerRaises or playerAllIns
}