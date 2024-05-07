#lang forge 

// This sig represents the state of a round of poker. It contains the players, the deck, the board, the pot, the highest bet, the turn, and the next round state.
sig RoundState {
    bstate: one BoardState,
    players: set Player,
    deck: set Card,
    board: set Card,
    pot: one Int,
    highestBet: one Int,
    turn: one Player,
    next: lone RoundState
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
    all p : Player | p in r.players and #{r.players} = 4 and p.hand.score = -5
    r.bstate = preFlop
    r.board = none
    r.highestBet = 0
    r.pot = 0
    dealCards
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
pred winner {
    some r : RoundState | {
        #{r.players} = 1 or {
            r.bstate = postRiver
            all p : Player | p in r.players <=> evaluateHand[p]
            all disj p1, p2 : Player | {
                p1.hand.score > p2.hand.score
            } 
        }
    }
}

/**
* This predicate checks that a turn is valid. If a player can play, they must play. If they cannot play, they must fold.
* After a move is made the turn is updated to the next player.
* Param: r - a round state
*/
pred validTurn[r : RoundState] {
    canPlay[r] implies playerAction[r] else playerFolds
    r.turn = r.turn.nextPlayer
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
            // post.highestBet = 0
        }
        pre.bstate = postFlop implies {
            c4 in pre.deck
            post.bstate = postTurn
            post.board = pre.board + c4
            #{post.board} = 4
            post.deck = pre.deck - c4
            // post.highestBet = 0
        }
        pre.bstate = postTurn implies {
            c5 in pre.deck
            post.bstate = postRiver
            post.board = pre.board + c5
            #{post.board} = 5
            post.deck = pre.deck - c5
            // post.highestBet = 0
        }
    }
    all p : Player | {
        p not in pre.players implies p not in post.players
        p in pre.players <=> validTurn[pre]
    }
}

