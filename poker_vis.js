const stage = new Stage();
let sortedStates = []; // Holds the sorted game states
let currentStateIndex = 0; // Tracker for the current state index

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
  // This function retrieves the name of an atom and removes 'Test' or other unwanted parts.
  if (atom) {
    return atom.toString().replace('Test', '').replace(/\d+$/, ''); // Removes 'Test' and trailing digits
  }
  return "none"; // Default return value if atom is undefined
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

var nextButton = new TextBox({
        text: '+',
        coords: {x: 500, y: 500},
        fontSize: 200,
        events: [
            {
                event: "click", 
                callback: () => {
                nextState();
      },
      },
    ],
},);
stage.add(nextButton);

var prevButton = new TextBox({
        text: '-',
        coords: {x: 200, y: 500},
        fontSize: 200,
        events: [
            {
                event: "click",
                 callback: function () {
                     prevState()
                     },
            },
        ],
});
stage.add(prevButton);


function displayPokerState() {
    sortAndLinkGameStates(); // Ensure states are sorted

    const roundState = sortedStates[currentStateIndex]; // Access the current state
    //  sortedStates.forEach((state, index) => {
    //     const stateInfo = new TextBox({
    //         text: `State ${state + (index + 1)}: ${state.bstate.id()}`,
    //         coords: {x: 300, y: 100 + index * 30},
    //         color: 'black',
    //         fontSize: 16
    //     });
    //     stage.add(stateInfo);
    // });

    const boardDiv = new TextBox({
        text: 'Board: ',
        coords: {x: 475, y: 50},
        color: 'blue',
        fontSize: 16
    });
    stage.add(boardDiv);

    const stateid = new TextBox({
        text: `Current State: ${roundState.bstate}`,
        coords: {x: 300, y: 10},
        color: 'blue',
        fontSize: 16
    });
    stage.add(stateid);

    var playersingame = roundState.players.tuples()
//getting player data to get and place cards
    playersingame.forEach((player, pindex) => {
        var playerCards = player.join(hand).join(cards).tuples()

        const playerText = new TextBox({
            text: `Player ${pindex + 1}: `,
            coords: {x: 100, y: 100 + pindex * 87.5},
            color: 'black',
            fontSize: 16
        });
        stage.add(playerText);

        //here I need another for loop to print out the cards
        playerCards.forEach((card, cindex) => {
            var rankname = getAtomName(card.join(rank));
            var suitname = getAtomName(card.join(suit));
          const cardshape = new Rectangle({
            coords: {x: 150 + cindex * 75, y:75 + pindex * 85},
            height: 75,
            width: 50,
            labelLocation: "center",
            color: "lightgrey",
            borderColor: "black",
            borderWidth: 1,
            label: `${rankname} \n ${suitname}`,
            labelSize: 7
        })
        stage.add(cardshape);
        });


//end of player loop
    });

        const players = new TextBox({
        text: `Players: ${roundState.players.tuples()}`,
        coords: {x: 175, y: 450},
        color: 'black',
        fontSize: 16
    });
    stage.add(players);
}

displayPokerState(); // Initialize the display with the first state
stage.render(svg, document); // Render the stage
