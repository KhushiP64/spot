import 'package:flutter/material.dart';

class BlinkingDot extends StatefulWidget {
  final double size;
  final Color color;

  const BlinkingDot({super.key, this.size = 5.0, this.color = Colors.blue});

  @override
  BlinkingDotState createState() => BlinkingDotState();
}

class BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Loop animation back and forth
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }
}
