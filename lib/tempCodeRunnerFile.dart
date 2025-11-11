import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'card/card_logic.dart';

class AnimatedContainerExample extends StatefulWidget {
  const AnimatedContainerExample({super.key});

  @override
  State<AnimatedContainerExample> createState() => _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  bool selected = false;
  var _color = Colors.black;
  final CardLogic cardLogic = CardLogic();
  
  // Variables for mouse tracking
  double _cardOffsetX = 0.0;
  double _cardOffsetY = 0.0;
  
  // Track current card display
  Map<String, dynamic> _currentDisplayCard = {};

  @override
  void initState() {
    super.initState();
    _currentDisplayCard = cardLogic.currentCard;
  }

  void _handleChoice(bool isLeftChoice) {
    setState(() {
      selected = !selected;
      _color = isLeftChoice ? Colors.blue : Colors.green;
      
      // Apply the choice to game logic
      cardLogic.applyChoice(isLeftChoice);
      
      // Update displayed card
      _currentDisplayCard = cardLogic.currentCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gesture areas for left and right choices
        Row(
          children: [
            // Left choice area
            Expanded(
              child: GestureDetector(
                onTap: () => _handleChoice(true),
                child: Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.red, size: 50),
                  ),
                ),
              ),
            ),
            
            // Right choice area
            Expanded(
              child: GestureDetector(
                onTap: () => _handleChoice(false),
                child: Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(Icons.arrow_forward, color: Colors.green, size: 50),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Full-screen mouse region that captures all mouse events
        Listener(
          onPointerMove: (PointerMoveEvent event) {
            setState(() {
              // Calculate card offset based on cursor position relative to center
              final screenSize = MediaQuery.of(context).size;
              final centerX = screenSize.width / 2;
              final centerY = screenSize.height / 2;
              
              // Calculate normalized offset (-1 to 1) from center
              final normalizedX = (event.position.dx - centerX) / centerX;
              final normalizedY = (event.position.dy - centerY) / centerY;
              
              // Apply movement with some damping (reduce the effect)
              _cardOffsetX = normalizedX * 20; // Max 20px movement
              _cardOffsetY = normalizedY * 15; // Max 15px movement
            });
          },
          onPointerHover: (PointerHoverEvent event) {
            // This ensures continuous tracking even when hovering over the card
            setState(() {
              // Calculate card offset based on cursor position relative to center
              final screenSize = MediaQuery.of(context).size;
              final centerX = screenSize.width / 2;
              final centerY = screenSize.height / 2;
              
              // Calculate normalized offset (-1 to 1) from center
              final normalizedX = (event.position.dx - centerX) / centerX;
              final normalizedY = (event.position.dy - centerY) / centerY;
              
              // Apply movement with some damping (reduce the effect)
              _cardOffsetX = normalizedX * 20; // Max 20px movement
              _cardOffsetY = normalizedY * 15; // Max 15px movement
            });
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Center content - only the AnimatedContainer will move
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // We use IgnorePointer to ensure mouse events pass through to the underlying Listener
              IgnorePointer(
                child: Transform.translate(
                  offset: Offset(_cardOffsetX, _cardOffsetY),
                  child: AnimatedContainer(
                    width: 600.0,
                    height: 400.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                          offset: Offset(4 + _cardOffsetX / 5, 4 + _cardOffsetY / 5),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/card_texture.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Card header with type indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCardTypeColor(_currentDisplayCard['type']),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getCardTypeLabel(_currentDisplayCard['type']),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Day ${cardLogic.day} | Act ${cardLogic.currentAct}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),

                          // Main card content
                          Expanded(
                            child: Center(
                              child: Text(
                                _currentDisplayCard['text'] ?? 'Loading...',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),

                          
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Resource indicators below the card
              Container(
                width: 500,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8.0,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResourceIndicator('Hunger', cardLogic.resources['hunger']!, Colors.orange),
                    _buildResourceIndicator('Sanity', cardLogic.resources['sanity']!, Colors.purple),
                    _buildResourceIndicator('Money', cardLogic.resources['money']!, Colors.green),
                    _buildResourceIndicator('Rep', cardLogic.resources['reputation']!, Colors.blue),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              
              
              // Game over message
              if (cardLogic.score > 0)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Game Over! Survived ${cardLogic.day} days. Tap to restart.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceIndicator(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getCardTypeColor(String? type) {
    switch (type) {
      case 'story':
        return Colors.blue;
      case 'side_story':
        return Colors.purple;
      case 'value':
        return Colors.orange;
      case 'secret':
        return Colors.red;
      case 'random':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getCardTypeLabel(String? type) {
    switch (type) {
      case 'story':
        return 'STORY';
      case 'side_story':
        return 'SIDESTORY';
      case 'value':
        return 'EMERGENCY';
      case 'secret':
        return 'SECRET';
      case 'random':
        return 'RANDOM';
      default:
        return 'EVENT';
    }
  }
}