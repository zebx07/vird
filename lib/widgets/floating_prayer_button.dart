import 'package:flutter/material.dart';

class FloatingPrayerButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingPrayerButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  _FloatingPrayerButtonState createState() => _FloatingPrayerButtonState();
}

class _FloatingPrayerButtonState extends State<FloatingPrayerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor: Colors.teal,
            child: Text(
              '🤲',
              style: TextStyle(fontSize: 24),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}// TODO Implement this library.