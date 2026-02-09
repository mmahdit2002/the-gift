import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

// 1. Cloud Painter for Calendar Days
class CloudPainter extends CustomPainter {
  final bool isUnlocked;
  final bool isCompleted;

  CloudPainter({this.isUnlocked = false, this.isCompleted = false});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = isUnlocked ? (isCompleted ? AppTheme.deepPink.withOpacity(0.8) : Colors.white) : Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    if (isUnlocked) {
      paint.shader = LinearGradient(
        colors: [Colors.white, AppTheme.primaryPink.withOpacity(0.3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    Path path = Path();
    // Drawing a cute cloud shape
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.cubicTo(size.width * 0.1, size.height * 0.8, size.width * 0.4, size.height * 0.9, size.width * 0.5, size.height * 0.85);
    path.cubicTo(size.width * 0.6, size.height * 0.9, size.width * 0.9, size.height * 0.8, size.width * 0.8, size.height * 0.5);
    path.cubicTo(size.width * 0.9, size.height * 0.2, size.width * 0.6, size.height * 0.1, size.width * 0.5, size.height * 0.2);
    path.cubicTo(size.width * 0.4, size.height * 0.1, size.width * 0.1, size.height * 0.2, size.width * 0.2, size.height * 0.5);
    path.close();

    // Add shadow
    canvas.drawShadow(path, AppTheme.deepPink.withOpacity(0.2), 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Glassmorphic Container Wrapper
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;

  const GlassContainer({required this.child, this.height = 100, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(height: height, width: width, decoration: AppTheme.glassDecoration(), child: child),
      ),
    );
  }
}

// 3. Neumorphic Button
class NeuButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const NeuButton({required this.onPressed, required this.child});

  @override
  _NeuButtonState createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(15),
        decoration: AppTheme.neumorphicDecoration(isPressed: _isPressed),
        child: widget.child,
      ),
    );
  }
}
