#lang forge/temporal

open "poker.frg"

// /**
//  * PLEASE READ
//  * Some of the tests related to the later predicates of this file fail. We encountered a bug that did
//  * not allow us to run any forge file, and we could not fix it for a while so some of the tests had to be written
//  * without even being able to run them. All the tests deal with the constraints that the predicates should be enforcing.
//  */

// pred dealCardsTest1{
//     all p: Player | some disj c1, c2: Card | {
//         c1 in p.hand.cards
//         c2 in p.hand.cards
//     }
// }

// pred dealCardsTest2{
//     some p: Player | some c1, c2: Card |{
//         c1 = c2
//         p.hand.cards = c1 + c2
//     }
// }

// pred dealCardsTest3{
//     all p: Player | {
//         #(p.hand.cards) = 3
//     }
// }

// /**
//  * Test suite for the dealCards predicate
//  */
// test suite for dealCards {
//     test expect {
//         t1: {dealCardsTest1 and dealCards} is sat
//         t2: {dealCardsTest2 and dealCards} is unsat
//         t3: {dealCardsTest3 and dealCards} is unsat
//     }
// }

// pred playersChipsGood{
//     all p: Player | {
//         p.chips = 5
//         p.bet = 0
//         }
// }

// pred playersChipsBad{
//     some p: Player | {
//         p.chips = 3
//         p.bet = 3}
// }

// pred playerBadBet{
//     some p: Player | {p.bet = 3}
// }

// pred playerGoodBet{
//     some p: Player | {p.bet = 0}
// }

// pred goodRoundState[s: RoundState]{
//     s.highestBet = 0
//     s.board = none
//     // s' = postFlop
//     s.highestBet = 0
//     s.pot = 0
// }

// pred badRoundState[s: RoundState]{
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
//         t11: {some r: RoundState | playersChipsGood and goodRoundState[r] and initRound[r]} is sat
//         t22: {some r: RoundState | playersChipsBad and goodRoundState[r] and initRound[r]} is unsat
//         t33: {some r: RoundState | playersChipsGood and badRoundState[r] and initRound[r]} is unsat
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

test suite for initRound {
    test expect {
        init: {initRound} is sat
    }
}

test suite for validTransition {
    test expect {
        valid: {validTransition} is sat
        // validInit: {initRound and validTransition} is sat
    }
}