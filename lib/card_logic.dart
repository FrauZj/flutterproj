class CardLogic {
  // Master list of all cards with metadata
  final List<Map<String, dynamic>> allCards = [
    // Story cards (must happen in order, act-specific)
    {
      'id': 0,
      'text': 'You wake up in the darkness...',
      'leftChoice': 'so non chalant',
      'rightChoice': 'ayo???',
      'leftImpact': {'hunger': 20, 'sanity': -5, 'money': 0, 'reputation': 0},
      'rightImpact': {'hunger': 15, 'sanity': 0, 'money': -15, 'reputation': 0},
      'type': 'story',
      'act': 1,
      'storyOrder': 0,
      'replyText': 'The darkness seems to respond to your choice...', // Add this
    },
    {
      'id': 1,
      'text': 'Wtf do you mean non chalant?',
      'leftChoice': 'ermm...',
      'rightChoice': 'shut up chud',
      'leftImpact': {'hunger': 0, 'sanity': -10, 'money': 5, 'reputation': -5},
      'rightImpact': {'hunger': 0, 'sanity': 15, 'money': -20, 'reputation': 10},
      'type': 'story',
      'act': 1,
      'storyOrder': 1,
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
    },
    
    // Value-dependent cards (trigger based on resource conditions)
    {
      'id': 3,
      'text': 'You are starving! You need to find food immediately.',
      'leftChoice': 'Search for food',
      'rightChoice': 'Ignore hunger',
      'leftImpact': {'hunger': 30, 'sanity': -5, 'money': -10, 'reputation': 0},
      'rightImpact': {'hunger': -20, 'sanity': -15, 'money': 0, 'reputation': 0},
      'type': 'value',
      'condition': {'hunger': 20}, // Triggers when hunger <= 20
      'priority': 2,
    },
    {
      'id': 4,
      'text': 'You find a wallet on the street with money and ID. What do you do?',
      'leftChoice': 'Return it to the owner',
      'rightChoice': 'Keep the money',
      'leftImpact': {'hunger': 0, 'sanity': 10, 'money': 0, 'reputation': 20},
      'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 50, 'reputation': -20},
      'type': 'random',
    },
    {
      'id': 5,
      'text': 'A mysterious stranger offers you a deal...',
      'leftChoice': 'Accept',
      'rightChoice': 'Decline',
      'leftImpact': {'hunger': 0, 'sanity': -20, 'money': 100, 'reputation': -10},
      'rightImpact': {'hunger': 0, 'sanity': 5, 'money': 0, 'reputation': 5},
      'type': 'secret',
      'condition': {'money': 10}, // Triggers when money <= 10
      'priority': 1,
    },
    {
      'id': 6,
      'text': 'Your reputation precedes you. People are watching...',
      'leftChoice': 'Act confidently',
      'rightChoice': 'Stay low',
      'leftImpact': {'hunger': 0, 'sanity': 10, 'money': 0, 'reputation': 15},
      'rightImpact': {'hunger': 0, 'sanity': -5, 'money': 0, 'reputation': -5},
      'type': 'value',
      'condition': {'reputation': 25}, // Triggers when reputation <= 25
      'priority': 1,
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
    },
    
    // Side story cards (act-specific but can be interrupted)
    {
      'id': 8,
      'text': 'A familiar face appears in the crowd...',
      'leftChoice': 'Approach',
      'rightChoice': 'Avoid',
      'leftImpact': {'hunger': 0, 'sanity': 10, 'money': -5, 'reputation': 5},
      'rightImpact': {'hunger': 0, 'sanity': -5, 'money': 0, 'reputation': 0},
      'type': 'side_story',
      'act': 1,
      'storyOrder': 0,
    },
    {
      'id': 9,
      'text': 'Rumors spread about your actions...',
      'leftChoice': 'Embrace it',
      'rightChoice': 'Deny everything',
      'leftImpact': {'hunger': 0, 'sanity': -5, 'money': 0, 'reputation': 20},
      'rightImpact': {'hunger': 0, 'sanity': 5, 'money': 0, 'reputation': -10},
      'type': 'side_story',
      'act': 2,
      'storyOrder': 0,
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
    },
  ];

  // Game state
  int currentCardIndex = 0;
  int score = 0;
  int day = 1;
  int currentAct = 1;
  
  Map<String, int> resources = {
    'hunger': 50,
    'sanity': 50,
    'money': 50,
    'reputation': 50,
  };

  // Event queues
  List<Map<String, dynamic>> mainQueue = [];
  List<Map<String, dynamic>> priorityQueue = [];
  List<Map<String, dynamic>> storyQueue = [];
  List<Map<String, dynamic>> sideStoryQueue = [];
  
  // Track which cards have been played
  Set<int> playedCards = {};
  Map<String, int> storyProgress = {'act1': 0, 'act2': 0}; // Track story progress per act

  CardLogic() {
    _initializeQueues();
  }

  void _initializeQueues() {
    // Separate cards by type
    final storyCards = allCards.where((card) => card['type'] == 'story').toList();
    final sideStoryCards = allCards.where((card) => card['type'] == 'side_story').toList();
    final valueCards = allCards.where((card) => card['type'] == 'value').toList();
    final randomCards = allCards.where((card) => card['type'] == 'random').toList();
    final secretCards = allCards.where((card) => card['type'] == 'secret').toList();

    // Sort story cards by act and order
    storyCards.sort((a, b) {
      if (a['act'] != b['act']) return a['act'].compareTo(b['act']);
      return a['storyOrder'].compareTo(b['storyOrder']);
    });

    // Sort side story cards by act and order
    sideStoryCards.sort((a, b) {
      if (a['act'] != b['act']) return a['act'].compareTo(b['act']);
      return a['storyOrder'].compareTo(b['storyOrder']);
    });

    // Add current act story cards to story queue
    storyQueue.addAll(storyCards.where((card) => card['act'] == currentAct));
    
    // Add current act side story cards to side story queue
    sideStoryQueue.addAll(sideStoryCards.where((card) => card['act'] == currentAct));

    // Add value and secret cards to priority queue (they'll be checked each turn)
    priorityQueue.addAll(valueCards);
    priorityQueue.addAll(secretCards);

    // Fill main queue with random cards
    mainQueue.addAll(randomCards);
    
    // Shuffle main queue for randomness
    mainQueue.shuffle();
  }

  Map<String, dynamic> get currentCard {
    if (mainQueue.isEmpty && storyQueue.isEmpty && sideStoryQueue.isEmpty) {
      // If no cards left, return a default game over card
      return {
        'id': -1,
        'text': 'You have experienced all events. The journey continues...',
        'leftChoice': 'Restart',
        'rightChoice': 'Continue',
        'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
        'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
      };
    }
    return mainQueue.isNotEmpty ? mainQueue[0] : _getNextAvailableCard();
  }

  Map<String, dynamic> _getNextAvailableCard() {
    // Check priority queue first (emergency/value-dependent cards)
    for (var card in priorityQueue) {
      if (!playedCards.contains(card['id']) && _meetsCondition(card)) {
        return card;
      }
    }

    // Check story queue next
    if (storyQueue.isNotEmpty) {
      return storyQueue[0];
    }

    // Check side story queue
    if (sideStoryQueue.isNotEmpty) {
      return sideStoryQueue[0];
    }

    // Fallback to first available card
    return allCards.firstWhere((card) => !playedCards.contains(card['id']), 
        orElse: () => allCards[0]);
  }

  bool _meetsCondition(Map<String, dynamic> card) {
    if (!card.containsKey('condition')) return true;
    
    final condition = card['condition'] as Map<String, int>;
    for (var resource in condition.keys) {
      if (resources[resource]! <= condition[resource]!) {
        return true;
      }
    }
    return false;
  }

  void applyChoice(bool isLeftChoice) {
    final card = currentCard;
    final impact = isLeftChoice ? card['leftImpact'] : card['rightImpact'];
    
    // Apply resource changes
    resources.forEach((key, value) {
      final impactValue = impact[key];
      if (impactValue is int) {
        resources[key] = (value + impactValue).clamp(0, 100);
      }
    });
    
    // Mark card as played
    playedCards.add(card['id']);
    
    // Remove card from appropriate queue
    _removeCardFromQueues(card);
    
    // Update story progress for story cards
    if (card['type'] == 'story') {
      storyProgress['act$currentAct'] = storyProgress['act$currentAct']! + 1;
      
      // Check if we should advance to next act
      if (_shouldAdvanceAct()) {
        currentAct++;
        _updateQueuesForNewAct();
      }
    }
    
    // Check for game over
    if (resources.values.any((value) => value <= 0)) {
      score = day;
      return;
    }
    
    day++;
    
    // Refresh main queue if empty
    if (mainQueue.isEmpty) {
      _refillMainQueue();
    }
  }

  void _removeCardFromQueues(Map<String, dynamic> card) {
    mainQueue.removeWhere((c) => c['id'] == card['id']);
    priorityQueue.removeWhere((c) => c['id'] == card['id']);
    storyQueue.removeWhere((c) => c['id'] == card['id']);
    sideStoryQueue.removeWhere((c) => c['id'] == card['id']);
  }

  bool _shouldAdvanceAct() {
    // Advance act when all main story cards for current act are completed
    final actStoryCards = allCards.where((card) => 
        card['type'] == 'story' && card['act'] == currentAct).length;
    return storyProgress['act$currentAct']! >= actStoryCards;
  }

  void _updateQueuesForNewAct() {
    // Add new act's story cards to story queue
    final newStoryCards = allCards.where((card) => 
        card['type'] == 'story' && card['act'] == currentAct).toList();
    storyQueue.addAll(newStoryCards);

    // Add new act's side story cards to side story queue
    final newSideStoryCards = allCards.where((card) => 
        card['type'] == 'side_story' && card['act'] == currentAct).toList();
    sideStoryQueue.addAll(newSideStoryCards);
  }

  void _refillMainQueue() {
    final randomCards = allCards.where((card) => 
        card['type'] == 'random' && !playedCards.contains(card['id'])).toList();
    randomCards.shuffle();
    mainQueue.addAll(randomCards);
  }

  void resetGame() {
    currentCardIndex = 0;
    score = 0;
    day = 1;
    currentAct = 1;
    
    resources = {
      'hunger': 50,
      'sanity': 50,
      'money': 50,
      'reputation': 50,
    };
    
    playedCards.clear();
    storyProgress = {'act1': 0, 'act2': 0};
    
    mainQueue.clear();
    priorityQueue.clear();
    storyQueue.clear();
    sideStoryQueue.clear();
    
    _initializeQueues();
  }
}