#lang forge/temporal

open "poker.frg"

pred dealCardsTest1 {
    some p1, p2 : Player | some disj c1, c2, c3, c4 : Card | {
        c1 in p1.hand.cards
        c2 in p1.hand.cards
        c3 in p2.hand.cards
        c4 in p2.hand.cards
    }
}

pred dealCardsTest2 {
    some p : Player | some disj c1, c2 : Card | {
        p.hand.cards = c1 + c2
    }
}

pred dealCardsTest3 {
    some p : Player | some c1, c2 : Card | {
        c1 = c2
        p.hand.cards = c1 + c2
    }
}

pred dealCardsTest4 {
    some disj p1, p2 : Player | some c : Card | {
        c in p1.hand and c not in p2.hand
    }
}

pred dealCardsTest5 {
    some disj p1, p2 : Player | some c : Card | {
        c in p1.hand and c in p2.hand
    }
}

pred dealCardsTest6 {
    all p : Player | {
        #{p.hand.cards} = 2
    }
}

pred dealCardsTest7 {
    some p : Player | {
        #{p.hand.cards} = 3
    }
}

/**
 * Test suite for the dealCards predicate
 */
test suite for dealCards {
    test expect {
        dealCardsTest: {dealCards} is sat
        dealCards1: {dealCardsTest1 and dealCards} is sat
        dealCards2: {dealCardsTest2 and dealCards} is sat
        dealCards3: {dealCardsTest3 and dealCards} is unsat
        // dealCards4: {dealCardsTest4 and dealCards} is sat
        dealCards5: {dealCardsTest5 and dealCards} is unsat
        dealCards6: {dealCardsTest6 and dealCards} is sat
        dealCards7: {dealCardsTest7 and dealCards} is unsat
    }
}

// pred playersChipsGood {
//     all p : Player | {
//         p.chips = 5
//         p.bet = 0
//     }
// }

// pred playersChipsBad {
//     some p : Player | {
//         p.chips = 3
//         p.bet = 3
//     }
// }

// pred playerBadBet {
//     some p : Player | {p.bet = 3}
// }

// pred playerGoodBet {
//     some p : Player | {p.bet = 0}
// }

// pred goodRoundState[s : RoundState] {
//     s.highestBet = 0
//     s.board = none
//     s.highestBet = 0
//     s.pot = 0
// }

// pred badRoundState[s : RoundState] {
//     s.highestBet = 3
//     s.board = none
//     s.highestBet = 0
//     s.pot = 0
// }

// /**
//  * Test suite for the initRound predicate
//  */
// test suite for initRound {
//     test expect {
//         // initRoundTest: {some r : RoundState | initRound[r]} is sat
//         // initRoundAndDealCardsTest: {some r : RoundState | initRound[r] and dealCards} is sat
//         // t11: {some r : RoundState | playersChipsGood and goodRoundState[r] and initRound[r]} is sat
//         t22: {some r : RoundState | playersChipsBad and goodRoundState[r] and initRound[r]} is unsat
//         t33: {some r : RoundState | playersChipsGood and badRoundState[r] and initRound[r]} is unsat
//     }
// }

// pred winnerRoundState1Player[r: RoundState] {
//     one p1 :Player | p1 in r.players and #(r.players) = 1
//     r = postRiver
// }

// pred winnerRoundState2Players[r: RoundState] {
//     some disj p1, p2 : Player | {
//         p1 in r.players 
//         p2 in r.players
//         #(r.players) = 2
//         r = postRiver
//         p1.hand.score = 3
//         p2.hand.score = 0
//     }
// }

// pred badWinnerRoundState[r: RoundState] {
//     some disj p1, p2 : Player | {
//         p1 in r.players 
//         p2 in r.players
//         #(r.players) = 2
//         r = postRiver
//         p1.chips = p1.chips + r.pot
//         p2.hand.score > p1.hand.score
//     }
// }

