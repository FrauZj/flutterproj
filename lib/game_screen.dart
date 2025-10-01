import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'card_logic.dart';
import 'widgets/resource_indicator.dart';
import 'widgets/game_card.dart';
import 'widgets/game_over_card.dart';
import 'flippable_card.dart';
import 'widgets/change_bubble.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin { // Changed this line
  final CardLogic gameLogic = CardLogic();
  late AnimationController _animationController;
  double _dragPosition = 0.0;
  bool _isDragging = false;
  Offset? _dragStart;
  bool _gameOver = false;
  bool _showReply = false;
  bool _waitingForContinue = false;
  bool _resetFlip = false;
  bool _isProcessingChoice = false;

  Map<String, double> _leftChoiceHighlights = {};
  Map<String, double> _rightChoiceHighlights = {};
  Map<String, int> _leftChoiceChanges = {};
  Map<String, int> _rightChoiceChanges = {};
  double _hoverAnimationValue = 0.0;
  bool _isHoveringLeft = false;
  bool _isHoveringRight = false;
  late AnimationController _hoverController;
  
  Map<String, dynamic> _currentCard = {};
  Map<String, dynamic> _nextCard = {};

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _hoverController.addListener(() {
      setState(() {
        _hoverAnimationValue = _hoverController.value;
      });
    });
    
    _currentCard = gameLogic.currentCard;
    _nextCard = _currentCard;
    _calculateChoiceImpacts();
  }


Widget _buildResourceIndicatorWithHighlight(String title, IconData icon, int value, Color color) {
  final isLeftHighlighted = _isHoveringLeft && _leftChoiceHighlights[title.toLowerCase()]! > 0;
  final isRightHighlighted = _isHoveringRight && _rightChoiceHighlights[title.toLowerCase()]! > 0;
  
  Color highlightColor = Colors.transparent;
  double highlightIntensity = 0.0;
  int changeAmount = 0;
  
  if (isLeftHighlighted) {
    changeAmount = _leftChoiceChanges[title.toLowerCase()]!;
    highlightColor = changeAmount >= 0 ? Colors.green : Colors.red;
    highlightIntensity = _leftChoiceHighlights[title.toLowerCase()]! * _hoverAnimationValue;
  } else if (isRightHighlighted) {
    changeAmount = _rightChoiceChanges[title.toLowerCase()]!;
    highlightColor = changeAmount >= 0 ? Colors.green : Colors.red;
    highlightIntensity = _rightChoiceHighlights[title.toLowerCase()]! * _hoverAnimationValue;
  }
  
  return SizedBox(
    width: 50, // Fixed width to prevent layout shifts
    height: 100, // Fixed height to accommodate bubble + indicator
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Main resource indicator positioned at bottom
        Positioned(
          bottom: 0,
          child: ResourceIndicator(
            title: title,
            icon: icon,
            value: value,
            color: color,
            isHighlighted: isLeftHighlighted || isRightHighlighted,
            highlightColor: highlightColor,
            highlightIntensity: highlightIntensity,
          ),
        ),
        
        // Change bubble positioned above the indicator
        if ((isLeftHighlighted || isRightHighlighted) && changeAmount.abs() > 0)
          Positioned(
            top: 0, // Position at the top of the container
            child: ChangeBubble(
              changeAmount: changeAmount,
              isPositive: changeAmount >= 0,
              scale: highlightIntensity,
            ),
          ),
      ],
    ),
  );
}
  void _calculateChoiceImpacts() {
  final leftImpact = _currentCard['leftImpact'] as Map<String, int>;
  final rightImpact = _currentCard['rightImpact'] as Map<String, int>;
  
  _leftChoiceHighlights = {};
  _rightChoiceHighlights = {};
  _leftChoiceChanges = leftImpact;
  _rightChoiceChanges = rightImpact;
  
  // Calculate highlight intensities based on impact magnitude
  leftImpact.forEach((resource, change) {
    _leftChoiceHighlights[resource] = (change.abs() / 100.0).clamp(0.0, 1.0);
  });
  
  rightImpact.forEach((resource, change) {
    _rightChoiceHighlights[resource] = (change.abs() / 100.0).clamp(0.0, 1.0);
  });
}
  @override