/**
* This predicate implements the constraints for a player to be able to play. It must be a players turn, 
* the player must still be in the game, and a player must either have more than 0 chips or their current bet must
* be equal to the highest bet.
* Param: r - a round state
*/
pred canPlay[r : RoundState] {
    some p : Player | {
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
    some p : Player | some s : RoundState | {
        s.players = s.players - p
        s.pot = s.pot
        s.highestBet = s.highestBet
        p.bet = p.bet
        p.chips = p.chips
    }
}

/**
* This predicate implements the logic of a player checking. Their current bet must be equal to the highest bet, and
* the players bet remains the same.
*/
pred playerChecks {
    some p : Player | some s : RoundState | {(p.bet = s.highestBet) {
        s.players = s.players
        s.pot = s.pot
        s.highestBet = s.highestBet
        p.bet = p.bet
        p.chips = p.chips
    }}
}

/**
* TODO: DECIDE WHETHER P.BET IS BET FOR THAT ROUND OR THE WHOLE GAME
* This predicate implements the logic of a player calling. The player must have more than 0 chips, and their bet is set
* to the highest bet. The players chips are updated and the pot is updated.
*/
pred playerCalls {
    some p : Player | some s : RoundState | {(p.chips > 0) and (subtract[p.chips, s.highestBet] >= 0) {
        s.players = s.players
        s.pot = add[subtract[s.highestBet, p.bet], s.pot]
        s.highestBet = s.highestBet
        p.bet = s.highestBet
        p.chips = subtract[p.chips, subtract[s.highestBet, p.bet]]
    }}
}

/**
* This predicate implements the logic of a player raising. The player must have more than 0 chips, and their new bet must be 
* greater than the highest bet. The players chips are updated, the pot is updated, and the highest bet is updated.
*/
pred playerRaises {
    some p : Player | some s : RoundState | some i : Int | {(p.chips > 0) and (i > s.highestBet) and (i <= p.chips) {
        s.players = s.players
        s.pot = add[s.pot, i]
        s.highestBet = i
        p.bet = add[p.bet, i]
        p.chips = subtract[p.chips, i]
    }}
}

/**
* This predicate implements the logic of a player going all in. The player must have more than 0 chips, and their bet is set
* to their remaining chips. The players remaining chips are set to 0 and the pot is updated.
*/
pred playerAllIns {
    some p : Player | some s : RoundState | {(p.chips > 0) {
        s.players = s.players
        s.pot = add[s.pot, p.chips]
        p.bet > s.highestBet implies s.highestBet = p.bet
        p.bet = add[p.bet, p.chips]
        p.chips = 0
    }}
}

/**
* This predicate checks if the player has a valid action to take. Calling 4 of the above player action predicates. 
* Param: r - a round state
*/
pred playerAction[r : RoundState] {
    playerChecks or playerCalls or playerRaises or playerAllIns
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
    // one r : RoundState | {
    //     winner
    // }
    all r : RoundState | {
        (r.bstate != postTurn) implies validTransition[r, r.next]
        // winner implies no r.next
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
pred hasPair[p : Player] {
    some r : RoundState | some rank1 : Rank | {
        p.hand = r.board + p.hand
        #{r : Rank | r in p.hand.cards.rank and r = rank1} = 2
    }
}

/**
* This predicate checks if the player's best hand is a two pair.
* Param: p - a player
*/
pred hasTwoPair[p : Player] {
    some r : RoundState | some disj rank1, rank2 : Rank | {
        p.hand = r.board + p.hand
        #{r : Rank | r in p.hand.cards.rank and r = rank1} = 2 and #{r : Rank | r in p.hand.cards.rank and r = rank2} = 2
    }
}

/**
* This predicate checks if the player's best hand is a full house.
* Param: p - a player
*/
pred hasFullHouse[p : Player] {
    hasThreeofaKind[p] and hasPair[p]
}

/**
* This predicate checks if the player's best hand is a straight.
* Param: p - a player
*/
pred hasStraight[p : Player] {
    some r : RoundState | some r1, r2, r3, r4, r5 : Rank | {
        p.hand = r.board + p.hand
        r1 in p.hand.cards.rank and r2.value = add[r1.value,1]
        r2 in p.hand.cards.rank and r3.value = add[r2.value,1]
        r3 in p.hand.cards.rank and r4.value = add[r3.value,1]
        r4 in p.hand.cards.rank and r5.value = add[r4.value,1]
        r5 in p.hand.cards.rank
    }
}

/**
* This predicate checks if the player's best hand is a flush.
* Param: p - a player
*/
pred hasFlush[p : Player] {
    some r : RoundState | some suit1 : Suit | {
        p.hand = r.board + p.hand
        #{s : Suit | s in p.hand.cards.suit and s = suit1} > 4
    }
}

/**
* This predicate checks if the player's best hand is a royal flush.
* Param: p - a player
*/
pred hasRoyalFlush[p : Player] {
    some r : RoundState | some i1, i2, i3, i4, i5 : Int | {
        hasStraightFlush[p]
        p.hand = r.board + p.hand
        Ace in p.hand.cards.rank
        King in p.hand.cards.rank
        Queen in p.hand.cards.rank
        Jack in p.hand.cards.rank
        Ten in p.hand.cards.rank
    }
}

/**
* This predicate checks if the player's best hand is a four of a kind.
* Param: p - a player
*/
pred hasFourOfaKind[p : Player] {
    some r: RoundState | some rank1 : Rank | {
        p.hand = r.board + p.hand
        #{r : Rank | r in p.hand.cards.rank and r = rank1} = 4
    }
}

/**
* This predicate checks if the player's best hand is a three of a kind.
* Param: p - a player
*/
pred hasThreeofaKind[p : Player] {
    some r: RoundState | some rank1 : Rank | {
        p.hand = r.board + p.hand
        #{r : Rank | r in p.hand.cards.rank and r = rank1} = 3
    }
}

/**
* This predicate checks if the player's best hand is a straight flush.
* Param: p - a player
*/
pred hasStraightFlush[p : Player] {
    hasStraight[p] and hasFlush[p]
}

/**
* This predicate checks if the player's best hand is a high card.
* Param: p - a player
*/
pred hasHighCard[p : Player] {
    not hasRoyalFlush[p]
    not hasStraightFlush[p]
    not hasFourOfaKind[p]
    not hasFullHouse[p]
    not hasFlush[p]
    not hasStraight[p]
    not hasThreeofaKind[p]
    not hasTwoPair[p]
    not hasPair[p]
}

/**
* This predicate checks the hand a player has and sets the players hand to the type of hand they have.
* Param: p - a player
*/
pred evaluateHand[p : Player] {
    hasRoyalFlush[p] implies p.hand.score = 5
    hasStraightFlush[p] implies p.hand.score = 4
    hasFourOfaKind[p] implies p.hand.score = 3
    hasFullHouse[p] implies p.hand.score = 2
    hasFlush[p] implies p.hand.score = 1
    hasStraight[p] implies p.hand.score = 0
    hasThreeofaKind[p] implies p.hand.score = -1
    hasTwoPair[p] implies p.hand.score = -2
    hasPair[p] implies p.hand.score = -3
    hasHighCard[p] implies p.hand.score = -4
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
} for exactly 13 Card, 4 Player, 4 Int for optimize_rank
