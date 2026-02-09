import 'package:flutter/material.dart';
import 'package:my_love/widgets/smart_asset_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  late AnimationController _tiltController;
  bool _isLastPage = false;
  bool _isButtonPressed = false;

  final List<Map<String, String>> _pages = [
    {"title": "سلام به روی ماهت عزیزم! 🌸", "subtitle": "به دنیای شخصیِ خودت خوش اومدی. اینو ساختم فقط برای اینکه لبخند رو لبت بیارم."},
    {"title": "یه فرصت برای رشد کنار هم 🌱", "subtitle": "هر قدم کوچیکی که برمی‌داری، ضربان قلب آینده‌مونه."},
    {"title": "نوبتی هم که باشه نوبت جایزست 🎁", "subtitle": "تسک هات رو کامل کن تا کلی چیزای باحال برات باز بشه؛ از نامه‌های مخفی گرفته تا پیام‌های صوتی و سورپرایزهای جذاب!"},
  ];

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED BASE COLOR
    final Color baseColor = const Color(0xFFFFF0F5); // Lavender Blush

    return Scaffold(
      backgroundColor: baseColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Spacer
            const SizedBox(height: 40),

            // 2. Main Page Content (Carousel)
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _isLastPage = index == _pages.length - 1),
                itemBuilder: (context, index) {
                  return _buildNeumorphicPage(index, baseColor);
                },
              ),
            ),

            // 3. Bottom Control Capsule
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: _neumorphicDecoration(
                    color: baseColor,
                    radius: 50,
                    isConcave: true, // Bowl look
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicators
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: SmoothPageIndicator(
                          controller: _controller,
                          count: _pages.length,
                          effect: WormEffect(
                            spacing: 12,
                            dotWidth: 10,
                            dotHeight: 10,
                            activeDotColor: AppTheme.deepPink,
                            dotColor: AppTheme.deepPink.withOpacity(0.2), // Pink tinted inactive dots
                            type: WormType.thin,
                          ),
                        ),
                      ),

                      // Action Button
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isButtonPressed = true),
                        onTapUp: (_) {
                          setState(() => _isButtonPressed = false);
                          if (_isLastPage) {
                            _finishOnboarding();
                          } else {
                            _controller.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuint);
                          }
                        },
                        onTapCancel: () => setState(() => _isButtonPressed = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isLastPage ? 140 : 60,
                          height: 60,
                          margin: const EdgeInsets.all(5),
                          decoration: _neumorphicDecoration(
                            color: baseColor,
                            isInverse: _isButtonPressed, // Press effect
                            radius: 30,
                          ),
                          child: Center(
                            child: _isLastPage
                                ? FadeIn(
                                    child: const Text(
                                      "شروع",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepPink, letterSpacing: 1.2),
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward_rounded, color: AppTheme.deepPink, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildNeumorphicPage(int index, Color baseColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Floating Image Container
          AnimatedBuilder(
            animation: _tiltController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(_tiltController.value * 2 * math.pi) * 10),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: _neumorphicDecoration(
                    color: baseColor,
                    radius: 150,
                    isConcave: true, // Bowl shape
                  ),
                  child: Center(
                    // Inner Circle (Pop out)
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: _neumorphicDecoration(color: baseColor, radius: 110, blur: 10),
                      child: Center(
                        child: index == 0
                            ? SmartAssetImage(assetPath: "assets/icons/heart.svg", height: 100, width: 100, svgColor: AppTheme.deepPink)
                            : index == 1
                            ? SmartAssetImage(assetPath: "assets/icons/grass.svg", height: 100, width: 100)
                            : SmartAssetImage(assetPath: "assets/icons/full-gift.svg", height: 100, width: 100, svgColor: Colors.orangeAccent),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 50),

          // Text Content
          FadeInUp(
            from: 50,
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                Text(
                  _pages[index]['title']!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                ),
                const SizedBox(height: 15),
                Text(
                  _pages[index]['subtitle']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.textDark.withOpacity(0.6), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CUSTOM PINK-TINTED NEUMORPHIC LOGIC ---
  BoxDecoration _neumorphicDecoration({required Color color, double radius = 20, double blur = 15, bool isInverse = false, bool isConcave = false}) {
    // COLOR LOGIC:
    // Top shadow is pure white (Highlight)
    final Color topShadow = Colors.white;
    // Bottom shadow is NOT grey, but a Darker Pink/Purple to match the lavender theme
    final Color bottomShadow = AppTheme.deepPink.withOpacity(0.15);
    // Darker shade for gradients
    final Color darkShade = const Color(0xFFF0E0E6); // Slightly darker lavender

    if (isInverse) {
      // INSET SHADOWS (Pressed In)
      return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Gradient goes Dark -> Light to simulate depth
          colors: [darkShade, Colors.white],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      );
    } else {
      // EXTRUDED SHADOWS (Popped Out)
      return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        gradient: isConcave
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkShade, Colors.white], // Concave reverses light
              )
            : null, // Flat color handles convexity well enough with shadows
        boxShadow: [
          BoxShadow(color: bottomShadow, offset: const Offset(8, 8), blurRadius: blur),
          BoxShadow(color: topShadow, offset: const Offset(-8, -8), blurRadius: blur),
        ],
      );
    }
  }
}