// /**
//  * Test suite for the winner predicate
//  */
// test suite for winner {
//     test expect {
//         t1winner: {some r: RoundState | winnerRoundState1Player[r] and winner[r]} is sat
//         // t2winner: {some r: RoundState | winnerRoundState2Players[r] and winner[r]} is sat
//         t3winner: {some r: RoundState | badWinnerRoundState[r] and winner[r]} is unsat
//     }
// }

// pred canPlay1[r: RoundState] {
//     some p: Player | {
//         p in r.players
//         p.chips > 0
//         r.turn = p
//     }
// }

// pred notHisTurn[r: RoundState] {
//     some p : Player | {
//         p in r.players
//         r.turn = none
//     }
// }

// pred notInPlayers[r: RoundState] {
//     some p : Player | {
//         not p in r.players
//         r.turn = p
//     }
// }

// pred notEnoughChips[r: RoundState] {
//     some p : Player | {
//         p in r.players
//         p.chips = 0
//         r.turn = p
//         p.bet < r.highestBet
//     }
// }

// /**
//  * Test suite for the canPlay predicate
//  */
// test suite for canPlay {
//     test expect {
//         t1CanPlay: {some r: RoundState | canPlay1[r] and canPlay[r]} is sat
//         t2CanPlay: {some r: RoundState | notHisTurn[r] and canPlay[r]} is unsat
//         t3CanPlay: {some r: RoundState | notInPlayers[r] and canPlay[r]} is unsat
//         t4CanPlay: {some r: RoundState | notEnoughChips[r] and canPlay[r]} is unsat
//     }
// }

// pred validTurn1[r: RoundState] {
//     some p: Player | {
//         p in r.players
//         p.bet = r.highestBet
//     }
// }

// pred notValidTurn1[r: RoundState] {
//     some p: Player | {
//         r.turn = p
//         r.turn.nextPlayer != p
//     }
// }

// /**
//  * Test suite for the validTurn predicate
//  */
// test suite for validTurn {
//     // assert canPlay is necessary for validTurn
//     test expect {
//         t1ValidTurn: {some r: RoundState | canPlay1[r] and validTurn[r]} is sat
//         t5ValidTurn: {some r: RoundState | notValidTurn1[r] and validTurn[r]} is unsat
//     }
// }

// pred preFlopToPostFlop[pre, post: RoundState] {
//     some disj c1, c2, c3: Card {
//         pre = preFlop
//         pre' = post
//         post = postFlop
//         pre.board = none
//         #(post.board) = 3
//         post.board = c1 + c2 + c3
//     }
// }

// pred badPreFlopToPostFlop[pre, post: RoundState] {
//     some c1: Card {
//         pre = preFlop
//         pre' = post
//         post = postFlop
//         pre.board = none
//         #(post.board) = 1
//         post.board = c1
//     }
// }

// pred postFlopToPostTurn[pre, post: RoundState] {
//     pre = postFlop
//     // pre' = post
//     post = postTurn
//     pre.board = post.board
//     #(post.board) = 4
//     some disj c1, c2, c3, c4: Card {
//         post.board = c1 + c2 + c3 + c4
//     }
// }

// pred badPostFlopToPostTurn[pre, post: RoundState] {
//     pre = postFlop
//     pre' = post
//     post = postTurn
//     pre.board = post.board
//     #(post.board) = 2
// }

// pred postTurnToPostRiver[pre, post: RoundState] {
//     pre = postTurn
//     pre' = post
//     post = postRiver
//     pre.board = post.board
//     #(post.board) = 5
//     some disj c1, c2, c3, c4, c5: Card {
//         post.board = c1 + c2 + c3 + c4 + c5
//     }
// }

// pred badPostTurnToPostRiver[pre, post: RoundState] {
//     pre = postTurn
//     pre' = post
//     post = postRiver
//     pre.board = post.board
//     #(post.board) = 3
// }

