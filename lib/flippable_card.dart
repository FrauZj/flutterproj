import 'package:flutter/material.dart';

class FlippableCard extends StatefulWidget {
  final Map<String, dynamic> cardData;
  final bool showReply;
  final VoidCallback onFlipComplete;
  final bool resetFlip;

  const FlippableCard({
    super.key,
    required this.cardData,
    required this.showReply,
    required this.onFlipComplete,
    this.resetFlip = false,
  });

  @override
  State<FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(FlippableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Flip to back when showReply becomes true
    if (widget.showReply && !oldWidget.showReply && _isFront) {
      _flipToBack();
    }
    
    // Flip back to front when resetFlip becomes true
    if (widget.resetFlip && !oldWidget.resetFlip && !_isFront) {
      _flipToFront();
    }
  }

  void _flipToBack() {
    _controller.forward().then((_) {
      widget.onFlipComplete();
    });
    setState(() {
      _isFront = false;
    });
  }

  void _flipToFront() {
    _controller.reverse().then((_) {
      setState(() {
        _isFront = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * 3.14159;
        
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: _animation.value < 0.5 
              ? _buildFrontCard(angle)
              : _buildBackCard(angle),
        );
      },
    );
  }

  Widget _buildFrontCard(double angle) {
    return Transform(
      transform: Matrix4.identity()..rotateY(angle > 1.57 ? 3.14159 : 0),
      alignment: Alignment.center,
      child: Opacity(
        opacity: 1.0 - (_animation.value * 2).clamp(0.0, 1.0),
        child: _buildCardFrontContent(),
      ),
    );
  }

  Widget _buildBackCard(double angle) {
    return Transform(
      transform: Matrix4.identity()..rotateY(angle > 1.57 ? 0 : 3.14159),
      alignment: Alignment.center,
      child: Opacity(
        opacity: (_animation.value - 0.5) * 2,
        child: _buildCardBackContent(),
      ),
    );
  }

  Widget _buildCardFrontContent() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 40, color: Colors.white54),
            const SizedBox(height: 20),
            Text(
              widget.cardData['text'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBackContent() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble, size: 40, color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              widget.cardData['replyText'] ?? 'The story continues...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Swipe any direction to continue...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}