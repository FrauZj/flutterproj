import 'package:flutter/material.dart';

class Fcolor extends StatefulWidget {
  const Fcolor({super.key, required this.height});
  final int height;

  @override
  State<Fcolor> createState() => _FcolorState();
}

class _FcolorState extends State<Fcolor> {
  bool selected = false;
  

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      child: const FlutterLogo(size: 75));
    }
}