import 'package:flutter/material.dart';

/// Flutter code sample for [AnimatedContainer].

void main() => runApp(const AnimatedContainerExampleApp());

class AnimatedContainerExampleApp extends StatelessWidget {
  const AnimatedContainerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const AnimatedContainerExample(),
      ),
      theme: ThemeData(scaffoldBackgroundColor: const Color.fromARGB(255, 43, 43, 43)),
    );
  }
}

class Cardlogic {
  final Map<int, String> listofcards = {
    1: 'This is the first card text. Swipe left or right to navigate.',
    2: 'Second card: Make important decisions that affect your kingdom!', 
    3: 'Third card: The people are getting restless. What will you do?', 
    4: 'Final card: Choose wisely, your reign depends on it!'
  };
  int currentCardIndex = 1;

  String get currentCardText => listofcards[currentCardIndex] ?? 'No text available';

  void nextCard() {
    currentCardIndex = (currentCardIndex % listofcards.length) + 1;
  }

  void previousCard() {
    currentCardIndex = currentCardIndex > 1 ? currentCardIndex - 1 : listofcards.length;
  }
}

class AnimatedContainerExample extends StatefulWidget {
  const AnimatedContainerExample({super.key});

  @override
  State<AnimatedContainerExample> createState() => _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState extends State<AnimatedContainerExample> {
  bool selected = false;
  var _color = Colors.black;
  final Cardlogic cardLogic = Cardlogic();

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

        // Center content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card container (600x400)
              AnimatedContainer(
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/card_texture.png'), // Add your texture
                    fit: BoxFit.cover,
                  ),
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
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

              const SizedBox(height: 30),

              // Text display area below the card
              Container(
                width: 500,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  cardLogic.currentCardText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Navigation hints
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