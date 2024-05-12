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
// test suite for dealCards {
//     test expect {
//         dealCardsTest: {dealCards} is sat
//         // dealCards1: {dealCardsTest1 and dealCards} is sat
//         // dealCards2: {dealCardsTest2 and dealCards} is sat
//         // dealCards3: {dealCardsTest3 and dealCards} is unsat
//         // dealCards4: {dealCardsTest4 and dealCards} is sat
//         // dealCards5: {dealCardsTest5 and dealCards} is unsat
//         // dealCards6: {dealCardsTest6 and dealCards} is sat
//         // dealCards7: {dealCardsTest7 and dealCards} is unsat
//     }
// }


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
pred cardInHandAndDeckTest1 {
    some p : Player, c : Card, r: RoundState | {
        c in p.hand.cards
        c in r.deck
    }
}

pred cardInDeckAndBoardTest1 {
    some c : Card, r: RoundState | {
        c in r.deck
        c in r.board
    }
}

pred cardInBoardAndHandTest1 {
    some p : Player, c : Card, r: RoundState | {
        c in p.hand.cards
        c in r.board
    }
}

pred cardCorrect{
    some p: Player, c: Card, r: RoundState | {
        c in p.hand.cards
        c not in r.board
        c not in r.deck
    }
}
// /** 
//  * Test suite for the wellfromedCards predicate
//  */
//  test suite for wellformedCards {
//     test expect {
//         wellformedCardsTest1: {wellformedCards} is sat
//         wellformedCardsTest2: {wellformedCards and cardInHandAndDeckTest1} is unsat 
//         wellformedCardsTest3: {wellformedCards and cardInDeckAndBoardTest1} is unsat 
//         wellformedCardsTest4: {wellformedCards and cardInBoardAndHandTest1} is unsat 
//         wellformedCardsTest5: {wellformedCards and cardCorrect} is sat 
//     }
// }

pred twoCardsSameSuit {
    some c1, c2: Card| {
        c1.suit = c2.suit
    }
}

pred twoCardsSameRank {
    some c1, c2: Card| {
        c1.rank = c2.rank
    }
}

pred twoCardsSame {
    some disj c1, c2: Card| {
        c1.suit = c2.suit
        c1.rank = c2.rank
    }
}
/**
 * Test suite for the uniqueCards predicate
 */
// test suite for uniqueCards {
//     test expect {
//         uniqueCardsTest1: {uniqueCards} is sat
//         uniqueCardsTest2: {uniqueCards and twoCardsSameSuit} is sat
//         uniqueCardsTest3: {uniqueCards and twoCardsSameRank} is sat
//         uniqueCardsTest4: {uniqueCards and twoCardsSame} is unsat
//     }
//     }

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
//     pre.bstate = preFlop
//     pre.next = post
//     post.bstate = postFlop
//     pre.board = none
//     #{post.players} = 3
//     #(pre.players) = 4
//     #(post.board) = 7

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
// }

// pred postFlopToPostTurn[pre, post: RoundState] {
//     pre.bstate = preFlop
//     pre.next = post
//     post.bstate = postFlop
//     #{pre.board} = 3
//     #(post.board) = 4

//     some disj p1, p2, p3, p4: Player {
//         p1 in pre.players
//         p2 in pre.players
//         p3 in pre.players
//         p4 in pre.players
        
//         p1 in post.players
//         p2 in post.players
//         p3 in post.players
//     }
//     some disj c1, c2, c3, c4: Card {
//         post.board = c1 + c2 + c3 + c4
//     }
// }

// pred badPostFlopToPostTurn[pre, post: RoundState] {
//     pre.bstate = postFlop
//     pre.next = post
//     post.bstate = postTurn
//     #{pre.board} = 3
//     #(post.board) = 3

//     some disj p1, p2, p3, p4: Player {
//         p1 in pre.players
//         p2 in pre.players
//         p3 in pre.players
//         p4 in pre.players
        
//         p1 in post.players
//         p2 in post.players
//         p3 in post.players
//     }
//     some disj c1, c2, c3: Card {
//         post.board = c1 + c2 + c3
//     }
// }

// pred postTurnToPostRiver[pre, post: RoundState] {
//     pre.bstate = postTurn
//     pre.next = post
//     post.bstate = postRiver
//     #{pre.board} = 4
//     #(post.board) = 5

//     some disj p1, p2, p3, p4: Player {
//         p1 in pre.players
//         p2 in pre.players
//         p3 in pre.players
//         p4 in pre.players
        
