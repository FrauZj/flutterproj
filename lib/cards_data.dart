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
    'text': '....',
    'leftChoice': '...',
    'rightChoice': '...',
    'leftImpact': {'hunger': -5, 'sanity': -10, 'money': 25, 'reputation': 5},
    'rightImpact': {'hunger': 0, 'sanity': 5, 'money': -10, 'reputation': 0},
    'type': 'story',
    'act': 1,
    'storyOrder': 2,
    // Choice-based reply texts
    'leftReplyText': 'Silence speaks volumes.',
    'rightReplyText': 'More silence follows.',
  },

  // Act 2 story cards
  {
    'id': 7,
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