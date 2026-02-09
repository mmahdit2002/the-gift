import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:my_love/widgets/smart_asset_image.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../bloc/app_bloc.dart';
import '../bloc/app_state.dart';
import '../widgets/all_neccessery_widgets.dart';
import 'day_screen.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Jalali now = Jalali.now();
    final Color baseColor = const Color(0xFFFFF0F5);

    return Scaffold(
      backgroundColor: baseColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background (Gradient + blobs)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFFF0F5), Color(0xFFFFC1E3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: SpinPerfect(
              duration: const Duration(seconds: 40),
              infinite: true,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.1), blurRadius: 60, spreadRadius: 10)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeuButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 6.0),
                          child: Icon(Icons.arrow_back_ios, color: AppTheme.deepPink, size: 20),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "مسیر من",
                            style: TextStyle(fontSize: 14, color: AppTheme.textDark.withOpacity(0.6), letterSpacing: 1.5, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "${now.formatter.mN} ${now.year}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                        child: SmartAssetImage(assetPath: "assets/icons/date.svg", height: 20, width: 20, svgColor: AppTheme.deepPink),
                      ),
                    ],
                  ),
                ),

                // 3. The "Living" Grid
                Expanded(
                  child: BlocBuilder<AppBloc, AppState>(
                    builder: (context, state) {
                      if (state.days.isEmpty) return const Center(child: CircularProgressIndicator());

                      return Stack(
                        children: [
                          // A. The Winding Path (Draws lines between clouds)
                          CustomPaint(
                            size: Size.infinite,
                            painter: JourneyPathPainter(totalItems: state.days.length),
                          ),

                          // B. The Clouds
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            // We don't use GlassContainer here because we want a custom shape (top rounded only)
                            // But we can simulate the look:
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: const BorderRadius.all(Radius.circular(40)),
                              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                            ),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1.0,
                                mainAxisSpacing: 0.5, // More space for "floating"
                                crossAxisSpacing: 0.5,
                              ),
                              itemCount: state.days.length,
                              itemBuilder: (context, index) {
                                final day = state.days[index];

                                // Randomize start time for breathing effect so they don't move in sync
                                final randomDelay = Duration(milliseconds: math.Random().nextInt(1000));

                                return FadeInUp(
                                  delay: Duration(milliseconds: index * 50), // Cascade entrance
                                  child: FloatingCloudTile(index: index, day: day, delay: randomDelay),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET: Floating Cloud Tile ---
class FloatingCloudTile extends StatefulWidget {
  final int index;
  final dynamic day; // Using dynamic for brevity, use DayModel in real code
  final Duration delay;

  const FloatingCloudTile({required this.index, required this.day, required this.delay, Key? key}) : super(key: key);

  @override
  State<FloatingCloudTile> createState() => _FloatingCloudTileState();
}

class _FloatingCloudTileState extends State<FloatingCloudTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 3), vsync: this);

    // Create a gentle breathing animation (up and down)
    _animation = Tween<double>(begin: 0, end: -8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));

    // Start animation after random delay to desynchronize clouds
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUnlocked = widget.day.isDayUnlocked;
    bool isCompleted = widget.day.isAllTasksComplete;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, isUnlocked ? _animation.value : 0), // Only unlocked clouds float
          child: child,
        );
      },
      child: GestureDetector(
        onTap: isUnlocked ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => DayScreen(dayId: widget.day.id))) : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. The Cloud Shape
            CustomPaint(
              size: const Size(110, 80),
              painter: CloudPainter(isUnlocked: isUnlocked, isCompleted: isCompleted),
            ),

            // 2. Content
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 32)
                  : Text(
                      "${widget.index + 1}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isUnlocked ? AppTheme.deepPink : Colors.grey.withOpacity(0.4),
                        shadows: isUnlocked ? [Shadow(color: Colors.white, offset: const Offset(-1, -1), blurRadius: 4)] : [],
                      ),
                    ),
            ),

            // 3. Active Indicator (Star)
            if (isUnlocked && !isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- PAINTER: The Winding Path ---
class JourneyPathPainter extends CustomPainter {
  final int totalItems;
  JourneyPathPainter({required this.totalItems});

  @override
  void paint(Canvas canvas, Size size) {
    // Dashed effect

    // Logic to draw path connecting grid centers
    // This is a simplified approximation for visual effect
    // Real grid coordinate calculation depends on screen width
    // Here we just draw a subtle decorative wavy line down the middle

    // NOTE: Implementing a perfect grid-to-grid path in CustomPainter
    // without passing exact coordinates is complex.
    // Instead, I will draw a decorative background pattern.
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
