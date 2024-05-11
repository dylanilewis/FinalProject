const stage = new Stage();
let sortedStates = []; // Holds the sorted game states
let currentStateIndex = 3; // Tracker for the current state index

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

function getAtomName(atom) {
  if (atom) {
    return atom.toString().replace('Test', '').replace(/\d+$/, ''); // Removes 'Test' and trailing digits
  }
  return "none";
}


function getWinName(atom) {
  if (atom) {
    return atom.toString().replace('Test', '').replace(/\[/, ''); // Removes 'Test' and trailing digits
  }
  return "none";
}

function nextState() {
  var last_state = sortedStates.length - 1;
  if (currentStateIndex < last_state) {
    currentStateIndex += 1;
  }
  stage.render(svg,document);
}

function prevState() {
  if (currentStateIndex != 0) {
    currentStateIndex -= 1;
  }
  stage.render(svg,document);
}

// var nextButton = new TextBox({
//         text: '+',
//         coords: {x: 500, y: 500},
//         fontSize: 200,
//         events: [
//             {
//                 event: "click", 
//                 callback: () => {
//                 nextState();
//       },
//       },
//     ],
// },);
// stage.add(nextButton);

// var prevButton = new TextBox({
//         text: '-',
//         coords: {x: 200, y: 500},
//         fontSize: 200,
//         events: [
//             {
//                 event: "click",
//                  callback: function () {
//                      prevState()
//                      },
//             },
//         ],
// });
// stage.add(prevButton);


function displayPokerState() {
    sortAndLinkGameStates(); // Ensure states are sorted

    const roundState = sortedStates[currentStateIndex]; // Access the current state
    const boardDiv = new TextBox({
        text: 'Board: ',
        coords: {x: 300, y: 150},
        color: 'blue',
        fontSize: 16
    });
    stage.add(boardDiv);

    const stateName = getAtomName(roundState.bstate)
    const stateid = new TextBox({
        text: `Current State: ${stateName}`,
        coords: {x: 350, y: 10},
        color: 'black',
        fontSize: 16
    });
    stage.add(stateid);

    var playersingame = roundState.players.tuples()
//getting player data to get and place cards
    playersingame.forEach((player, pindex) => {
        var playerCards = player.join(hand).join(cards).tuples()

        const playerText = new TextBox({
            text: `Player ${pindex + 1}: `,
            coords: {x: 50, y: 100 + pindex * 87.5},
            color: 'black',
            fontSize: 16
        });
        stage.add(playerText);

        //here I need another for loop to print out the cards
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
            label: `${rankname} \n ${suitname}`,
            labelColor: "bold",
            labelSize: 7
        })
        stage.add(cardshape);
        });
//End of player loop
    });
//Same for Board
    var boardCards = roundState.board.tuples();
    boardCards.forEach((card, cindex) => {
        var rankname = getAtomName(card.join(rank));
        var suitname = getAtomName(card.join(suit));
        const cardshape = new Rectangle({
            coords: {x: 275 + cindex * 65, y: 175},
            height: 75,
            width: 50,
            labelLocation: "center",
            color: "lightgrey",
            borderColor: "black",
            borderWidth: 0.5,
            label: `${rankname} \n ${suitname}`,
            labelColor: "bold",
            labelSize: 7
        })
        stage.add(cardshape);
    });

    //in final round declare a winner:
    if (currentStateIndex == 3) {
        var winner = getWinName(roundState.winner);
        
        const winnerText = new TextBox({
            text: `Winner: ${winner}!`,
            coords: {x: 325, y: 100},
            color: 'green',
            fontSize: 16
        });
        stage.add(winnerText);
    }
}

displayPokerState(); // Initialize the display
stage.render(svg, document); 
