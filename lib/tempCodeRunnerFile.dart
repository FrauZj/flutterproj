import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'card_logic.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gesture areas for left and right swipes
        Row(
          children: [
            // Left side GestureDetector
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selected = !selected;
                    _color = Colors.blue;
                    cardLogic.previousCard();
                  });
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            
            // Right side GestureDetector
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selected = !selected;
                    _color = Colors.green;
                    cardLogic.nextCard();
                  });
                },
                child: Container(color: Colors.transparent),
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
                    child: Center(
                      child: Text(
                        'Card ${cardLogic.currentCardIndex}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Text display area below the card (does NOT move with cursor)
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
                child: Text(
                  cardLogic.currentCard['text'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Navigation hints (does NOT move with cursor)
              const Text(
                '← Swipe left or right →',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}