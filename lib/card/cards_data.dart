class CardsData {
static final List<Map<String, dynamic>> allCards = [
  // Story cards (must happen in order, act-specific)
  {
    'id': 0,
    'text': 'You wake up at the docks.',
    'leftChoice': 'Wake up',
    'rightChoice': 'Keep sleeping',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': -10, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 0,
    // Choice-based reply texts
    'leftReplyText': 'You feel well-rested.',
    'rightReplyText': 'You decide to sleep a little longer...',
    'conditionalNextCards': {
      'rightChoice': 1001, // This will interrupt story flow
    },
  },
  {
    'id': 1001,
    'text': 'You wake up at the docks. Even more tired than before.',
    'leftChoice': 'Wake up',
    'rightChoice': 'Wake up',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'side_story', // This is now invoked by conditional
    'act': 1,
    // Choice-based reply texts
    'leftReplyText': 'You feel like shit waking up after a long sleep...',
    'rightReplyText': 'You feel like shit waking up after a long sleep...',
    // No conditionalNextCards, so story will resume after this
  },
  
  {
    'id': 1,
    'text': 'You see a vending machine, looming with its bright lights.',
    'leftChoice': 'Come closer',
    'rightChoice': 'Ignore',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 1,
    // Choice-based reply texts
    'leftReplyText': 'You mutter something incoherent and move on.',
    'rightReplyText': 'You confidently dismiss the machine.',
    'conditionalNextCards': {
      'leftChoice': 1002, // This will interrupt story flow
    },
  },
  {
    'id': 1002,
    'text': 'Vending machine buzzes at you.',
    'leftChoice': 'Buy a can of soda',
    'rightChoice': 'Walk away',
    'leftImpact': {'hunger': 5, 'sanity': 20, 'money': -10, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'side_story', // This is now invoked by conditional
    'act': 1,
    // Choice-based reply texts
    'leftReplyText': 'You take a sip from the can you just bought. It feels refreshing.',
    // This side story has its own conditional chain
    'conditionalNextCards': {
      'leftChoice': 1003,
    },
    },
    {
      'id': 1003,
      'text': 'The soda was surprisingly good. You feel energized.',
      'leftChoice': 'Continue',
      'rightChoice': 'Continue',
      'leftImpact': {'hunger': 5, 'sanity': 10, 'money': 0, 'reputation': 0},
      'rightImpact': {'hunger': 5, 'sanity': 10, 'money': 0, 'reputation': 0},
      'type': 'side_story',
      'act': 1,
      // No more conditionals, so story will resume after this
    },
    {
      'id': 2,
      'text': 'Stranger asks you for some money. He seems to be in a hurry.',
      'leftChoice': 'Give him money',
      'rightChoice': 'Ignore.',
      'leftImpact': {'hunger': 0, 'sanity': 0, 'money': -20, 'reputation': 5},
      'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
      'type': 'story',
      'act': 1,
      'storyOrder': 2,
      'leftReplyText': 'You dont like the feel of your wallet emptying, but the sence of self-righteousness overwhelmed you in the moment.',
      'rightReplyText': 'Noone needs your money more than you.',
    },

  {
    'id': 3,
    'text': 'A patrol drone hovers at the end of the alley, its red sensor sweeping back and forth.',
    'leftChoice': 'Wait for it to pass',
    'rightChoice': 'Duck into a doorway',
    'leftImpact': {'hunger': 0, 'sanity': -10, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': -5, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 3,
    'leftReplyText': 'The drone lingers for a tense minute before moving on.',
    'rightReplyText': 'You slip into the shadows, heart pounding.',
  },

  {
    'id': 4,
    'text': 'You find a faded poster torn from a wall. It shows a symbol you don\'t recognize, with the words "Remember the Coast" scrawled underneath.',
    'leftChoice': 'Pocket the poster',
    'rightChoice': 'Leave it be',
    'leftImpact': {'hunger': 0, 'sanity': 5, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 4,
    'leftReplyText': 'You fold the paper carefully. A small act of defiance.',
    'rightReplyText': 'You let the wind take it. Some things are not worth the risk.',
    'conditionalNextCards': {
      'leftChoice': 2001, // Triggers a side story about the symbol
    },
  },

  {
    'id': 2001,
    'text': 'Later, a stranger in a worn-out coat glances at your pocket, where the poster peeks out. He gives you a barely perceptible nod.',
    'leftChoice': 'Nod back',
    'rightChoice': 'Ignore him',
    'leftImpact': {'hunger': 0, 'sanity': 10, 'money': 0, 'reputation': 10},
    'rightImpact': {'hunger': 0, 'sanity': -5, 'money': 0, 'reputation': 0},
    'type': 'side_story',
    'act': 1,
    'leftReplyText': 'A silent understanding passes between you.',
    'rightReplyText': 'You look away, pretending you saw nothing.',
  },

  {
    'id': 5,
    'text': 'A public terminal flickers with a canned message from the Civil Protection Bureau: "Compliance is Community. Report Unsettled Behavior."',
    'leftChoice': 'Watch the message',
    'rightChoice': 'Look away',
    'leftImpact': {'hunger': 0, 'sanity': -10, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': -5, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 5,
    'leftReplyText': 'The cheerful, automated voice sends a chill down your spine.',
    'rightReplyText': 'You keep your head down, but the words echo in your mind.',
  },

  {
    'id': 6,
    'text': 'The smell of stale beer and disinfectant hits you. A bar named "The Last Stop" is open, its windows grimy.',
    'leftChoice': 'Enter the bar',
    'rightChoice': 'Walk past',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': -15, 'reputation': 0},
    'rightImpact': {'hunger': -5, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 6,
    'leftReplyText': 'You push the heavy door open. Conversations die down for a moment.',
    'rightReplyText': 'You continue down the street, the noise fading behind you.',
    'conditionalNextCards': {
      'leftChoice': 2002, // Triggers the bar scene
    },
  },

  {
    'id': 2002,
    'text': 'Inside, the bartender eyes you without a word. A man at the counter slides an empty glass towards you.',
    'leftChoice': 'Sit down',
    'rightChoice': 'Leave immediately',
    'leftImpact': {'hunger': 10, 'sanity': 15, 'money': -20, 'reputation': 5},
    'rightImpact': {'hunger': 0, 'sanity': -10, 'money': 0, 'reputation': 0},
    'type': 'side_story',
    'act': 1,
    'leftReplyText': 'You buy a drink. For a little while, the world feels less heavy.',
    'rightReplyText': 'The feeling of being watched is too strong. You retreat back outside.',
  },

  // ... (your existing Act 2 card, id 7, would follow after these)

  // --- NEW ADDITIONAL ACT 1 STORY CARDS ---

  {
    'id': 8,
    'text': 'A water dispenser in a broken-down transit station still has a trickle of clean water.',
    'leftChoice': 'Drink your fill',
    'rightChoice': 'Fill a bottle if you have one',
    'leftImpact': {'hunger': 10, 'sanity': 5, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 15, 'sanity': 10, 'money': 0, 'reputation': 0}, // Assumes the player has a bottle
    'type': 'story',
    'act': 1,
    'storyOrder': 7,
    'leftReplyText': 'The water is cold and washes the dust from your throat.',
    'rightReplyText': 'You secure a precious reserve of clean water for later.',
  },

  {
    'id': 9,
    'text': 'You see two CP officers "questioning" a shopkeeper. His face is pale with fear.',
    'leftChoice': 'Keep walking',
    'rightChoice': 'Linger and watch',
    'leftImpact': {'hunger': 0, 'sanity': -10, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': -15, 'money': 0, 'reputation': -5},
    'type': 'story',
    'act': 1,
    'storyOrder': 8,
    'leftReplyText': 'You mind your own business, a familiar shame settling in your gut.',
    'rightReplyText': 'One of the officers glares at you. "Move along, citizen."',
  },

  {
    'id': 10,
    'text': 'A child has dropped their small, hand-stitched toy in the street. They look about to cry.',
    'leftChoice': 'Pick it up for them',
    'rightChoice': 'Don\'t get involved',
    'leftImpact': {'hunger': 0, 'sanity': 10, 'money': 0, 'reputation': 5},
    'rightImpact': {'hunger': 0, 'sanity': -5, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 9,
    'leftReplyText': 'The child smiles weakly as you return the toy. Their parent pulls them away quickly.',
    'rightReplyText': 'You look away as the child starts to wail.',
  },

  {
    'id': 11,
    'text': 'A man in a long coat is selling goods from a briefcase in a secluded underpass.',
    'leftChoice': 'See what he has',
    'rightChoice': 'Avoid him',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 10,
    'leftReplyText': 'He opens the case slightly, revealing ration bars and batteries.',
    'rightReplyText': 'Black market deals are a sure way to get noticed. You keep your distance.',
    'conditionalNextCards': {
      'leftChoice': 2003,
    },
  },

  {
    'id': 2003,
    'text': '"Batteries. Good ones. Keep your light on when the patrols cut the power," the man whispers.',
    'leftChoice': 'Buy batteries',
    'rightChoice': 'Buy a ration bar',
    'leftImpact': {'hunger': 0, 'sanity': 5, 'money': -15, 'reputation': 0},
    'rightImpact': {'hunger': 20, 'sanity': 0, 'money': -10, 'reputation': 0},
    'type': 'side_story',
    'act': 1,
    'leftReplyText': 'You pocket the batteries. A small piece of security.',
    'rightReplyText': 'The bar is bland but filling. It staves off the hunger.',
  },

  {
    'id': 12,
    'text': 'A sewer grate is slightly ajar, leading to the darkness below. A faint, damp smell rises from it.',
    'leftChoice': 'Investigate',
    'rightChoice': 'Keep to the streets',
    'leftImpact': {'hunger': -5, 'sanity': -10, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 11,
    'leftReplyText': 'You slip into the damp darkness, leaving the world above behind.',
    'rightReplyText': 'Some darknesses are better left unexplored.',
    'conditionalNextCards': {
      'leftChoice': 2004,
    },
  },

  {
    'id': 2004,
    'text': 'In the tunnel, you find a small, hidden alcove with a sleeping bag and a few canned goods. A temporary refuge.',
    'leftChoice': 'Take a can of food',
    'rightChoice': 'Leave it all, rest for a bit',
    'leftImpact': {'hunger': 25, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 10, 'sanity': 20, 'money': 0, 'reputation': 0},
    'type': 'side_story',
    'act': 1,
    'leftReplyText': 'You take the food. Whoever owns this will understand.',
    'rightReplyText': 'A few hours of safe, uninterrupted sleep is a rare gift.',
  },

  {
    'id': 13,
    'text': 'A loudspeaker on a pole crackles to life. "CURFEW IN EFFECT. ALL CITIZENS RETURN TO THEIR DESIGNATED SECTORS."',
    'leftChoice': 'Find a place to hide',
    'rightChoice': 'Try to get "home" quickly',
    'leftImpact': {'hunger': -5, 'sanity': -5, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': -10, 'sanity': -15, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 12,
    'leftReplyText': 'You duck into a ruined building, listening to the boots march past.',
    'rightReplyText': 'You run through back alleys, the sound of patrols all around you.',
  },

  {
    'id': 14,
    'text': 'You find a discarded CP helmet, its visor cracked. The internal comms unit is dead.',
    'leftChoice': 'Put it on as a disguise',
    'rightChoice': 'Smash it under your boot',
    'leftImpact': {'hunger': 0, 'sanity': -10, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 10, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 13,
    'leftReplyText': 'The weight of it feels wrong. You feel like a imposter in your own skin.',
    'rightReplyText': 'The plastic cracks satisfyingly. A small, pointless rebellion.',
  },

  {
    'id': 15,
    'text': 'An old woman beckons you from a doorway. "You look lost. The patrols are thick tonight. Come in, quickly."',
    'leftChoice': 'Accept her offer',
    'rightChoice': 'Refuse and hurry away',
    'leftImpact': {'hunger': 15, 'sanity': 15, 'money': 0, 'reputation': 10},
    'rightImpact': {'hunger': 0, 'sanity': -10, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 14,
    'leftReplyText': 'She gives you a bowl of thin soup and a safe corner for the night.',
    'rightReplyText': 'Trust is a luxury you can\'t afford. You disappear into the night.',
  },
  // Act 2 story cards
  {
    'id': 201,
    'text': 'The world outside begins to change...',
    'leftChoice': 'Explore',
    'rightChoice': 'Hide',
    'leftImpact': {'hunger': -10, 'sanity': -10, 'money': 5, 'reputation': 0},
    'rightImpact': {'hunger': -5, 'sanity': 5, 'money': 0, 'reputation': 0},
    'type': 'story',
    'act': 2,
    'storyOrder': 0,
    // Choice-based reply texts
    'leftReplyText': 'You venture into the unknown.',
    'rightReplyText': 'You find a safe place to wait it out.',
  },
  
  // Random events 
  {
    'id': 10,
    'text': 'A sudden rainstorm catches you unprepared.',
    'leftChoice': 'Find shelter',
    'rightChoice': 'Keep going',
    'leftImpact': {'hunger': -5, 'sanity': 5, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': -10, 'sanity': -10, 'money': 0, 'reputation': 0},
    'type': 'random',
    // Choice-based reply texts
    'leftReplyText': 'You find dry shelter until the storm passes.',
    'rightReplyText': 'You get soaked but press onward.',
  },
  
  // Game over cards
  {
    'id': 100,
    'text': 'You have starved to death. Your journey ends here.',
    'leftChoice': 'Try Again',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'game_over',
    'gameOverReason': 'hunger_0',
  },
  {
    'id': 101,
    'text': 'You have lost your mind completely. The darkness consumes you.',
    'leftChoice': 'Try Again',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'game_over',
    'gameOverReason': 'sanity_0',
  },
  {
    'id': 102,
    'text': 'You are completely bankrupt. Without resources, you cannot continue.',
    'leftChoice': 'Try Again',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'game_over',
    'gameOverReason': 'money_0',
  },
  {
    'id': 103,
    'text': 'Your reputation is completely destroyed. No one will help you now.',
    'leftChoice': 'Try Again',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'game_over',
    'gameOverReason': 'reputation_0',
  },
  
  // Special achievement cards for each resource at 100
  {
    'id': 104,
    'text': 'You have achieved perfect nourishment! But contentment makes you complacent...',
    'leftChoice': 'Continue Journey',
    'rightChoice': 'Keep Going',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'game_over',
    'gameOverReason': 'hunger_100',
  },
  {
    'id': 105,
    'text': 'Your mind has reached perfect clarity! But enlightenment separates you from this world...',
    'leftChoice': 'New Path',
    'rightChoice': 'Begin Again',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'game_over',
    'gameOverReason': 'sanity_100',
  },
  {
    'id': 106,
    'text': 'You have unimaginable wealth! But money cannot buy meaning in this journey...',
    'leftChoice': 'Try Again',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'game_over',
    'gameOverReason': 'money_100',
  },
  {
    'id': 107,
    'text': 'You are universally respected! But fame isolates you from authentic connections...',
    'leftChoice': 'Try Again',
    'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
    'type': 'game_over',
    'gameOverReason': 'reputation_100',
  },
];
}