void dispose() {
  _hoverController.dispose();
  super.dispose();
}

    void _onDragStart(DragStartDetails details) {
    if (_gameOver || _isProcessingChoice) return;
    setState(() {
      _isDragging = true;
      _dragStart = details.localPosition;
      
      // Determine if hovering left or right side
      final screenWidth = MediaQuery.of(context).size.width;
      final isLeftHover = details.localPosition.dx < screenWidth / 2;
      _isHoveringLeft = isLeftHover;
      _isHoveringRight = !isLeftHover;
      
      // Start hover animation
      _hoverController.forward();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_gameOver || _isProcessingChoice || _dragStart == null) return;
    setState(() {
      _dragPosition = details.localPosition.dx - _dragStart!.dx;
      
      // Update hover state based on drag position
      _isHoveringLeft = _dragPosition < -20;
      _isHoveringRight = _dragPosition > 20;
      
      if (!_isHoveringLeft && !_isHoveringRight) {
        _hoverController.reverse();
      } else {
        _hoverController.forward();
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_gameOver || _isProcessingChoice) return;
    
    setState(() {
          _isDragging = false;
          _isHoveringLeft = false;
          _isHoveringRight = false;
          _hoverController.reverse();
    });

    if (_dragPosition.abs() > 100) {
      _isProcessingChoice = true; // Prevent multiple triggers
      
      if (_waitingForContinue) {
        // This is a reply card swipe - any direction continues
        _proceedToNextCard();
      } else {
        // Normal card swipe
        final bool isLeftChoice = _dragPosition < 0;
        final Map<String, dynamic> playedCard = _currentCard;
        gameLogic.applyChoice(isLeftChoice);
        _nextCard = gameLogic.currentCard;
        
        if (gameLogic.score > 0) {
          setState(() {
            _gameOver = true;
            _isProcessingChoice = false;
          });
        } else {
          if (playedCard.containsKey('replyText') && playedCard['replyText'] != null) {
            setState(() {
              _waitingForContinue = true;
              _showReply = true;
            });
            // Reset position immediately when showing reply
            _resetCardPosition().then((_) {
              _isProcessingChoice = false;
            });
          } else {
            _proceedToNextCard();
          }
        }
      }
    } else {
      _resetCardPosition().then((_) {
        _isProcessingChoice = false;
      });
    }
  }

  void _proceedToNextCard() {
  _resetCardPosition().then((_) {
    if (_showReply) {
      setState(() {
        _resetFlip = true;
      });
      
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _currentCard = _nextCard;
          _calculateChoiceImpacts(); // Recalculate for new card
          _showReply = false;
          _waitingForContinue = false;
          _resetFlip = false;
          _isProcessingChoice = false;
        });
      });
    } else {
      setState(() {
        _currentCard = _nextCard;
        _calculateChoiceImpacts(); // Recalculate for new card
        _showReply = false;
        _waitingForContinue = false;
        _isProcessingChoice = false;
      });
    }
  });
}

  Future<void> _resetCardPosition() {
    return _animationController.forward(from: 0.0).then((_) {
      setState(() {
        _dragPosition = 0.0;
      });
    });
  }

  void _onFlipComplete() {
    // Flip to back complete
  }

  void _resetGame() {
  setState(() {
    gameLogic.resetGame();
    _gameOver = false;
    _dragPosition = 0.0;
    _showReply = false;
    _waitingForContinue = false;
    _resetFlip = false;
    _isProcessingChoice = false;
    _currentCard = gameLogic.currentCard;
    _nextCard = _currentCard;
    _isHoveringLeft = false;
    _isHoveringRight = false;
    _hoverController.reverse();
    _calculateChoiceImpacts(); // Recalculate for new game
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameApp'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_gameOver)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetGame,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background deck of cards
          Positioned(
            bottom: 150,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Main card
          Center(
            child: GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Transform.translate(
                offset: Offset(_dragPosition, 0),
                child: Transform.rotate(
                  angle: _dragPosition * 0.001,
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: _gameOver 
                      ? GameOverCard(day: gameLogic.day, onReset: _resetGame)
                      : FlippableCard(
                          cardData: _currentCard,
                          showReply: _showReply,
                          resetFlip: _resetFlip,
                          onFlipComplete: _onFlipComplete,
                        ),
                  ),
                ),
              ),
            ),
          ),
          
          // Resource indicators
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 100,
              children: [
                _buildResourceIndicatorWithHighlight(
                  'Hunger',
                  Icons.restaurant,
                  gameLogic.resources['hunger']!,
                  Colors.orange,
                ),
                _buildResourceIndicatorWithHighlight(
                  'Sanity',
                  Icons.psychology,
                  gameLogic.resources['sanity']!,
                  Colors.purple,
                ),
                _buildResourceIndicatorWithHighlight(
                  'Money',
                  Icons.attach_money,
                  gameLogic.resources['money']!,
                  Colors.green,
                ),
                _buildResourceIndicatorWithHighlight(
                  'Reputation',
                  Icons.thumb_up,
                  gameLogic.resources['reputation']!,
                  Colors.blue,
                ),
              ],
            ),
          ),
          
          // Day counter
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              'Day ${gameLogic.day}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          
          // Choice indicators
          if (_isDragging && !_waitingForContinue && !_isProcessingChoice)
            Positioned(
              bottom: 100,
              left: _dragPosition < 0 ? 50 : null,
              right: _dragPosition > 0 ? 50 : null,
              child: AnimatedOpacity(
                opacity: _isDragging ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _dragPosition < 0 ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _dragPosition < 0 
                      ? _currentCard['leftChoice']
                      : _currentCard['rightChoice'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          
          // Reply card indicator
          if (_isDragging && _waitingForContinue && !_isProcessingChoice)
            Positioned(
              bottom: 100,
              left: MediaQuery.of(context).size.width / 2 - 60,
              child: AnimatedOpacity(
                opacity: _isDragging ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Continue...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
        
      ),
    );
  }
}