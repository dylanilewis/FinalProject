/*
  Script for poker vizualization
*/
const stage = new Stage()

//create card elements
// function createCard(card) {
//     let cardDiv = document.createElement('div');
//     cardDiv.textContent = `${card.rank} of ${card.suit}`;
//     cardDiv.style.padding = '10px';
//     cardDiv.style.margin = '5px';
//     cardDiv.style.border = '1px solid black';
//     return cardDiv;
// }

// Function to create card text representation
function cardToString(card) {
    return `${card.rank} of ${card.suit}`;
  }
  
  // Function to display the state of the poker game
  function displayPokerState() {
    const roundState = instance.signature('RoundState').atoms()[0];
    const players = roundState.field('players')
    const boardCards = roundState.field('board')
    const currentTurn = roundState.field('turn')
  
    // Display  cards
    const boardDiv = new TextBox({
      text: 'Board: ' + boardCards.map(cardToString).join(', '),
      coords: {x: 100, y: 50},
      color: 'blue',
      fontSize: 16
    });
    stage.add(boardDiv);
  
    // Display each player's cards
    players.forEach((player, index) => {
      const hand = player.join(instance.field('hand')).join(instance.field('cards')).tuples().map(tuple => tuple.atoms()[1]);
      const playerText = new TextBox({
        text: `Player ${index + 1}: ${hand.map(cardToString).join(', ')} - Chips: ${player.field('chips').value()}`,
        coords: {x: 100, y: 100 + index * 30},
        color: player === currentTurn ? 'red' : 'black',
        fontSize: 16
      });
      stage.add(playerText);
    });
  }
   
  displayPokerState();  
  stage.render(svg, document); 