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
        c in p1.hand implies c not in p2.hand
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
        // dealCards1: {dealCardsTest1 and dealCards} is sat
        // dealCards2: {dealCardsTest2 and dealCards} is sat
        // dealCards3: {dealCardsTest3 and dealCards} is unsat
        // dealCards4: {dealCardsTest4 and dealCards} is sat
        // dealCards5: {dealCardsTest5 and dealCards} is unsat
        // dealCards6: {dealCardsTest6 and dealCards} is sat
        // dealCards7: {dealCardsTest7 and dealCards} is unsat
    }
}


pred goodRoundState1[s : RoundState] {
    s.bet = 0
    s.board = none
    s.winner = none
    s.bstate = preFlop
    #{s.players} = 4

    all p : Player | {
        p.hand.score[s] = 2
        p in s.players
    }
}

pred badRoundState1[s : RoundState] {
    s.bet = 0
    s.board = none
    s.winner = none
    s.bstate = preFlop
    #{s.players} = 4

    some p : Player | {
        no p.hand.score[s]
        p in s.players
    }
}

pred badRoundState2[s : RoundState] {
    s.bet = 5
    s.board = none
    s.winner = none
    s.bstate = preFlop
    #{s.players} = 4

    all p : Player | {
        p.hand.score[s] = 2
        p in s.players
    }
}

pred badRoundState3[s : RoundState] {
    s.bet = 0
    s.board = none
    s.winner = none
    s.bstate = preFlop
    #{s.players} = 5

    some p : Player | {
        p.hand.score[s] = 2
        p in s.players
    }
}

pred badRoundState4[s : RoundState] {
    s.bet = 0
    s.board = none
    s.winner = none
    s.bstate = preFlop
    #{s.players} = 4

    some p : Player | {
        p not in s.players
    }
}

/**
 * Test suite for the initRound predicate
 */
// test suite for initRound {
//     test expect {
//         // initRoundTest00: {some r : RoundState | initRound[r]} is sat
//         // initRoundTest0: {some r : RoundState | initRound[r] and dealCards} is sat
//         // initRoundTest1: {some r : RoundState | initRound[r] and goodRoundState1[r]} is sat
//         // initRoundTest2: {some r : RoundState | initRound[r] and badRoundState1[r]} is unsat
//         // initRoundTest3: {some r : RoundState | initRound[r] and badRoundState2[r]} is unsat
//         // initRoundTest4: {some r : RoundState | initRound[r] and badRoundState3[r]} is unsat
//         // initRoundTest5: {some r : RoundState | initRound[r] and badRoundState4[r]} is unsat
//     }
// }

// pred preFlopToPostFlop1[pre, post: RoundState] {
//     pre.bstate = preFlop
//     pre.next = post
//     post.bstate = postFlop
//     pre.board = none
//     #{post.players} = 3
//     #(pre.players) = 4
//     #(post.board) = 3

//     some disj p1, p2, p3, p4: Player {
//         p1 in pre.players
//         p2 in pre.players
//         p3 in pre.players
//         p4 in pre.players
        
//         p1 in post.players
//         p2 in post.players
//         p3 in post.players
//         no p4.hand.score[post]
//     }
//     some disj c1, c2, c3: Card {
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

/**
 * Test suite for the validTransition predicate
 */
// test suite for validTransition {
//     // assert validTurn is necessary for validTransition
//     test expect {
//         // vt1: {some pre, post: RoundState | preFlopToPostFlop1[pre, post] and validTransition[pre, post]} is sat
//         // vt2: {some pre, post: RoundState | postFlopToPostTurn[pre, post] and validTransition[pre, post]} is sat
//         // vt3: {some pre, post: RoundState | postTurnToPostRiver[pre, post] and validTransition[pre, post]} is sat
//         // vt4: {some pre, post: RoundState | badPreFlopToPostFlop[pre, post] and validTransition[pre, post]} is unsat
//         // vt5: {some pre, post: RoundState | badPostFlopToPostTurn[pre, post] and validTransition[pre, post]} is unsat
//         // vt6: {some pre, post: RoundState | badPostTurnToPostRiver[pre, post] and validTransition[pre, post]} is unsat
//     }
// }