//         p1 in post.players
//         p2 in post.players
//         p3 in post.players
//     }
//     some disj c1, c2, c3, c4, c5: Card {
//         post.board = c1 + c2 + c3 + c4 + c5
//     }
// }

// pred badPostTurnToPostRiver[pre, post: RoundState] {
//     pre.bstate = postTurn
//     pre.next = post
//     post.bstate = postRiver
//     #{pre.board} = 4
//     #(post.board) = 3

//     some disj p1, p2, p3, p4: Player {
//         p1 in pre.players
//         p2 in pre.players
//         p3 in pre.players
//         p4 in pre.players
        
//         p1 in post.players
//         p2 in post.players
//         p3 in post.players
//     }
//     some disj c1, c2, c3: Card {
//         post.board = c1 + c2 + c3
//     }
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

// test suite for traces {
//     test expect {
//         vacuity: {traces} is sat
//         pairSat: {traces => {some p : Player | hasPair[p.hand.cards]}} is sat
//         // twoPairSat: {traces => {some p : Player, r: RoundState| hasTwoPair[p.hand.cards + r.board]}} is sat
//         // threeOfAKindSat: {traces => {some p : Player, r: RoundState | hasThreeofaKind[p.hand.cards + r.board]}} is sat
//         // straightSat: {traces => {some p : Player, r: RoundState | hasStraight[p.hand.cards + r.board]}} is sat
//         // flushSat: {traces => {some p : Player, r: RoundState | hasFlush[p.hand.cards + r.board]}} is sat
//         // fullHouseSat: {traces => {some p : Player, r: RoundState | hasFullHouse[p.hand.cards + r.board]}} is sat
//         // fourOfAKindSat: {traces => {some p : Player, r: RoundState | hasFourOfaKind[p.hand.cards + r.board]}} is sat
//         // straightFlushSat: {traces => {some p : Player, r: RoundState | hasStraightFlush[p.hand.cards + r.board]}} is sat
//         // royalFlushSat: {traces => {some p : Player, r: RoundState | hasRoyalFlush[p.hand.cards + r.board]}} is sat

//         // pairScoreTest: {(traces and {some p: Player, r: RoundState | hasPair[p.hand.cards + r.board]}) => player.hand.score[r] = -3} is theorem
//         // twoPairScoreTest: {(traces and {some p: Player, r: RoundState | hasTwoPair[p.hand.cards + r.board]}) => player.hand.score[r] = -2} is theorem
//         // threeOfAKindScoreTest: {(traces and {some p: Player, r: RoundState | hasThreeofaKind[p.hand.cards + r.board]}) => player.hand.score[r] = -1} is theorem
//         // straightScoreTest: {(traces and {some p: Player, r: RoundState | hasStraight[p.hand.cards + r.board]}) => player.hand.score[r] = 0} is theorem
//         // flushScoreTest: {(traces and {some p: Player, r: RoundState | hasFlush[p.hand.cards + r.board]}) => player.hand.score[r] = 1} is theorem
//         // fullHouseScoreTest: {(traces and {some p: Player, r: RoundState | hasFullHouse[p.hand.cards + r.board]}) => player.hand.score[r] = 2} is theorem
//         // fourOfAKindScoreTest: {(traces and {some p: Player, r: RoundState | hasFourOfaKind[p.hand.cards + r.board]}) => player.hand.score[r] = 3} is theorem
//         // straightFlushScoreTest: {(traces and {some p: Player, r: RoundState | hasStraightFlush[p.hand.cards + r.board]}) => player.hand.score[r] = 4} is theorem
//         // royalFlushScoreTest: {(traces and {some p: Player, r: RoundState | hasRoyalFlush[p.hand.cards + r.board]}) => player.hand.score[r] = 5} is theorem
//     }
// }

pred stillIn[p: Player] {
    all r: RoundState | {
        p in r.players
    }
}

pred lowChanceOfWinning[p: Player] {
    some r: RoundState | {
        p.hand.score[r] <= -3
    }
}

pred proc1[p: Player] {
    strategyTesting
    neverFolds[p]
}

pred proc2[p: Player] {
    strategyTesting
    highCardFold[p]
}

pred proc3[p: Player] {
    strategyTesting
    straightOrBetter[p]
}

pred proc4[p: Player] {
    strategyTesting
    bestHandInTheGame[p]
}

pred proc5[p: Player] {
    strategyTesting
    postRiverFold[p]
}


