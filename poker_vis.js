const stage = new Stage();
let sortedStates = []; // Holds the sorted game states
let currentStateIndex = 3; // Tracker for the current state index

//sorts states in order
function sortAndLinkGameStates() {
    // Fetch all RoundState atoms
    let states = instance.signature('RoundState').atoms();

    states.forEach(state => {
        const stateType = state.bstate.id();
        switch(stateType) {
            case "preFlop0":
                sortedStates[0] = state;
                break;
            case "postFlop0":
                sortedStates[1] = state;
                break;
            case "postTurn0":
                sortedStates[2] = state;
                break;
            case "postRiver0":
                sortedStates[3] = state;
                break;
            default:
                console.log("Unrecognized state type:", stateType);
        }
    });
    // // Ensure all states are filled and none are null (optional error handling)
    // if (sortedStates.includes(null)) {
    //     console.error("Error: Not all game states were found!", sortedStates);
    // } does not work
}

//get names
function getAtomName(atom) {
  if (atom) {
    return atom.toString().replace('Test', '').replace(/\d+$/, ''); 
  }
  return "none"; 
}

//function that takes in a player atom and fixes the name
function getPlayerName(atom) {
    let atomName = atom.toString();

    if (atomName.includes("Player0")) {
        return "Player 1";
    } else if (atomName.includes("Player1")) {
        return "Player 2";
    } else if (atomName.includes("Player2")) {
        return "Player 3";
    } else if (atomName.includes("Player3")) {
        return "Player 4";
    } else {
        return "Unknown Player"; 
    }
}

//converts the score to a string of a players hand score
function getHandDescription(score) {
    const descriptions = {
        5: "Royal Flush",
        4: "Straight Flush",
        3: "Four of a Kind",
        2: "Full House",
        1: "Flush",
        0: "Straight",
        '-1': "Three of a Kind", // negatives are strings
        '-2': "Two Pair",
        '-3': "Pair",
        '-4': "High Card"
    };
    return descriptions[score.toString()] || "Unknown Hand"; 
}


//function that is called to display the game
function displayPokerState() {
    sortAndLinkGameStates(); 
    const roundState = sortedStates[currentStateIndex]; 

    //Board label
    const boardDiv = new TextBox({
        text: 'Board: ',
        coords: {x: 300, y: 150},
        color: 'black',
        fontSize: 16
    });
    stage.add(boardDiv);

    //Shows what state the game is in
    const stateName = getAtomName(roundState.bstate)
    const stateid = new TextBox({
        text: `Current State: ${stateName}`,
        coords: {x: 350, y: 10},
        color: 'black',
        fontSize: 16
    });
    stage.add(stateid);

    //getting player data to get and place cards
    var playersingame = roundState.players.tuples()
    playersingame.forEach((player, pindex) => {
      //getting player cards  
      var playerCards = player.join(hand).join(cards).tuples()
       
       //getting player score
        var playerHandScore = player.join(hand).join(score).tuples()
        const scoreValue = playerHandScore[currentStateIndex].atoms()[1]
        const handScore = getHandDescription(scoreValue)
        
        //player name and score labels
        const playerText = new TextBox({
            text: `${getPlayerName(player)}: `,
            coords: {x: 50, y: 100 + pindex * 87.5},
            color: 'black',
            fontSize: 16
        });
        stage.add(playerText);

        const scoreText = new TextBox({
            text: `Score: ${handScore} `,
            coords: {x: 50, y: 115 + pindex * 88},
            color: 'black',
            fontSize: 10
        });
        stage.add(scoreText);

        //Print out the cards
        playerCards.forEach((card, cindex) => {
            var rankname = getAtomName(card.join(rank));
            var suitname = getAtomName(card.join(suit));
          const cardshape = new Rectangle({
            coords: {x: 100 + cindex * 75, y:75 + pindex * 85},
            height: 75,
            width: 50,
            labelLocation: "center",
            color: "lightgrey",
            borderColor: "black",
            borderWidth: 0.5,
            label: `${rankname} \n ${suitname} `,
            labelColor: "bold",
            labelSize: 7
        })
        stage.add(cardshape);
        });
//end of player loop
    });

    //Display cards on the Board
    var boardCards = roundState.board.tuples();
    boardCards.forEach((card, cindex) => {
        var rankname = getAtomName(card.join(rank));
        var suitname = getAtomName(card.join(suit));
        const cardshape = new Rectangle({
            coords: {x: 275 + cindex * 100, y: 175},
            height: 112.5,
            width: 72.5,
            labelLocation: "center",
            color: "lightgrey",
            borderColor: "black",
            borderWidth: 1,
            label: `${rankname} \n ${suitname}`,
            labelColor: "bold",
            labelSize: 10
        })
        stage.add(cardshape);
    });

    //in final round declare a winner:
    if (currentStateIndex == 3) {
        var winner = getPlayerName(roundState.winner);
        var playerHandScore = roundState.winner.join(hand).join(score).tuples()
        const scoreValue = playerHandScore[currentStateIndex].atoms()[1]

        const handScore = getHandDescription(scoreValue)
 
        
        const winnerText = new TextBox({
            text: `${winner +  ' wins with ' + handScore}!`,
            coords: {x: 500, y: 100},
            color: 'green',
            fontSize: 25
        });
        stage.add(winnerText);
    }
}


displayPokerState(); // Initialize the display with the first state
stage.render(svg, document); // Render the stage