// THESE TESTS MIGHT BE FAILING BECAUSE dealCards RESTRICTS PLAYER HANDS TO 2 CARDS

// pred highCard[cards : set Card] {
//         Ace in cards.rank
//         #{c : Card | c in cards and c.suit = Clubs} = 3
//         #{c : Card | c in cards and c.suit = Diamonds} = 2
//         Queen in cards.rank
//         #{c : Card | c in cards and c.suit = Hearts} = 2
//         Ten in cards.rank
//         Eight in cards.rank
//         Six in cards.rank
//         Four in cards.rank
//         Two in cards.rank
//         #{cards} = 7
//     }

pred pair[p: Player, r: RoundState] {
    // some disj c1, c2, c3, c4, c5, c6, c7 : Card {
    //     c1 in p.hand and c2 in p.hand
    //     c3 in r.board and c4 in r.board and c5 in r.board and c6 in r.board and c7 in r.board
    //     c1.suit = Clubs and c1.rank = Ace
    //     c2.suit = Diamonds and c2.rank = Nine
    //     c3.suit = Hearts and c3.rank = Ten
    //     c4.suit = Clubs and c4.rank = Ten
    //     c5.suit = Diamonds and c5.rank = Six
    //     c6.suit = Hearts and c6.rank = Four
    //     c7.suit = Clubs and c7.rank = Two
    // }
    some rank1 : Rank | {
        #{c : Card | c in p.hand.cards and c.rank = rank1} = 2
    } 
}

pred twoPair[p : Player] {
    some c1, c2, c3, c4, c5, c6, c7 : Card {
        c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
        c1.suit = Clubs and c1.rank = Ace
        c2.suit = Diamonds and c2.rank = Ace
        c3.suit = Hearts and c3.rank = Ten
        c4.suit = Clubs and c4.rank = Ten
        c5.suit = Diamonds and c5.rank = Six
        c6.suit = Hearts and c6.rank = Four
        c7.suit = Clubs and c7.rank = Two
    }
}

pred threeOfAKind[p : Player] {
    some c1, c2, c3, c4, c5, c6, c7 : Card {
        c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
        c1.suit = Clubs and c1.rank = Ace
        c2.suit = Diamonds and c2.rank = Ace
        c3.suit = Hearts and c3.rank = Ace
        c4.suit = Clubs and c4.rank = Eight
        c5.suit = Diamonds and c5.rank = Six
        c6.suit = Hearts and c6.rank = Four
        c7.suit = Clubs and c7.rank = Two
    }
}

pred straight[p : Player] {
    some c1, c2, c3, c4, c5, c6, c7 : Card {
        c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
        c1.suit = Clubs and c1.rank = Ace
        c2.suit = Diamonds and c2.rank = King
        c3.suit = Hearts and c3.rank = Nine
        c4.suit = Clubs and c4.rank = Eight
        c5.suit = Diamonds and c5.rank = Seven
        c6.suit = Hearts and c6.rank = Six
        c7.suit = Clubs and c7.rank = Five
    }
}

pred flush[p : Player] {
    some c1, c2, c3, c4, c5, c6, c7 : Card {
        c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
        c1.suit = Clubs and c1.rank = Ace
        c2.suit = Clubs and c2.rank = Queen
        c3.suit = Clubs and c3.rank = Ten
        c4.suit = Clubs and c4.rank = Eight
        c5.suit = Diamonds and c5.rank = Six
        c6.suit = Hearts and c6.rank = Four
        c7.suit = Clubs and c7.rank = Two
    }
}

pred fullHouse[p : Player] {
    some c1, c2, c3, c4, c5, c6, c7 : Card {
        c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
        c1.suit = Clubs and c1.rank = Ace
        c2.suit = Diamonds and c2.rank = Ace
        c3.suit = Hearts and c3.rank = Ace
        c4.suit = Clubs and c4.rank = Eight
        c5.suit = Diamonds and c5.rank = Eight
        c6.suit = Hearts and c6.rank = Four
        c7.suit = Clubs and c7.rank = Two
    }
}

