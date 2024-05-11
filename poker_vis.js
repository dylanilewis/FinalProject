const stage = new Stage();
let sortedStates = []; // Holds the sorted game states
let currentStateIndex = 0; // Tracker for the current state index

function sortAndLinkGameStates() {
    // Fetch all RoundState atoms
    let states = instance.signature('RoundState').atoms();

    // Manually place each state in the correct position
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
                event: 'click',
                 callback: () => {
                     prevState()
                     },
            },
        ],
});
stage.add(prevButton);


function displayPokerState() {
    sortAndLinkGameStates(); // Ensure states are sorted

    const roundState = sortedStates[currentStateIndex]; // Access the current state
     sortedStates.forEach((state, index) => {
        const stateInfo = new TextBox({
            text: `State ${state + index + 1}: ${state.bstate.id()}`,
            coords: {x: 300, y: 100 + index * 30},
            color: 'black',
            fontSize: 16
        });
        stage.add(stateInfo);
    });

    const boardDiv = new TextBox({
        text: 'Board: ',
        coords: {x: 100, y: 50},
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

    const currentTurnDiv = new TextBox({
        text: `Player Turn: ${roundState.turn}`,
        coords: {x: 300, y: 30},
        color: 'blue',
        fontSize: 16
    });
    stage.add(currentTurnDiv);

    var playersingame = roundState.players.tuples()

    // playersingame.forEach((player, index) => {
    //     const playerText = new TextBox({
    //         text: `Player ${index + 1}: ${player.hand.cards.rank}`,
    //         coords: {x: 100, y: 100 + index * 30},
    //         color: 'black',
    //         fontSize: 16
    //     });
    //     stage.add(playerText);
    // });

        const players = new TextBox({
        text: `Players: ${roundState.players.tuples()}`,
        coords: {x: 200, y: 350},
        color: 'black',
        fontSize: 16
    });
    stage.add(players);

    //testing for cards
    let rect = new Rectangle({
      coords: {x: 100, y:100},
      height: 20,
      width: 20,
      color: "pink",
      borderColor: "black",
      borderWidth: 2,
      label: "5"
  })
  stage.add(rect);
}

displayPokerState(); // Initialize the display with the first state
stage.render(svg, document); // Render the stage
