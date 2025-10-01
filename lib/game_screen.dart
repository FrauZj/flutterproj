import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'card_logic.dart';
import 'widgets/resource_indicator.dart';
import 'widgets/game_card.dart';
import 'widgets/game_over_card.dart';
import 'flippable_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final CardLogic gameLogic = CardLogic();
  late AnimationController _animationController;
  double _dragPosition = 0.0;
  bool _isDragging = false;
  Offset? _dragStart;
  bool _gameOver = false;
  bool _showReply = false;
  bool _waitingForContinue = false;
  bool _resetFlip = false;
  bool _isProcessingChoice = false; // Add this to prevent multiple triggers
  
  Map<String, dynamic> _currentCard = {};
  Map<String, dynamic> _nextCard = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _currentCard = gameLogic.currentCard;
    _nextCard = _currentCard;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    if (_gameOver || _isProcessingChoice) return;
    setState(() {
      _isDragging = true;
      _dragStart = details.localPosition;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_gameOver || _isProcessingChoice || _dragStart == null) return;
    setState(() {
      _dragPosition = details.localPosition.dx - _dragStart!.dx;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_gameOver || _isProcessingChoice) return;
    
    setState(() {
      _isDragging = false;
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
    // First reset the card position
    _resetCardPosition().then((_) {
      // Then flip back to front if we were showing reply
      if (_showReply) {
        setState(() {
          _resetFlip = true;
        });
        
        // Wait for flip animation, then update card
        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            _currentCard = _nextCard;
            _showReply = false;
            _waitingForContinue = false;
            _resetFlip = false;
            _isProcessingChoice = false;
          });
        });
      } else {
        // No flip needed, just update card
        setState(() {
          _currentCard = _nextCard;
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
                ResourceIndicator(
                  title: 'Hunger',
                  icon: Icons.restaurant,
                  value: gameLogic.resources['hunger']!,
                  color: Colors.orange,
                ),
                ResourceIndicator(
                  title: 'Sanity',
                  icon: Icons.psychology,
                  value: gameLogic.resources['sanity']!,
                  color: Colors.purple,
                ),
                ResourceIndicator(
                  title: 'Money',
                  icon: Icons.attach_money,
                  value: gameLogic.resources['money']!,
                  color: Colors.green,
                ),
                ResourceIndicator(
                  title: 'Reputation',
                  icon: Icons.thumb_up,
                  value: gameLogic.resources['reputation']!,
                  color: Colors.blue,
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