pred fourOfAKind[p : Player] {
    some c1, c2, c3, c4, c5, c6, c7 : Card {
        c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
        c1.suit = Clubs and c1.rank = Ace
        c2.suit = Diamonds and c2.rank = Ace
        c3.suit = Hearts and c3.rank = Ace
        c4.suit = Spades and c4.rank = Ace
        c5.suit = Diamonds and c5.rank = Six
        c6.suit = Hearts and c6.rank = Four
        c7.suit = Clubs and c7.rank = Two
    }
}

pred straightFlush[p : Player] {
    some c1, c2, c3, c4, c5, c6, c7 : Card {
        c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
        c1.suit = Clubs and c1.rank = Ace
        c2.suit = Spades and c2.rank = King
        c3.suit = Diamonds and c3.rank = Nine
        c4.suit = Diamonds and c4.rank = Eight
        c5.suit = Diamonds and c5.rank = Seven
        c6.suit = Diamonds and c6.rank = Six
        c7.suit = Diamonds and c7.rank = Five
    }
}

pred royalFlush[p : Player] {
    some c1, c2, c3, c4, c5, c6, c7 : Card {
        c1 in p.hand and c2 in p.hand and c3 in p.hand and c4 in p.hand and c5 in p.hand and c6 in p.hand and c7 in p.hand
        c1.suit = Clubs and c1.rank = Ace
        c2.suit = Clubs and c2.rank = King
        c3.suit = Clubs and c3.rank = Queen
        c4.suit = Clubs and c4.rank = Jack
        c5.suit = Clubs and c5.rank = Ten
        c6.suit = Hearts and c6.rank = Four
        c7.suit = Clubs and c7.rank = Two
    }
}

/*
    * Test suite for the various card combination predicates
    These are all vacuity tests only, as the properties are tested
    in the evaluateHand test suite 
*/
// test suite for hasPair {
//     test expect {
//         pairSat: {some h: Hand, r: RoundState | hasPair[h.cards + r.board]} is sat
//     }
// }

// // test suite for hasTwoPair {
// //     test expect {
// //         twoPairSat: {some h: Hand, r: RoundState | hasTwoPair[h.cards + r.board]} is sat
// //     }
// // }

// test suite for hasThreeofaKind {
//     test expect {
//         threeOfAKindSat: {some h: Hand, r: RoundState | hasThreeofaKind[h.cards + r.board]} is sat
//     }
// }

// test suite for hasStraight {
//     test expect {
//         straightSat: {some h: Hand, r: RoundState | hasStraight[h.cards + r.board]} is sat
//     }
// }

// test suite for hasFlush {
//     test expect {
//         flushSat: {some h: Hand, r: RoundState | hasFlush[h.cards + r.board]} is sat
//     }
// }

// test suite for hasFullHouse {
//     test expect {
//         fullHouseSat: {some h: Hand, r: RoundState | hasFullHouse[h.cards + r.board]} is sat
//     }
// }

// test suite for hasFourOfaKind {
//     test expect {
//         fourOfAKindSat: {some h: Hand, r: RoundState | hasFourOfaKind[h.cards + r.board]} is sat
//     }
// }

// test suite for hasStraightFlush {
//     test expect {
//         straightFlushSat: {some h: Hand, r: RoundState | hasStraightFlush[h.cards + r.board]} is sat
//     }
// }

// test suite for hasRoyalFlush {
//     test expect {
//         royalFlushSat: {some h: Hand, r: RoundState | hasRoyalFlush[h.cards + r.board]} is sat
//     }
// }

