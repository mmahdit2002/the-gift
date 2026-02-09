import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:my_love/widgets/smart_asset_image.dart';
import 'dart:ui'; // Required for ImageFilter
import 'calendar_screen.dart';
import 'prize_archive_screen.dart';
import 'requirements_screen.dart';
import '../widgets/all_neccessery_widgets.dart';
import '../theme/app_theme.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundPink, // Consistent base color
      body: Stack(
        children: [
          // 1. Dreamy Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.backgroundPink, Color(0xFFFFE6EE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),

          // 2. Decorative Background Blobs
          Positioned(top: -50, left: -50, child: _buildBlob(200, AppTheme.deepPink.withOpacity(0.1))),
          Positioned(bottom: 100, right: -30, child: _buildBlob(150, Colors.white.withOpacity(0.4))),
          Positioned(top: size.height * 0.2, right: 20, child: _buildBlob(80, AppTheme.primaryPink.withOpacity(0.2))),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Header / Avatar Area
                ZoomIn(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryPink,
                          child: SmartAssetImage(assetPath: "assets/icons/heart.svg", height: 40, width: 40, svgColor: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "خوش اومدی پرنسس من",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark.withOpacity(0.8), letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- REAL GLASSMORPHIC MENU CARD ---
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      // ClipRRect is needed to contain the blur
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                        child: BackdropFilter(
                          // THE BLUR EFFECT
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3), // Milky transparent white
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFancyMenuItem(
                                  context: context,
                                  index: 0,
                                  title: "مسیر من",
                                  subtitle: "تقویم و میزان پیشرفتت رو ببین",
                                  assetPath: "assets/icons/date.svg",
                                  page: const CalendarScreen(),
                                ),
                                const SizedBox(height: 25),
                                _buildFancyMenuItem(
                                  context: context,
                                  index: 1,
                                  title: "صندوقچه گنج",
                                  subtitle: "هدیه‌ها و خاطره‌هایی که باز کردی",
                                  assetPath: "assets/icons/gift.svg",
                                  page: const PrizeArchiveScreen(),
                                ),
                                const SizedBox(height: 25),
                                _buildFancyMenuItem(
                                  context: context,
                                  index: 2,
                                  title: "ضروری‌ها",
                                  subtitle: "لینک‌ها و پیش‌نیازها",
                                  assetPath: "assets/icons/grid1.svg",
                                  page: const RequirementsScreen(),
                                ),
                                const SizedBox(height: 40), // Bottom spacing
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for background blobs
  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
      ),
    );
  }

  // Fancy Menu Item Builder
  Widget _buildFancyMenuItem({required BuildContext context, required int index, required String title, required String subtitle, required String assetPath, required Widget page}) {
    // --- EXACT COLORS FROM ONBOARDING SCREEN ---
    final Color topShadow = Colors.white;
    final Color bottomShadow = AppTheme.deepPink.withOpacity(0.15); // Lavender tinted shadow

    return FadeInLeft(
      delay: Duration(milliseconds: index * 200 + 500),
      child: NeuButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              // Icon Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundPink,
                  shape: BoxShape.circle,
                  // Updated Shadows
                  boxShadow: [
                    BoxShadow(color: topShadow, blurRadius: 5, offset: const Offset(-3, -3)),
                    BoxShadow(color: bottomShadow, blurRadius: 5, offset: const Offset(3, 3)),
                  ],
                ),
                child: SmartAssetImage(assetPath: assetPath, height: 20, width: 20, svgColor: AppTheme.deepPink),
              ),
              const SizedBox(width: 20),

              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textDark.withOpacity(0.6))),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textDark.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
