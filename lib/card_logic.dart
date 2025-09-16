class CardLogic {
  final List<Map<String, dynamic>> cards = [
    {
      'id' : 0,
      'text': 'You wake up in the darkness...',
      'leftChoice': 'so non chalant',
      'rightChoice': 'ayo???',
      'leftImpact': {'hunger': 20, 'sanity': -5, 'money': 0, 'reputation': 0},
      'rightImpact': {'hunger': 15, 'sanity': 0, 'money': -15, 'reputation': 0},
    },
    {
      'id' : 1,
      'text': 'Wtf do you mean non chalant?',
      'leftChoice': 'ermm...',
      'rightChoice': 'shut up chud',
      'leftImpact': {'hunger': 0, 'sanity': -10, 'money': 5, 'reputation': -5},
      'rightImpact': {'hunger': 0, 'sanity': 15, 'money': -20, 'reputation': 10},
    },
    { 'id' : 2,
      'text': '....',
      'leftChoice': '...',
      'rightChoice': '...',
      'leftImpact': {'hunger': -5, 'sanity': -10, 'money': 25, 'reputation': 5},
      'rightImpact': {'hunger': 0, 'sanity': 5, 'money': -10, 'reputation': 0},
    },
    {
      'id' : 3,
      'text': '...',
      'leftChoice': '...???',
      'rightChoice': '...!!!',
      'leftImpact': {'hunger': 0, 'sanity': 5, 'money': 0, 'reputation': 10},
      'rightImpact': {'hunger': 0, 'sanity': -5, 'money': 0, 'reputation': -15},
    },
    {
      'id' : 4,
      'text': 'You find a wallet on the street with money and ID. What do you do?',
      'leftChoice': 'Return it to the owner',
      'rightChoice': 'Keep the money',
      'leftImpact': {'hunger': 0, 'sanity': 10, 'money': 0, 'reputation': 20},
      'rightImpact': {'hunger': 0, 'sanity': 0, 'money': 50, 'reputation': -20},
    },
  ];

  int currentCardIndex = 0;
  int score = 0;
  int day = 1;
  
  Map<String, int> resources = {
    'hunger': 50,
    'sanity': 50,
    'money': 50,
    'reputation': 50,
  };



  Map<String, dynamic> get currentCard => cards[currentCardIndex];

  void applyChoice(bool isLeftChoice) {
    final impact = isLeftChoice ? currentCard['leftImpact'] : currentCard['rightImpact'];
    
    resources.forEach((key, value) {
      final impactValue = impact[key];
        if (impactValue is int) {
          resources[key] = (value + impactValue);
        }
    });
    
    // dbd
    if (resources.values.any((value) => value <= 0)) {
      score = day;
      return;
    }
    
    // top 10 placeholders
    currentCardIndex = (currentCardIndex + 1) % cards.length;
    day++;
  }

  void resetGame() {
    currentCardIndex = 0;
    score = 0;
    day = 1;
    resources = {
      'hunger': 50,
      'sanity': 50,
      'money': 50,
      'reputation': 50,
    };
  }


  void nextCard() {
    currentCardIndex = (currentCardIndex % cards.length) + 1;
  }

  void previousCard() {
    currentCardIndex = currentCardIndex > 1 ? currentCardIndex - 1 : cards.length;
  }
}