//-----------Property Tests of Strategies----------------//
// test expect {
//     vacuity1: {some p: Player | {proc1[p]}} for exactly 13 Card, 4 Player, 4 Int for optimize_rank is sat // PASS
//     isWinner1: {some p: Player | (proc1[p]) and (some r: RoundState | r.winner = p)} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat // PASS
//     // alwaysWinner1: {some p: Player | (proc1[p]) => (some r: RoundState | r.winner = p)} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is theorem //FAILS
//     neverFold1: {some p : Player | proc1[p] implies stillIn[p]} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat //PASS
//     alwaysNeverFold1: {some p : Player | proc1[p] implies stillIn[p]} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is theorem //PASS
//     lowChanceOfWinning1: {some p: Player | proc1[p] and lowChanceOfWinning[p]} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat //PASS
// }

// test expect {
//     vacuity2: {some p: Player | {proc2[p]}} for exactly 13 Card, 4 Player, 4 Int for optimize_rank is sat // PASS
// //     isWinner2: {some p: Player | (proc2[p]) and (some r: RoundState | r.winner = p)} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat // FAILS
// //     alwaysWinner2: {some p: Player | (proc2[p]) => (some r: RoundState | r.winner = p)} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is theorem //FAILS
//     neverFold1: {some p : Player | proc2[p] implies stillIn[p]} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat //PASS
// //     alwaysNeverFold2: {some p: Player | (proc[2]) => (all r:RoundState |p in r.players)} for exactly 13 Card, 4 Player, 4 Int for optimize_rank is theorem //FAILS
//     lowChanceOfWinning2: {some p: Player | proc2[p] and lowChanceOfWinning[p]} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat // PASS
// }

// test expect {
    // vacuity3: {some p: Player | {proc3[p]}} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat // PASS
    // isWinner3: {some p: Player | (proc3[p]) and (some r: RoundState | r.winner = p)} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat // PASS
//     alwaysWinner3: {some p: Player | (proc3[p]) => (some r: RoundState | r.winner = p)} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is theorem //FAILS
    // neverFold3: {some p : Player | proc3[p] implies stillIn[p]} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat //PASS
    // alwaysNeverFold3: {some p: Player | (proc3[p]) => (all r:RoundState |p in r.players)} for exactly 4 Player, 13 Card,  4 Int for optimize_rank is theorem //PASS
//     lowChanceOfWinning3: {some p: Player | proc3[p] and lowChanceOfWinning[p]} for exactly 4 Player, 13 Card, 4 Int for optimize_rank is sat //FAILS
// }

// test expect {
//     vacuity4: {some p: Player | {proc4[p]}} is sat for exactly 4 Player, 13 Card, 4 Int for optimize_rank // PASS
//     isWinner4: {some p: Player | (proc4[p]) and (some r: RoundState | r.winner = p)} is sat for exactly 4 Player, 13 Card, 4 Int for optimize_rank // PASS
//     alwaysWinner4: {some p: Player | (proc4[p]) => (some r: RoundState | r.winner = p)} is theorem for exactly 4 Player, 13 Card, 4 Int for optimize_rank //PASS
//     neverFold4: {some p : Player | proc4[p] implies stillIn[p]} is sat for exactly 4 Player, 13 Card, 4 Int for optimize_rank //PASS
//     alwaysNeverFold4: {some p: Player | (proc4[p]) => (all r:RoundState |p in r.players)} is theorem for exactly 4 Player, 13 Card, 4 Int for optimize_rank //PASS
//     lowChanceOfWinning4: {some p: Player | proc4[p] and lowChanceOfWinning[p]} is sat for exactly 4 Player, 13 Card, 4 Int for optimize_rank // FAILS
// }   

// test expect {
//     vacuity5: {some p: Player | {proc5[p]}} is sat for exactly 4 Player, 13 Card, 4 Int for optimize_rank // PASS
//     isWinner5: {some p: Player | (proc5[p]) and (some r: RoundState | r.winner = p)} is sat for exactly 4 Player, 13 Card, 4 Int for optimize_rank // PASS
//     alwaysWinner5: {some p: Player | (proc5[p]) => (some r: RoundState | r.winner = p)} is theorem for exactly 4 Player, 13 Card, 4 Int for optimize_rank //FAILS
//     neverFold5: {some p : Player | proc5[p] implies stillIn[p]} is sat for exactly 4 Player, 13 Card, 4 Int for optimize_rank //PASS
//     alwaysNeverFold5: {some p: Player | (proc5[p]) => (all r:RoundState |p in r.players)} is theorem for exactly 4 Player, 13 Card, 4 Int for optimize_rank //FAILS
//     lowChanceOfWinning5: {some p: Player | proc5[p] and lowChanceOfWinning[p]} is sat for exactly 4 Player, 13 Card, 4 Int for optimize_rank // PASS
// }