import 'package:flutter/material.dart';

class FadeTransitionWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool fadeIn;
  final VoidCallback? onComplete;

  const FadeTransitionWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.fadeIn = true,
    this.onComplete,
  });

  @override
  State<FadeTransitionWrapper> createState() => _FadeTransitionWrapperState();
}

class _FadeTransitionWrapperState extends State<FadeTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.fadeIn) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    } else {
      _controller.value = 1.0;
    }
  }

  void fadeOut() {
    _controller.reverse().then((_) {
      widget.onComplete?.call();
    });
  }

  void fadeIn() {
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}