import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:try3/game_repository.dart';
import 'package:try3/local/device_data_source.dart';
import 'package:try3/platform_utils.dart';
import 'package:try3/remote/nakama_data_source.dart';
import '../card/card_logic.dart';
import '../widgets/resource_indicator.dart';
import '../widgets/game_card.dart';
import '../card/flippable_card.dart';
import '../widgets/change_bubble.dart';
import '../card/fade_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../preferences_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
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
  bool _isFadingOut = false;
  bool _showGameOverBackground = false;
  Color _gameOverBackgroundColor = Colors.black;
  int _bestDaysSurvived = 0;
  bool _isNewRecord = false;

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
  
  // Track the last choice to get the correct reply text
  bool? _lastChoiceIsLeft;

  @override
  void initState() {
    super.initState();
     _loadBestDays();
    
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

  void _loadBestDays() async {
    final bestDays = await PreferencesService.getBestDaysSurvived();
    setState(() {
      _bestDaysSurvived = bestDays;
    });
  }

  bool get _isGameOver {
    return gameLogic.getGameOverCard() != null;
  }

  // Get the effective current card with proper reply text
  Map<String, dynamic> get _effectiveCurrentCard {
    final gameOverCard = gameLogic.getGameOverCard();
    if (gameOverCard != null) {
      return gameOverCard;
    }
    
    // For regular cards, create a copy with the appropriate reply text
    final card = _currentCard;
    if (_showReply && _lastChoiceIsLeft != null) {
      final cardWithReply = Map<String, dynamic>.from(card);
      cardWithReply['replyText'] = gameLogic.getReplyText(card, _lastChoiceIsLeft!);
      return cardWithReply;
    }
    
    return card;
  }

  

    void _calculateChoiceImpacts() {
    final leftImpact = _currentCard['leftImpact'] as Map<String, int>? ?? {};
    final rightImpact = _currentCard['rightImpact'] as Map<String, int>? ?? {};
    
    _leftChoiceHighlights = {};
    _rightChoiceHighlights = {};
    _leftChoiceChanges = Map.from(leftImpact);
    _rightChoiceChanges = Map.from(rightImpact);
    
    // Ensure all resources are present in the maps, even if they don't change
    final allResources = ['hunger', 'sanity', 'money', 'reputation'];
    for (var resource in allResources) {
      _leftChoiceChanges.putIfAbsent(resource, () => 0);
      _rightChoiceChanges.putIfAbsent(resource, () => 0);
      
      // Calculate highlight intensities based on impact magnitude
      final leftChange = _leftChoiceChanges[resource]!;
      final rightChange = _rightChoiceChanges[resource]!;
      
      _leftChoiceHighlights[resource] = (leftChange.abs() / 100.0).clamp(0.0, 1.0);
      _rightChoiceHighlights[resource] = (rightChange.abs() / 100.0).clamp(0.0, 1.0);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _startGameEndFade() {
    final currentDays = gameLogic.day;
    final isNewRecord = currentDays > _bestDaysSurvived;
  
    if (isNewRecord) {
      PreferencesService.setBestDaysSurvived(currentDays);
    }

    _submitScoreToLeaderboard(currentDays);

    setState(() {
      _isFadingOut = true;
      _isNewRecord = isNewRecord;
    });
    
    // Wait for fade out to complete, then show game over background and restart
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _showGameOverBackground = true;
        if (isNewRecord) {
          _bestDaysSurvived = currentDays;
        }
      });
      
      // Wait a moment to show the game over background, then restart
      Future.delayed(const Duration(milliseconds: 1500), () {
        _resetGame();
        setState(() {
          _isFadingOut = false;
          _showGameOverBackground = false;
          _isNewRecord = false;
        });
      });
    });
  }

    Future<void> _submitScoreToLeaderboard(int score) async {
  try {
    final GameRepository gameRepository = GameRepository(
      DeviceDataSource(),
      NakamaDataSource(),
    );
    
    final playerName = await PreferencesService.getPlayerName();
    
    await gameRepository.initSession(username: playerName);
    
    if (playerName.isNotEmpty) {
      await gameRepository.updateUsername(playerName);
    }
    
    await gameRepository.submitScore(score, leaderboardName);
    print('Score submitted successfully: $score days as $playerName');
  } catch (e) {
    print('Failed to submit score: $e');
  }
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
      
      // Update hover state based on drag position - use thresholds
      final dragThreshold = getResponsiveValue(
        context,
        mobile: 10.0,
        tablet: 15.0,
        desktop: 20.0,
      );
      
      _isHoveringLeft = _dragPosition < -dragThreshold;
      _isHoveringRight = _dragPosition > dragThreshold;
      
      // Only show highlights when clearly dragging to one side
      if (!_isHoveringLeft && !_isHoveringRight) {
        _hoverController.reverse();
      } else {
        _hoverController.forward();
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isProcessingChoice) return;
    
    setState(() {
      _isDragging = false;
      _isHoveringLeft = false;
      _isHoveringRight = false;
      _hoverController.reverse();
    });

    if (_dragPosition.abs() > 100) {
      _isProcessingChoice = true;
      
      if (_isGameOver && _currentCard['type'] == 'game_over') {
        // We're already on a game over card - any swipe starts the fade out
        _startGameEndFade();
        return;
      }
      
      if (_waitingForContinue) {
        _proceedToNextCard();
      } else {
        final bool isLeftChoice = _dragPosition < 0;
        _lastChoiceIsLeft = isLeftChoice; // Store the choice for reply text
        final Map<String, dynamic> playedCard = _currentCard;
        gameLogic.applyChoice(isLeftChoice);
        
        // Check if this choice caused a game over
        if (_isGameOver) {
          setState(() {
            _currentCard = gameLogic.getGameOverCard()!;
            _showReply = false;
            _waitingForContinue = false;
            _resetFlip = false;
            _isProcessingChoice = false;
          });
          _resetCardPosition().then((_) {
            _isProcessingChoice = false;
          });
        } else {
          _nextCard = gameLogic.currentCard;
          
          // Check if this card has reply text (using the choice-based method)
          final hasReplyText = (isLeftChoice && playedCard.containsKey('leftReplyText')) || 
                              (!isLeftChoice && playedCard.containsKey('rightReplyText')) ||
                              playedCard.containsKey('replyText');
          
          if (hasReplyText) {
            setState(() {
              _waitingForContinue = true;
              _showReply = true;
            });
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
    // Check for game over before proceeding
    if (_isGameOver && _currentCard['type'] != 'game_over') {
      setState(() {
        _currentCard = gameLogic.getGameOverCard()!;
        _showReply = false;
        _waitingForContinue = false;
        _resetFlip = false;
        _isProcessingChoice = false;
      });
      return;
    }

    if (_showReply) {
      setState(() {
        _resetFlip = true;
      });
      
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _currentCard = gameLogic.currentCard;
          _calculateChoiceImpacts();
          _showReply = false;
          _waitingForContinue = false;
          _resetFlip = false;
          _isProcessingChoice = false;
          _lastChoiceIsLeft = null; // Reset choice
        });
      });
    } else {
      setState(() {
        _currentCard = gameLogic.currentCard;
        _calculateChoiceImpacts();
        _showReply = false;
        _waitingForContinue = false;
        _isProcessingChoice = false;
        _lastChoiceIsLeft = null; // Reset choice
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

  String _getGameOverMessage() {
    if (!_isGameOver) return '';
    
    final gameOverCard = gameLogic.getGameOverCard()!;
    final reason = gameOverCard['gameOverReason'];
    
    switch (reason) {
      case 'hunger_0':
        return 'STARVATION';
      case 'sanity_0':
        return 'MADNESS';
      case 'money_0':
        return 'BANKRUPTCY';
      case 'reputation_0':
        return 'DISGRACE';
      case 'hunger_100':
        return 'SATIATION';
      case 'sanity_100':
        return 'ENLIGHTENMENT';
      case 'money_100':
        return 'WEALTH';
      case 'reputation_100':
        return 'FAME';
      default:
        return 'GAME OVER';
    }
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
      _calculateChoiceImpacts(); 
      _isNewRecord = false;
      _lastChoiceIsLeft = null;


    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isGameOver && !_isFadingOut)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetGame,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Game over background (shown after fade out)
          if (_showGameOverBackground)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: _gameOverBackgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isNewRecord) ...[
                    Icon(
                      Icons.emoji_events,
                      size: getResponsiveValue(
                        context,
                        mobile: 40.0,
                        tablet: 50.0,
                        desktop: 60.0,
                      ),
                      color: Colors.amber,
                    ),
                    SizedBox(height: getResponsiveValue(
                      context,
                      mobile: 5.0,
                      tablet: 8.0,
                      desktop: 10.0,
                    )),
                    Text(
                      'NEW RECORD!',
                      style: TextStyle(
                        fontSize: getResponsiveValue(
                          context,
                          mobile: 18.0,
                          tablet: 22.0,
                          desktop: 24.0,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: getResponsiveValue(
                      context,
                      mobile: 5.0,
                      tablet: 8.0,
                      desktop: 10.0,
                    )),
                  ],
                  Text(
                    _getGameOverMessage(),
                    style: TextStyle(
                      fontSize: getResponsiveValue(
                        context,
                        mobile: 24.0,
                        tablet: 28.0,
                        desktop: 32.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: getResponsiveValue(
                    context,
                    mobile: 5.0,
                    tablet: 8.0,
                    desktop: 10.0,
                  )),
                  Text(
                    'Survived ${gameLogic.day} days',
                    style: TextStyle(
                      fontSize: getResponsiveValue(
                        context,
                        mobile: 14.0,
                        tablet: 16.0,
                        desktop: 18.0,
                      ),
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: getResponsiveValue(
                    context,
                    mobile: 2.0,
                    tablet: 4.0,
                    desktop: 5.0,
                  )),
                  Text(
                    'Best: $_bestDaysSurvived days',
                    style: TextStyle(
                      fontSize: getResponsiveValue(
                        context,
                        mobile: 12.0,
                        tablet: 14.0,
                        desktop: 16.0,
                      ),
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: getResponsiveValue(
                    context,
                    mobile: 15.0,
                    tablet: 20.0,
                    desktop: 30.0,
                  )),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Main game content with fade transition
          if (!_showGameOverBackground)
            FadeTransitionWrapper(
              fadeIn: !_isFadingOut,
              duration: const Duration(milliseconds: 1000),
              child: _buildGameContent(),
            ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    final cardWidth = getResponsiveValue(
      context,
      mobile: 250.0,
      tablet: 280.0,
      desktop: 300.0,
    );
    
    final cardHeight = getResponsiveValue(
      context,
      mobile: 350.0,
      tablet: 380.0,
      desktop: 400.0,
    );

    final resourceSpacing = getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 70.0,
      desktop: 100.0,
    );

    return Stack(
      children: [
        // Background deck of cards (only show if not game over) - hide on mobile
        if (!_isGameOver && !isMobile) ...[
          Positioned(
            bottom: getResponsiveValue(
              context,
              mobile: 120.0,
              tablet: 140.0,
              desktop: 150.0,
            ),
            left: MediaQuery.of(context).size.width / 2 - cardWidth / 2,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: cardWidth,
                height: cardHeight,
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
            bottom: getResponsiveValue(
              context,
              mobile: 130.0,
              tablet: 150.0,
              desktop: 160.0,
            ),
            left: MediaQuery.of(context).size.width / 2 - cardWidth / 2,
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: cardWidth,
                height: cardHeight,
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
        ],
        
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
                  width: cardWidth,
                  height: cardHeight,
                  child: FlippableCard(
                    cardData: _effectiveCurrentCard,
                    showReply: _showReply,
                    resetFlip: _resetFlip,
                    onFlipComplete: _onFlipComplete,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Resource indicators (only show if not game over)
        if (!_isGameOver)
          Positioned(
            top: getResponsiveValue(
              context,
              mobile: 5.0,
              tablet: 8.0,
              desktop: 10.0,
            ),
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 16.0,
                  desktop: 0.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: resourceSpacing),
                  _buildResourceIndicatorWithHighlight(
                    'Hunger',
                    Icons.restaurant,
                    gameLogic.resources['hunger']!,
                    Colors.orange,
                  ),
                  SizedBox(width: resourceSpacing),
                  _buildResourceIndicatorWithHighlight(
                    'Sanity',
                    Icons.psychology,
                    gameLogic.resources['sanity']!,
                    Colors.purple,
                  ),
                  SizedBox(width: resourceSpacing),
                  _buildResourceIndicatorWithHighlight(
                    'Money',
                    Icons.attach_money,
                    gameLogic.resources['money']!,
                    const Color.fromARGB(255, 0, 129, 4),
                  ),
                  SizedBox(width: resourceSpacing),
                  _buildResourceIndicatorWithHighlight(
                    'Reputation',
                    Icons.thumb_up,
                    gameLogic.resources['reputation']!,
                    Colors.blue,
                  ),
                  SizedBox(width: resourceSpacing),
                ],
              ),
            ),
          ),
        
        // Day counter (only show if not game over)
        if (!_isGameOver)
          Positioned(
            top: getResponsiveValue(
              context,
              mobile: 30.0,
              tablet: 35.0,
              desktop: 40.0,
            ),
            right: getResponsiveValue(
              context,
              mobile: 10.0,
              tablet: 15.0,
              desktop: 20.0,
            ),
            child: Text(
              'Day ${gameLogic.day}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: getResponsiveValue(
                  context,
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
              ),
            ),
          ),
        
        // Choice indicators (only show if not game over and not waiting for continue)
        if (_isDragging && !_waitingForContinue && !_isProcessingChoice && !_isGameOver)
          Positioned(
            bottom: getResponsiveValue(
              context,
              mobile: 80.0,
              tablet: 90.0,
              desktop: 100.0,
            ),
            left: _dragPosition < 0 ? 
              getResponsiveValue(context, mobile: 20.0, tablet: 30.0, desktop: 50.0) : null,
            right: _dragPosition > 0 ? 
              getResponsiveValue(context, mobile: 20.0, tablet: 30.0, desktop: 50.0) : null,
            child: AnimatedOpacity(
              opacity: _isDragging ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 10),
              child: Container(
                padding: EdgeInsets.all(getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                )),
                decoration: BoxDecoration(
                  color: _dragPosition < 0 ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _dragPosition < 0 
                    ? _currentCard['leftChoice']
                    : _currentCard['rightChoice'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: getResponsiveValue(
                      context,
                      mobile: 12.0,
                      tablet: 14.0,
                      desktop: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        
        // Game over indicator (show when game over and not fading)
        if (_isDragging && _isGameOver && _currentCard['type'] == 'game_over' && !_isProcessingChoice && !_isFadingOut)
          Positioned(
            bottom: getResponsiveValue(
              context,
              mobile: 80.0,
              tablet: 90.0,
              desktop: 100.0,
            ),
            left: MediaQuery.of(context).size.width / 2 - 
              getResponsiveValue(context, mobile: 50.0, tablet: 55.0, desktop: 60.0),
            child: AnimatedOpacity(
              opacity: _isDragging ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 10),
              child: Container(
                padding: EdgeInsets.all(getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                )),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentCard['leftChoice'],
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: getResponsiveValue(
                      context,
                      mobile: 12.0,
                      tablet: 14.0,
                      desktop: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Update the resource indicator container size for mobile
  Widget _buildResourceIndicatorWithHighlight(String title, IconData icon, int value, Color color) {
    final resourceKey = title.toLowerCase();
    
    // Always show the indicator, but calculate highlight state
    final isLeftHighlighted = _isHoveringLeft && _leftChoiceHighlights.containsKey(resourceKey) && _leftChoiceHighlights[resourceKey]! > 0;
    final isRightHighlighted = _isHoveringRight && _rightChoiceHighlights.containsKey(resourceKey) && _rightChoiceHighlights[resourceKey]! > 0;
    
    Color highlightColor = Colors.transparent;
    double highlightIntensity = 0.0;
    int changeAmount = 0;
    
    if (isLeftHighlighted) {
      changeAmount = _leftChoiceChanges[resourceKey]!;
      highlightColor = changeAmount >= 0 ? Colors.green : Colors.red;
      highlightIntensity = _leftChoiceHighlights[resourceKey]! * _hoverAnimationValue;
    } else if (isRightHighlighted) {
      changeAmount = _rightChoiceChanges[resourceKey]!;
      highlightColor = changeAmount >= 0 ? Colors.green : Colors.red;
      highlightIntensity = _rightChoiceHighlights[resourceKey]! * _hoverAnimationValue;
    }
    
    final containerWidth = getResponsiveValue(
      context,
      mobile: 40.0,
      tablet: 45.0,
      desktop: 50.0,
    );
    
    final containerHeight = getResponsiveValue(
      context,
      mobile: 80.0,
      tablet: 90.0,
      desktop: 100.0,
    );

    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
          
          // Change bubble - show when highlighted AND there's an actual change
          if ((isLeftHighlighted || isRightHighlighted) && changeAmount != 0)
            Positioned(
              top: 0,
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
}