import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // Assuming this contains your AppTheme

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();
  factory ToastManager() => _instance;
  ToastManager._internal();

  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  void showToast({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor, // Used as accent color for icon
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_isVisible) _removeToast();

    _overlayEntry = OverlayEntry(
      builder: (context) => _NeumorphicToastWidget(message: message, icon: icon, accentColor: backgroundColor ?? AppTheme.deepPink, duration: duration, onDismiss: _removeToast),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isVisible = true;
  }

  void _removeToast() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }
}

class _NeumorphicToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? accentColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _NeumorphicToastWidget({required this.message, this.icon, this.accentColor, required this.duration, required this.onDismiss});

  @override
  State<_NeumorphicToastWidget> createState() => _NeumorphicToastWidgetState();
}

class _NeumorphicToastWidgetState extends State<_NeumorphicToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400), reverseDuration: const Duration(milliseconds: 300));

    // CHANGED: Slide from BOTTOM (Offset(0.0, 1.0) -> Offset(0.0, 0.0))
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack, reverseCurve: Curves.easeInBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED: Use DayScreen base color
    final Color toastBg = const Color(0xFFFFF0F5);
    final Color shadowDark = const Color(0xFF8B80A8).withOpacity(0.2);
    final Color shadowLight = Colors.white;

    return Positioned(
      // CHANGED: Position at bottom instead of top
      bottom: MediaQuery.of(context).padding.bottom + 40,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dismissible(
              key: UniqueKey(),
              // CHANGED: Swipe DOWN to dismiss since it's at the bottom
              direction: DismissDirection.down,
              onDismissed: (_) => widget.onDismiss(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: toastBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    // Toast Floating Shadow
                    BoxShadow(color: shadowDark, offset: const Offset(4, 4), blurRadius: 12),
                    BoxShadow(color: shadowLight, offset: const Offset(-2, -2), blurRadius: 4),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        // ICON PLACE (Preserved your exact shadow structure)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: toastBg,
                            boxShadow: [
                              // Bottom-Right Highlight
                              BoxShadow(color: shadowLight.withOpacity(0.6), offset: const Offset(2, 2), blurRadius: 2),
                              // Top-Left Shadow
                              BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(-2, -2), blurRadius: 3),
                            ],
                          ),
                          child: Icon(widget.icon, color: widget.accentColor ?? AppTheme.deepPink, size: 20),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: AppTheme.textDark, // Matches app text color
                            fontSize: 14,
                            fontFamily: 'Vazir',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
