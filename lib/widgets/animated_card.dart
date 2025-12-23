import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated card widget with fade-in and slide-up animation
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.animationCurve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.animationCurve),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.all(AppTheme.spaceMd),
            padding: widget.padding ?? const EdgeInsets.all(AppTheme.spaceLg),
            decoration: AppTheme.cardDecoration(
              color: widget.color,
              borderColor: widget.borderColor,
              borderWidth: widget.borderWidth,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