/*
    * Test suite for evaluateHand.  Ensures that the different card combinations
    give the player the appropriate score.
*/
test suite for evaluateHand {
    test expect {
        sattest: {some p : Player, r: RoundState | evaluateHand[p, r]} is sat
        // evalPairSat: {some p : Player, r: RoundState | pair[p, r] and evaluateHand[p, r] and p.hand.score[r] = -3} is sat
        // evalTwoPairSat: {some p : Player | twoPair[p] and evaluateHand[p] and p.hand.score = -2} is sat
        // evalThreeOfAKindSat: {some p : Player | threeOfAKind[p] and evaluateHand[p] and p.hand.score = -1} is sat
        // evalStraightSat: {some p : Player | straight[p] and evaluateHand[p] and p.hand.score = 0} is sat
        // evalFlushSat: {some p : Player | flush[p] and evaluateHand[p] and p.hand.score = 1} is sat
        // evalFullHouseSat: {some p : Player | fullHouse[p] and evaluateHand[p] and p.hand.score = 2} is sat
        // evalFourOfAKindSat: {some p : Player | fourOfAKind[p] and evaluateHand[p] and p.hand.score = 3} is sat
        // evalStraightFlushSat: {some p : Player | straightFlush[p] and evaluateHand[p] and p.hand.score = 4} is sat
        // evalRoyalFlushSat: {some p : Player | royalFlush[p] and evaluateHand[p] and p.hand.score = 5} is sat
    }
}

test suite for traces {
    test expect {
        vacuity: {traces} is sat
        pairSat: {traces => {some p : Player | hasPair[p.hand.cards]}} is sat
        // twoPairSat: {traces => {some p : Player, r: RoundState| hasTwoPair[p.hand.cards + r.board]}} is sat
        // threeOfAKindSat: {traces => {some p : Player, r: RoundState | hasThreeofaKind[p.hand.cards + r.board]}} is sat
        // straightSat: {traces => {some p : Player, r: RoundState | hasStraight[p.hand.cards + r.board]}} is sat
        // flushSat: {traces => {some p : Player, r: RoundState | hasFlush[p.hand.cards + r.board]}} is sat
        // fullHouseSat: {traces => {some p : Player, r: RoundState | hasFullHouse[p.hand.cards + r.board]}} is sat
        // fourOfAKindSat: {traces => {some p : Player, r: RoundState | hasFourOfaKind[p.hand.cards + r.board]}} is sat
        // straightFlushSat: {traces => {some p : Player, r: RoundState | hasStraightFlush[p.hand.cards + r.board]}} is sat
        // royalFlushSat: {traces => {some p : Player, r: RoundState | hasRoyalFlush[p.hand.cards + r.board]}} is sat

        // pairScoreTest: {(traces and {some p: Player, r: RoundState | hasPair[p.hand.cards + r.board]}) => player.hand.score[r] = -3} is theorem
        // twoPairScoreTest: {(traces and {some p: Player, r: RoundState | hasTwoPair[p.hand.cards + r.board]}) => player.hand.score[r] = -2} is theorem
        // threeOfAKindScoreTest: {(traces and {some p: Player, r: RoundState | hasThreeofaKind[p.hand.cards + r.board]}) => player.hand.score[r] = -1} is theorem
        // straightScoreTest: {(traces and {some p: Player, r: RoundState | hasStraight[p.hand.cards + r.board]}) => player.hand.score[r] = 0} is theorem
        // flushScoreTest: {(traces and {some p: Player, r: RoundState | hasFlush[p.hand.cards + r.board]}) => player.hand.score[r] = 1} is theorem
        // fullHouseScoreTest: {(traces and {some p: Player, r: RoundState | hasFullHouse[p.hand.cards + r.board]}) => player.hand.score[r] = 2} is theorem
        // fourOfAKindScoreTest: {(traces and {some p: Player, r: RoundState | hasFourOfaKind[p.hand.cards + r.board]}) => player.hand.score[r] = 3} is theorem
        // straightFlushScoreTest: {(traces and {some p: Player, r: RoundState | hasStraightFlush[p.hand.cards + r.board]}) => player.hand.score[r] = 4} is theorem
        // royalFlushScoreTest: {(traces and {some p: Player, r: RoundState | hasRoyalFlush[p.hand.cards + r.board]}) => player.hand.score[r] = 5} is theorem
    }
}


//-----------Property Tests of Strategies----------------//
test expect {
    vacuity1: {traces and neverFolds} is sat
}

