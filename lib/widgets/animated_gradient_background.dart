import 'package:flutter/material.dart';

/// An animated gradient background that smoothly transitions between colors
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<List<Color>> gradientSets;
  final Duration animationDuration;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.gradientSets,
    this.animationDuration = const Duration(seconds: 6),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentGradientIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentGradientIndex = (_currentGradientIndex + 1) % widget.gradientSets.length;
        });
        _controller.reset();
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGradient = widget.gradientSets[_currentGradientIndex];
    final nextGradient = widget.gradientSets[(_currentGradientIndex + 1) % widget.gradientSets.length];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(currentGradient[0], nextGradient[0], _controller.value)!,
                Color.lerp(currentGradient[1], nextGradient[1], _controller.value)!,
                if (currentGradient.length > 2)
                  Color.lerp(currentGradient[2], nextGradient[2], _controller.value)!,
              ],
              begin: widget.begin,
              end: widget.end,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