// /**
//  * Test suite for the validTransition predicate
//  */
// test suite for validTransition {
//     // assert validTurn is necessary for validTransition
//     test expect {
//         // vt1: {some pre, post: RoundState | preFlopToPostFlop[pre, post] and validTransition[pre, post]} is sat
//         // vt2: {some pre, post: RoundState | postFlopToPostTurn[pre, post] and validTransition[pre, post]} is sat
//         vt3: {some pre, post: RoundState | postTurnToPostRiver[pre, post] and validTransition[pre, post]} is sat
//         vt4: {some pre, post: RoundState | badPreFlopToPostFlop[pre, post] and validTransition[pre, post]} is unsat
//         vt5: {some pre, post: RoundState | badPostFlopToPostTurn[pre, post] and validTransition[pre, post]} is unsat
//         vt6: {some pre, post: RoundState | badPostTurnToPostRiver[pre, post] and validTransition[pre, post]} is unsat
//     }
// }

// pred highestCard[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Diamonds and c2.rank = Queen
//         c3.suit = Hearts and c3.rank = Ten
//         c4.suit = Clubs and c4.rank = Eight
//         c5.suit = Diamonds and c5.rank = Six
//         c6.suit = Hearts and c6.rank = Four
//         c7.suit = Clubs and c7.rank = Two
//     }
// }

// pred pair[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Diamonds and c2.rank = Ace
//         c3.suit = Hearts and c3.rank = Ten
//         c4.suit = Clubs and c4.rank = Eight
//         c5.suit = Diamonds and c5.rank = Six
//         c6.suit = Hearts and c6.rank = Four
//         c7.suit = Clubs and c7.rank = Two
//     }
// }

// pred twoPair[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Diamonds and c2.rank = Ace
//         c3.suit = Hearts and c3.rank = Ten
//         c4.suit = Clubs and c4.rank = Ten
//         c5.suit = Diamonds and c5.rank = Six
//         c6.suit = Hearts and c6.rank = Four
//         c7.suit = Clubs and c7.rank = Two
//     }
// }

// pred threeOfAKind[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Diamonds and c2.rank = Ace
//         c3.suit = Hearts and c3.rank = Ace
//         c4.suit = Clubs and c4.rank = Eight
//         c5.suit = Diamonds and c5.rank = Six
//         c6.suit = Hearts and c6.rank = Four
//         c7.suit = Clubs and c7.rank = Two
//     }
// }

// pred straight[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Diamonds and c2.rank = King
//         c3.suit = Hearts and c3.rank = Nine
//         c4.suit = Clubs and c4.rank = Eight
//         c5.suit = Diamonds and c5.rank = Seven
//         c6.suit = Hearts and c6.rank = Six
//         c7.suit = Clubs and c7.rank = Five
//     }
// }

// pred flush[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Clubs and c2.rank = Queen
//         c3.suit = Clubs and c3.rank = Ten
//         c4.suit = Clubs and c4.rank = Eight
//         c5.suit = Diamonds and c5.rank = Six
//         c6.suit = Hearts and c6.rank = Four
//         c7.suit = Clubs and c7.rank = Two
//     }
// }

// pred fullHouse[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Diamonds and c2.rank = Ace
//         c3.suit = Hearts and c3.rank = Ace
//         c4.suit = Clubs and c4.rank = Eight
//         c5.suit = Diamonds and c5.rank = Eight
//         c6.suit = Hearts and c6.rank = Four
//         c7.suit = Clubs and c7.rank = Two
//     }
// }

// pred fourOfAKind[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Diamonds and c2.rank = Ace
//         c3.suit = Hearts and c3.rank = Ace
//         c4.suit = Spades and c4.rank = Ace
//         c5.suit = Diamonds and c5.rank = Six
//         c6.suit = Hearts and c6.rank = Four
//         c7.suit = Clubs and c7.rank = Two
//     }
// }

