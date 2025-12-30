import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedSewingLoader extends StatefulWidget {
  final double size;
  final String? message;

  const AnimatedSewingLoader({
    super.key,
    this.size = 200,
    this.message = 'Stitching things together...',
  });

  @override
  State<AnimatedSewingLoader> createState() => _AnimatedSewingLoaderState();
}

class _AnimatedSewingLoaderState extends State<AnimatedSewingLoader> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _needleAnimation;
  late Animation<double> _wheelRotation;
  late Animation<double> _fabricAnimation;
  late Animation<double> _threadAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller for synchronized movements
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    // Pulse animation for subtle breathing effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Needle goes up and down with easing
    _needleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 20.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 20.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_mainController);

    // Hand wheel rotation
    _wheelRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.linear),
    );

    // Fabric moving from right to left
    _fabricAnimation = Tween<double>(begin: 0, end: 1).animate(_mainController);

    // Thread animation - creates stitch marks
    _threadAnimation = Tween<double>(begin: 0, end: 1).animate(_mainController);

    // Pulse for glow effect
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    const machineColor = Color(0xFF1a365d); // Deep navy blue
    const accentColor = Color(0xFFe53e3e); // Red accent for thread
    const goldColor = Color(0xFFd69e2e); // Gold for decorative elements
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Glow Background
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: widget.size * 1.4,
                height: widget.size * 1.2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: widget.size * 0.7 * _pulseAnimation.value,
                          height: widget.size * 0.7 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primaryColor.withOpacity(0.15),
                                primaryColor.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // The sewing machine
                    CustomPaint(
                      size: Size(widget.size * 1.2, widget.size),
                      painter: _TraditionalSewingMachinePainter(
                        machineColor: machineColor,
                        accentColor: accentColor,
                        goldColor: goldColor,
                      ),
                    ),
                    
                    // Animated Hand Wheel (on the right side)
                    AnimatedBuilder(
                      animation: _wheelRotation,
                      builder: (context, child) {
                        return Positioned(
                          right: widget.size * 0.08,
                          top: widget.size * 0.15,
                          child: Transform.rotate(
                            angle: _wheelRotation.value,
                            child: Container(
                              width: widget.size * 0.22,
                              height: widget.size * 0.22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: machineColor.withOpacity(0.9),
                                border: Border.all(color: goldColor, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Spokes
                                  for (int i = 0; i < 8; i++)
                                    Transform.rotate(
                                      angle: i * math.pi / 4,
                                      child: Container(
                                        width: 2,
                                        height: widget.size * 0.18,
                                        color: goldColor.withOpacity(0.6),
                                      ),
                                    ),
                                  // Center knob
                                  Container(
                                    width: widget.size * 0.06,
                                    height: widget.size * 0.06,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: goldColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Thread Spool on top
                    Positioned(
                      left: widget.size * 0.35,
                      top: widget.size * 0.02,
                      child: Container(
                        width: widget.size * 0.12,
                        height: widget.size * 0.18,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: widget.size * 0.1,
                              height: 2,
                              color: accentColor.withOpacity(0.7),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: widget.size * 0.1,
                              height: 2,
                              color: accentColor.withOpacity(0.7),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: widget.size * 0.1,
                              height: 2,
                              color: accentColor.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Thread from spool to needle area
                    AnimatedBuilder(
                      animation: _needleAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(widget.size * 1.2, widget.size),
                          painter: _ThreadPainter(
                            spoolX: widget.size * 0.41,
                            spoolY: widget.size * 0.2,
                            needleX: widget.size * 0.32,
                            needleY: widget.size * 0.52 + _needleAnimation.value,
                            color: accentColor,
                          ),
                        );
                      },
                    ),
                    
                    // Reciprocating Needle
                    AnimatedBuilder(
                      animation: _needleAnimation,
                      builder: (context, child) {
                        return Positioned(
                          left: widget.size * 0.28,
                          top: widget.size * 0.38 + _needleAnimation.value,
                          child: Column(
                            children: [
                              // Needle shaft
                              Container(
                                width: 3,
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.grey[400]!,
                                      Colors.grey[600]!,
                                    ],
                                  ),
                                ),
                              ),
                              // Needle point
                              Container(
                                width: 3,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey[700],
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(2),
                                    bottomRight: Radius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Presser Foot
                    Positioned(
                      left: widget.size * 0.22,
                      top: widget.size * 0.68,
                      child: Container(
                        width: widget.size * 0.15,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Fabric sliding under
                    AnimatedBuilder(
                      animation: _fabricAnimation,
                      builder: (context, child) {
                        return Positioned(
                          left: widget.size * 0.05 - (_fabricAnimation.value * widget.size * 0.1),
                          top: widget.size * 0.71,
                          child: Container(
                            width: widget.size * 1.0,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  Colors.grey[200]!,
                                  Colors.white.withOpacity(0.9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(15, (i) => Container(
                                width: 4,
                                height: 2,
                                color: accentColor.withOpacity(
                                  (i * 2 + (_fabricAnimation.value * 30).toInt()) % 4 == 0 ? 0.8 : 0.0
                                ),
                              )),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Loading message with animated dots
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            _AnimatedLoadingText(message: widget.message!),
          ],
        ],
      ),
    );
  }
}

class _TraditionalSewingMachinePainter extends CustomPainter {
  final Color machineColor;
  final Color accentColor;
  final Color goldColor;

  _TraditionalSewingMachinePainter({
    required this.machineColor,
    required this.accentColor,
    required this.goldColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final machinePaint = Paint()
      ..color = machineColor
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // === BASE PLATE ===
    final basePath = Path();
    basePath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.78, size.width * 0.8, size.height * 0.1),
      const Radius.circular(6),
    ));
    canvas.drawPath(basePath, machinePaint);
    
    // Base highlight
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.79, size.width * 0.78, size.height * 0.015),
      highlightPaint,
    );

    // === ARM (Curved top section) ===
    final armPath = Path();
    armPath.moveTo(size.width * 0.15, size.height * 0.35);
    armPath.quadraticBezierTo(
      size.width * 0.15, size.height * 0.12,
      size.width * 0.35, size.height * 0.08,
    );
    armPath.lineTo(size.width * 0.65, size.height * 0.08);
    armPath.quadraticBezierTo(
      size.width * 0.78, size.height * 0.08,
      size.width * 0.78, size.height * 0.2,
    );
    armPath.lineTo(size.width * 0.78, size.height * 0.45);
    armPath.lineTo(size.width * 0.68, size.height * 0.45);
    armPath.lineTo(size.width * 0.68, size.height * 0.18);
    armPath.quadraticBezierTo(
      size.width * 0.68, size.height * 0.15,
      size.width * 0.62, size.height * 0.15,
    );
    armPath.lineTo(size.width * 0.35, size.height * 0.15);
    armPath.quadraticBezierTo(
      size.width * 0.22, size.height * 0.15,
      size.width * 0.22, size.height * 0.35,
    );
    armPath.close();
    canvas.drawPath(armPath, machinePaint);

    // === PILLAR (Right support) ===
    final pillarPath = Path();
    pillarPath.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.65, size.height * 0.18, size.width * 0.15, size.height * 0.6),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(12),
      bottomRight: const Radius.circular(8),
    ));
    canvas.drawPath(pillarPath, machinePaint);

    // === HEAD/NEEDLE AREA ===
    final headPath = Path();
    headPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.28, size.width * 0.12, size.height * 0.42),
      const Radius.circular(8),
    ));
    canvas.drawPath(headPath, machinePaint);

    // Decorative arc on head
    final arcPath = Path();
    arcPath.addArc(
      Rect.fromLTWH(size.width * 0.16, size.height * 0.3, size.width * 0.16, size.height * 0.1),
      math.pi, 
      math.pi,
    );
    canvas.drawPath(arcPath, Paint()..color = goldColor.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2);

    // === Decorative Gold Details ===
    // Gold stripe on arm
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.23, size.height * 0.1, size.width * 0.42, size.height * 0.015),
      Paint()..color = goldColor,
    );

    // Gold accent on pillar
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.66, size.height * 0.5, size.width * 0.13, size.height * 0.01),
      Paint()..color = goldColor.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ThreadPainter extends CustomPainter {
  final double spoolX;
  final double spoolY;
  final double needleX;
  final double needleY;
  final Color color;

  _ThreadPainter({
    required this.spoolX,
    required this.spoolY,
    required this.needleX,
    required this.needleY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(spoolX, spoolY);
    // Thread goes through tension guides
    path.quadraticBezierTo(
      spoolX - 10, spoolY + 20,
      spoolX - 5, spoolY + 40,
    );
    path.quadraticBezierTo(
      needleX + 20, spoolY + 80,
      needleX + 3, needleY,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ThreadPainter oldDelegate) {
    return oldDelegate.needleY != needleY;
  }
}

class _AnimatedLoadingText extends StatefulWidget {
  final String message;
  
  const _AnimatedLoadingText({required this.message});

  @override
  State<_AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dotCount = (_controller.value * 4).floor() % 4;
        final dots = '.' * dotCount;
        return Text(
          '${widget.message}$dots',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1a365d).withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        );
      },
    );
  }
}
