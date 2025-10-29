class CardLogic {
  // Master list of all cards with metadata
  final List<Map<String, dynamic>> allCards = [
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

  // Game state
  int currentCardIndex = 0;
  int score = 0;
  int day = 1;
  int currentAct = 1;
  
  // NEW: Track conditional card chain
  List<int> _conditionalCardChain = [];
  bool get _isInConditionalChain => _conditionalCardChain.isNotEmpty;

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
  
  // Track which cards have been played
  Set<int> playedCards = {};
  Map<String, int> storyProgress = {'act1': 0, 'act2': 0};

  CardLogic() {
    _initializeQueues();
  }

  void _initializeQueues() {
    // Separate cards by type
    final storyCards = allCards.where((card) => card['type'] == 'story').toList();
    final valueCards = allCards.where((card) => card['type'] == 'value').toList();
    final randomCards = allCards.where((card) => card['type'] == 'random').toList();
    final secretCards = allCards.where((card) => card['type'] == 'secret').toList();

    // Sort story cards by act and order
    storyCards.sort((a, b) {
      if (a['act'] != b['act']) return a['act'].compareTo(b['act']);
      return a['storyOrder'].compareTo(b['storyOrder']);
    });

    // Add current act story cards to story queue
    storyQueue.addAll(storyCards.where((card) => card['act'] == currentAct));

    // Add value and secret cards to priority queue
    priorityQueue.addAll(valueCards);
    priorityQueue.addAll(secretCards);

    // Fill main queue with random cards
    mainQueue.addAll(randomCards);
    mainQueue.shuffle();
  }

  Map<String, dynamic> get currentCard {
    if (mainQueue.isEmpty && storyQueue.isEmpty && !_isInConditionalChain) {
      return {
        'id': -1,
        'text': 'You have experienced all events. The journey continues...',
        'leftChoice': 'Restart',
        'rightChoice': 'Continue',
        'leftImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
        'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 0, 'reputation': 0},
      };
    }
    
    return _getNextAvailableCard();
  }

  Map<String, dynamic> _getNextAvailableCard() {
    // 1. Check conditional chain first (highest priority)
    if (_isInConditionalChain) {
      final nextCardId = _conditionalCardChain.first;
      final conditionalCard = _getCardById(nextCardId);
      if (!playedCards.contains(conditionalCard['id'])) {
        return conditionalCard;
      } else {
        // If conditional card was already played, remove from chain and continue
        _conditionalCardChain.removeAt(0);
        return _getNextAvailableCard();
      }
    }

    // 2. Check priority queue (emergency/value-dependent cards)
    for (var card in priorityQueue) {
      if (!playedCards.contains(card['id']) && _meetsCondition(card)) {
        return card;
      }
    }

    // 3. Check story queue next
    if (storyQueue.isNotEmpty) {
      return storyQueue[0];
    }

    // 4. Check random cards (only after first 5 cards)
    if (mainQueue.isNotEmpty && _shouldShowRandomCards()) {
      return mainQueue[0];
    }

    // Fallback
    return allCards.firstWhere((card) => !playedCards.contains(card['id']), 
        orElse: () => allCards[0]);
  }

  bool _shouldShowRandomCards() {
    return playedCards.length >= 5;
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

  String getReplyText(Map<String, dynamic> card, bool isLeftChoice) {
    if (isLeftChoice && card.containsKey('leftReplyText')) {
      return card['leftReplyText'];
    } else if (!isLeftChoice && card.containsKey('rightReplyText')) {
      return card['rightReplyText'];
    }
    
    return card['replyText'] ?? 'The story continues...';
  }

  void applyChoice(bool isLeftChoice) {
    // Check for game over condition before applying choice
    final gameOverCard = getGameOverCard();
    if (gameOverCard != null) {
      return;
    }

    final card = currentCard;
    final impact = isLeftChoice ? card['leftImpact'] : card['rightImpact'];
    
    // Apply resource changes
    resources.forEach((key, value) {
      final impactValue = impact[key];
      if (impactValue is int) {
        resources[key] = (value + impactValue).clamp(0, 100);
      }
    });
    
    // Handle conditional next cards - add to chain
    if (card.containsKey('conditionalNextCards')) {
      final conditionals = card['conditionalNextCards'] as Map<String, dynamic>;
      final choiceKey = isLeftChoice ? 'leftChoice' : 'rightChoice';
      
      if (conditionals.containsKey(choiceKey)) {
        final nextCardId = conditionals[choiceKey] as int;
        _conditionalCardChain.add(nextCardId);
      }
    }
    
    // Mark card as played
    playedCards.add(card['id']);
    
    // If this card was from conditional chain, remove it from chain
    if (_isInConditionalChain && _conditionalCardChain.first == card['id']) {
      _conditionalCardChain.removeAt(0);
    }
    
    // Remove card from appropriate queues (if it was in any queue)
    _removeCardFromQueues(card);
    
    // Update story progress for story cards (only if not in conditional chain)
    if (card['type'] == 'story' && !_isInConditionalChain) {
      storyProgress['act$currentAct'] = storyProgress['act$currentAct']! + 1;
      
      // Check if we should advance to next act
      if (_shouldAdvanceAct()) {
        currentAct++;
        _updateQueuesForNewAct();
      }
    }
    
    // Check for game over after applying choice
    final newGameOverCard = getGameOverCard();
    if (newGameOverCard != null) {
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
  }

  bool _shouldAdvanceAct() {
    final actStoryCards = allCards.where((card) => 
        card['type'] == 'story' && card['act'] == currentAct).length;
    return storyProgress['act$currentAct']! >= actStoryCards;
  }

  void _updateQueuesForNewAct() {
    final newStoryCards = allCards.where((card) => 
        card['type'] == 'story' && card['act'] == currentAct).toList();
    storyQueue.addAll(newStoryCards);
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

    // NEW: Clear conditional chain
    _conditionalCardChain.clear();
    
    mainQueue.clear();
    priorityQueue.clear();
    storyQueue.clear();
    
    _initializeQueues();
  }

  Map<String, dynamic>? getGameOverCard() {
    // Check for resource at 0
    if (resources['hunger']! <= 0) return _getCardById(100);
    if (resources['sanity']! <= 0) return _getCardById(101);
    if (resources['money']! <= 0) return _getCardById(102);
    if (resources['reputation']! <= 0) return _getCardById(103);
    
    // Check for resource at 100
    if (resources['hunger']! >= 100) return _getCardById(104);
    if (resources['sanity']! >= 100) return _getCardById(105);
    if (resources['money']! >= 100) return _getCardById(106);
    if (resources['reputation']! >= 100) return _getCardById(107);
    
    return null;
  }

  Map<String, dynamic> _getCardById(int id) {
    return allCards.firstWhere((card) => card['id'] == id);
  }
}