// pred straightFlush[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Spades and c2.rank = King
//         c3.suit = Diamonds and c3.rank = Nine
//         c4.suit = Diamonds and c4.rank = Eight
//         c5.suit = Diamonds and c5.rank = Seven
//         c6.suit = Diamonds and c6.rank = Six
//         c7.suit = Diamonds and c7.rank = Five
//     }
// }

// pred royalFlush[p : Player] {
//     some c1, c2, c3, c4, c5, c6, c7 : Card {
//         c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
//         c1.suit = Clubs and c1.rank = Ace
//         c2.suit = Clubs and c2.rank = King
//         c3.suit = Clubs and c3.rank = Queen
//         c4.suit = Clubs and c4.rank = Jack
//         c5.suit = Clubs and c5.rank = Ten
//         c6.suit = Hearts and c6.rank = Four
//         c7.suit = Clubs and c7.rank = Two
//     }
// }

// test suite for hasHighCard {
//     test expect {
//         // highCardSat: {some p : Player | highestCard[p] and hasHighCard[p]} is sat
//         highCardUnsat1: {some p : Player | highestCard[p] and hasPair[p]} is unsat
//         highCardUnsat2: {some p : Player | highestCard[p] and hasTwoPair[p]} is unsat
//         highCardUnsat3: {some p : Player | highestCard[p] and hasThreeofaKind[p]} is unsat
//         highCardUnsat4: {some p : Player | highestCard[p] and hasStraight[p]} is unsat
//         highCardUnsat5: {some p : Player | highestCard[p] and hasFlush[p]} is unsat
//         highCardUnsat6: {some p : Player | highestCard[p] and hasFullHouse[p]} is unsat
//         highCardUnsat7: {some p : Player | highestCard[p] and hasFourOfaKind[p]} is unsat
//         highCardUnsat8: {some p : Player | highestCard[p] and hasStraightFlush[p]} is unsat
//         highCardUnsat9: {some p : Player | highestCard[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasPair {
//     test expect {
//         // pairSat: {some p : Player | pair[p] and hasPair[p]} is sat
//         pairUnsat1: {some p : Player | pair[p] and hasHighCard[p]} is unsat
//         pairUnsat2: {some p : Player | pair[p] and hasTwoPair[p]} is unsat
//         pairUnsat3: {some p : Player | pair[p] and hasThreeofaKind[p]} is unsat
//         pairUnsat4: {some p : Player | pair[p] and hasStraight[p]} is unsat
//         pairUnsat5: {some p : Player | pair[p] and hasFlush[p]} is unsat
//         pairUnsat6: {some p : Player | pair[p] and hasFullHouse[p]} is unsat
//         pairUnsat7: {some p : Player | pair[p] and hasFourOfaKind[p]} is unsat
//         pairUnsat8: {some p : Player | pair[p] and hasStraightFlush[p]} is unsat
//         pairUnsat9: {some p : Player | pair[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasTwoPair {
//     test expect {
//         // twoPairSat: {some p : Player | twoPair[p] and hasTwoPair[p]} is sat
//         twoPairUnsat1: {some p : Player | twoPair[p] and hasHighCard[p]} is unsat
//         twoPairUnsat2: {some p : Player | twoPair[p] and hasPair[p]} is unsat
//         twoPairUnsat3: {some p : Player | twoPair[p] and hasThreeofaKind[p]} is unsat
//         twoPairUnsat4: {some p : Player | twoPair[p] and hasStraight[p]} is unsat
//         twoPairUnsat5: {some p : Player | twoPair[p] and hasFlush[p]} is unsat
//         twoPairUnsat6: {some p : Player | twoPair[p] and hasFullHouse[p]} is unsat
//         twoPairUnsat7: {some p : Player | twoPair[p] and hasFourOfaKind[p]} is unsat
//         twoPairUnsat8: {some p : Player | twoPair[p] and hasStraightFlush[p]} is unsat
//         twoPairUnsat9: {some p : Player | twoPair[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasThreeofaKind {
//     test expect {
//         // threeOfAKindSat: {some p : Player | threeOfAKind[p] and hasThreeofaKind[p]} is sat
//         threeOfAKindUnsat1: {some p : Player | threeOfAKind[p] and hasHighCard[p]} is unsat
//         threeOfAKindUnsat2: {some p : Player | threeOfAKind[p] and hasPair[p]} is unsat
//         threeOfAKindUnsat3: {some p : Player | threeOfAKind[p] and hasTwoPair[p]} is unsat
//         threeOfAKindUnsat4: {some p : Player | threeOfAKind[p] and hasStraight[p]} is unsat
//         threeOfAKindUnsat5: {some p : Player | threeOfAKind[p] and hasFlush[p]} is unsat
//         threeOfAKindUnsat6: {some p : Player | threeOfAKind[p] and hasFullHouse[p]} is unsat
//         threeOfAKindUnsat7: {some p : Player | threeOfAKind[p] and hasFourOfaKind[p]} is unsat
//         threeOfAKindUnsat8: {some p : Player | threeOfAKind[p] and hasStraightFlush[p]} is unsat
//         threeOfAKindUnsat9: {some p : Player | threeOfAKind[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasStraight {
//     test expect {
//         // straightSat: {some p : Player | straight[p] and hasStraight[p]} is sat
//         straightUnsat1: {some p : Player | straight[p] and hasHighCard[p]} is unsat
//         straightUnsat2: {some p : Player | straight[p] and hasPair[p]} is unsat
//         straightUnsat3: {some p : Player | straight[p] and hasTwoPair[p]} is unsat
//         straightUnsat4: {some p : Player | straight[p] and hasThreeofaKind[p]} is unsat
//         straightUnsat5: {some p : Player | straight[p] and hasFlush[p]} is unsat
//         straightUnsat6: {some p : Player | straight[p] and hasFullHouse[p]} is unsat
//         straightUnsat7: {some p : Player | straight[p] and hasFourOfaKind[p]} is unsat
//         straightUnsat8: {some p : Player | straight[p] and hasStraightFlush[p]} is unsat
//         straightUnsat9: {some p : Player | straight[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasFlush {
//     test expect {
//         // flushSat: {some p : Player | flush[p] and hasFlush[p]} is sat
//         flushUnsat1: {some p : Player | flush[p] and hasHighCard[p]} is unsat
//         flushUnsat2: {some p : Player | flush[p] and hasPair[p]} is unsat
//         flushUnsat3: {some p : Player | flush[p] and hasTwoPair[p]} is unsat
//         flushUnsat4: {some p : Player | flush[p] and hasThreeofaKind[p]} is unsat
//         flushUnsat5: {some p : Player | flush[p] and hasStraight[p]} is unsat
//         flushUnsat6: {some p : Player | flush[p] and hasFullHouse[p]} is unsat
//         flushUnsat7: {some p : Player | flush[p] and hasFourOfaKind[p]} is unsat
//         flushUnsat8: {some p : Player | flush[p] and hasStraightFlush[p]} is unsat
//         flushUnsat9: {some p : Player | flush[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasFullHouse {
//     test expect {
//         // fullHouseSat: {some p : Player | fullHouse[p] and hasFullHouse[p]} is sat
//         fullHouseUnsat1: {some p : Player | fullHouse[p] and hasHighCard[p]} is unsat
//         fullHouseUnsat2: {some p : Player | fullHouse[p] and hasPair[p]} is unsat
//         fullHouseUnsat3: {some p : Player | fullHouse[p] and hasTwoPair[p]} is unsat
//         fullHouseUnsat4: {some p : Player | fullHouse[p] and hasThreeofaKind[p]} is unsat
//         fullHouseUnsat5: {some p : Player | fullHouse[p] and hasStraight[p]} is unsat
//         fullHouseUnsat6: {some p : Player | fullHouse[p] and hasFlush[p]} is unsat
//         fullHouseUnsat7: {some p : Player | fullHouse[p] and hasFourOfaKind[p]} is unsat
//         fullHouseUnsat8: {some p : Player | fullHouse[p] and hasStraightFlush[p]} is unsat
//         fullHouseUnsat9: {some p : Player | fullHouse[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasFourOfaKind {
//     test expect {
//         // fourOfAKindSat: {some p : Player | fourOfAKind[p] and hasFourOfaKind[p]} is sat
//         fourOfAKindUnsat1: {some p : Player | fourOfAKind[p] and hasHighCard[p]} is unsat
//         fourOfAKindUnsat2: {some p : Player | fourOfAKind[p] and hasPair[p]} is unsat
//         fourOfAKindUnsat3: {some p : Player | fourOfAKind[p] and hasTwoPair[p]} is unsat
//         fourOfAKindUnsat4: {some p : Player | fourOfAKind[p] and hasThreeofaKind[p]} is unsat
//         fourOfAKindUnsat5: {some p : Player | fourOfAKind[p] and hasStraight[p]} is unsat
//         fourOfAKindUnsat6: {some p : Player | fourOfAKind[p] and hasFlush[p]} is unsat
//         fourOfAKindUnsat7: {some p : Player | fourOfAKind[p] and hasFullHouse[p]} is unsat
//         fourOfAKindUnsat8: {some p : Player | fourOfAKind[p] and hasStraightFlush[p]} is unsat
//         fourOfAKindUnsat9: {some p : Player | fourOfAKind[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasStraightFlush {
//     test expect {
//         // straightFlushSat: {some p : Player | straightFlush[p] and hasStraightFlush[p]} is sat
//         straightFlushUnsat1: {some p : Player | straightFlush[p] and hasHighCard[p]} is unsat
//         straightFlushUnsat2: {some p : Player | straightFlush[p] and hasPair[p]} is unsat
//         straightFlushUnsat3: {some p : Player | straightFlush[p] and hasTwoPair[p]} is unsat
//         straightFlushUnsat4: {some p : Player | straightFlush[p] and hasThreeofaKind[p]} is unsat
//         straightFlushUnsat5: {some p : Player | straightFlush[p] and hasStraight[p]} is unsat
//         straightFlushUnsat6: {some p : Player | straightFlush[p] and hasFlush[p]} is unsat
//         straightFlushUnsat7: {some p : Player | straightFlush[p] and hasFullHouse[p]} is unsat
//         straightFlushUnsat8: {some p : Player | straightFlush[p] and hasFourOfaKind[p]} is unsat
//         straightFlushUnsat9: {some p : Player | straightFlush[p] and hasRoyalFlush[p]} is unsat
//     }
// }

// test suite for hasRoyalFlush {
//     test expect {
//         // royalFlushSat: {some p : Player | royalFlush[p] and hasRoyalFlush[p]} is sat
//         royalFlushUnsat1: {some p : Player | royalFlush[p] and hasHighCard[p]} is unsat
//         royalFlushUnsat2: {some p : Player | royalFlush[p] and hasPair[p]} is unsat
//         royalFlushUnsat3: {some p : Player | royalFlush[p] and hasTwoPair[p]} is unsat
//         royalFlushUnsat4: {some p : Player | royalFlush[p] and hasThreeofaKind[p]} is unsat
//         royalFlushUnsat5: {some p : Player | royalFlush[p] and hasStraight[p]} is unsat
//         royalFlushUnsat6: {some p : Player | royalFlush[p] and hasFlush[p]} is unsat
//         royalFlushUnsat7: {some p : Player | royalFlush[p] and hasFullHouse[p]} is unsat
//         royalFlushUnsat8: {some p : Player | royalFlush[p] and hasFourOfaKind[p]} is unsat
//         royalFlushUnsat9: {some p : Player | royalFlush[p] and hasStraightFlush[p]} is unsat
//     }
// }