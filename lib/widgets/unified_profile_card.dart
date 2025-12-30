import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UnifiedProfileCard extends StatefulWidget {
  final String name;
  final String description;
  final String? photoUrl;
  final List<Widget> infoChips;
  final List<ProfileQuickAction> quickActions;
  final VoidCallback? onEdit;
  final Widget? extraContent;

  const UnifiedProfileCard({
    super.key,
    required this.name,
    required this.description,
    this.photoUrl,
    this.infoChips = const [],
    this.quickActions = const [],
    this.onEdit,
    this.extraContent,
  });

  @override
  State<UnifiedProfileCard> createState() => _UnifiedProfileCardState();
}

class _UnifiedProfileCardState extends State<UnifiedProfileCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image with scale animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: _getProfileImage(),
                        child: (widget.photoUrl == null || widget.photoUrl!.isEmpty)
                            ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name and Edit Button with staggered animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FittedBox(
                             fit: BoxFit.scaleDown,
                             child: Text(
                              widget.name,
                              style: const TextStyle(
                                color: Color(0xFF1f455b),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (widget.onEdit != null) ...[
                          const SizedBox(width: 8),
                          _AnimatedEditButton(onTap: widget.onEdit!),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description with fade animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  
                  if (widget.infoChips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 15 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: widget.infoChips,
                      ),
                    ),
                  ],

                  if (widget.quickActions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    // Responsive grid for quick actions - ensures all fit on one row
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.quickActions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final action = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: _AnimatedQuickAction(
                                action: action,
                                width: 70, // Fixed width, scaled by FittedBox
                                delay: Duration(milliseconds: 100 * index),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  
                  if (widget.extraContent != null) ...[
                    const SizedBox(height: 24),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(opacity: value, child: child);
                      },
                      child: widget.extraContent!,
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (widget.photoUrl == null || widget.photoUrl!.isEmpty) return null;
    try {
      if (widget.photoUrl!.startsWith('data:')) {
        final parts = widget.photoUrl!.split(',');
        if (parts.length > 1) {
          final base64String = parts[1];
          final bytes = base64Decode(base64String);
          return MemoryImage(bytes);
        }
      } else if (widget.photoUrl!.startsWith('http://') || widget.photoUrl!.startsWith('https://')) {
        return CachedNetworkImageProvider(widget.photoUrl!);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

class _AnimatedEditButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedEditButton({required this.onTap});

  @override
  State<_AnimatedEditButton> createState() => _AnimatedEditButtonState();
}

class _AnimatedEditButtonState extends State<_AnimatedEditButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _isHovered 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: AnimatedScale(
            scale: _isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.edit,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedQuickAction extends StatefulWidget {
  final ProfileQuickAction action;
  final double width;
  final Duration delay;

  const _AnimatedQuickAction({
    required this.action,
    required this.width,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedQuickAction> createState() => _AnimatedQuickActionState();
}

class _AnimatedQuickActionState extends State<_AnimatedQuickAction> 
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _bounceController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _bounceController.reverse();
        widget.action.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _bounceController.reverse();
      },
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isPressed 
                      ? widget.action.color.withOpacity(0.2) 
                      : widget.action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isPressed 
                        ? widget.action.color.withOpacity(0.4) 
                        : widget.action.color.withOpacity(0.2),
                  ),
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: widget.action.color.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.action.icon, 
                  color: widget.action.color, 
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.action.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileQuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  ProfileQuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
