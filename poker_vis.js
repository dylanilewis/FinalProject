/*
  Script for poker vizualization
*/
const stage = new Stage()
let sortedStates = []; // Holds the sorted game states


// Function to manually sort and link game states
function sortAndLinkGameStates() {
    // Fetch all RoundState atoms
    let states = instance.signature('RoundState').atoms();
    const stateOrder = ["preFlop", "postFlop", "postTurn", "postRiver"]; // Define the game state order

    // Sort states based on the defined game order
    sortedStates = states.sort((a, b) => stateOrder.indexOf(a.bstate.id()) - stateOrder.indexOf(b.bstate.id()));
}
  
  // Function to display the state of the poker game
  function displayPokerState(roundState) {
    sortAndLinkGameStates();

    // Display each state for debugging
    sortedStates.forEach((state, index) => {
        const stateInfo = new TextBox({
            text: `State ${index + 1}: ${state.bstate.id()}`,
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
      text: `State: ${sortedStates[0].bstate}`,
      coords: {x: 300, y: 10},
      color: 'blue',
      fontSize: 16
    });
    stage.add(stateid);

    const currentTurnDiv = new TextBox({
      text: `Current Turn: ${sortedStates[0].turn}`,
      coords: {x: 300, y: 600},
      color: 'blue',
      fontSize: 16
    });
    stage.add(currentTurnDiv);

    const nextTurnDiv = new TextBox({
      text: `Next Turn: ${sortedStates[0].next}`,
      coords: {x: 500, y: 600},
      color: 'blue',
      fontSize: 16
    });
    stage.add(nextTurnDiv);

  
    // roundState.players.forEach((player, index) => {
    //   const hand = player.hand;
    //   const playerText = new TextBox({
    //     text: `Player ${index + 1}: ${hand.map(cardToString)} - Chips: ${player.field('chips').value()}`,
    //     coords: {x: 100, y: 100 + index * 30},
    //     color: player === roundState.turn ? 'red' : 'black',
    //     fontSize: 16
    //   });
    //   stage.add(playerText);
    // });
  }
   
  displayPokerState(sortedStates[0]);  
  stage.render(svg, document); 

//Fixed issue with random game states by sorting and linking the game states
//Buttons not yet functional 