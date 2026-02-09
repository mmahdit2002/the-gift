import 'package:flutter/material.dart';
import 'package:my_love/widgets/smart_asset_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui'; // REQUIRED for ImageFilter (Blur)
import '../theme/app_theme.dart';
import '../widgets/all_neccessery_widgets.dart';

class RequirementsScreen extends StatelessWidget {
  const RequirementsScreen({super.key});

  final List<Map<String, String>> courses = const [
    {"name": "دوره اول فیگما", "url": "https://help.figma.com/hc/en-us/sections/30880632542743-Figma-Design-for-beginners", "assetPath": "assets/icons/figma.svg"},
    {"name": "دوره دوم فیگما", "url": "https://downloadlynet.ir/2022/15/70746/03/figma-ui-ux-design-essentials/20/?#/70746-udemy-212635025705.html", "assetPath": "assets/icons/figma.svg"},
    {"name": "دوره سوم فیگما", "url": "https://downloadlynet.ir/2023/11/102211/08/figma-ui-ux-design-advanced/21/?#/102211-udemy-212637020305.html", "assetPath": "assets/icons/figma.svg"},
    {
      "name": "دوره چهارم فیگما",
      "url": "https://downloadlynet.ir/2023/15/90312/01/complete-figma-megacourse-ui-ux-design-beginner-to-expert/20/?#/90312-udemy-212646022705.html",
      "assetPath": "assets/icons/figma.svg",
    },
    {"name": "دوره اول MBA", "url": "https://downloadly.ir/elearning/video-tutorials/oxford-mba-the-fifty-hour-mba-master-course/", "assetPath": "assets/icons/MBA1.svg"},
    {"name": "دوره دوم MBA", "url": "https://downloadlynet.ir/2020/17/6312/03/mba-in-a-box-business-lessons-from-a-ceo/17/?#/6312-udemy-212653020905.html", "assetPath": "assets/icons/MBA2.svg"},
    {"name": "برای واحدهای آموزشیت", "url": "https://maktabkhooneh.org/", "assetPath": "assets/icons/study.svg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPink,
      body: Stack(
        children: [
          // 1. Dynamic Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.backgroundPink, Color(0xFFFFE6EE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),

          // 2. Animated Blob (Top Right)
          Positioned(
            top: -50,
            right: -50,
            child: SpinPerfect(
              duration: const Duration(seconds: 25),
              infinite: true,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.25),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.15), blurRadius: 50, spreadRadius: 10)],
                ),
              ),
            ),
          ),

          // 3. Animated Blob (Bottom Left)
          Positioned(
            bottom: 50,
            left: -30,
            child: FadeInUp(
              duration: const Duration(seconds: 2),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.1), blurRadius: 40, spreadRadius: 5)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                  child: Row(
                    children: [
                      NeuButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 6.0),
                          child: Icon(Icons.arrow_back_ios, color: AppTheme.deepPink, size: 20),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ضروری‌ها",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          Text("لینک‌ها و پیش‌نیازها", style: TextStyle(fontSize: 14, color: AppTheme.textDark.withOpacity(0.6))),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- REAL GLASS CONTAINER ---
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          // THE BLUR EFFECT
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            ),
                            child: ListView.separated(
                              clipBehavior: Clip.none,
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                              itemCount: courses.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 20),
                              itemBuilder: (context, index) {
                                return _buildResourceCard(context, courses[index], index);
                              },
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

  Widget _buildResourceCard(BuildContext context, Map<String, String> item, int index) {
    // --- EXACT COLORS FROM ONBOARDING SCREEN (used only for the icon now) ---
    final Color topShadow = Colors.white;
    final Color bottomShadow = AppTheme.deepPink.withOpacity(0.15);

    return FadeInLeft(
      delay: Duration(milliseconds: index * 200),
      child: NeuButton(
        // ← This is what gives you the real neumorphic press animation (same as MenuScreen)
        onPressed: () async {
          final uri = Uri.parse(item['url']!);
          await launchUrl(uri);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Icon Container (Inset/Neumorphic) - unchanged
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundPink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: topShadow, offset: const Offset(-3, -3), blurRadius: 5),
                    BoxShadow(color: bottomShadow, offset: const Offset(3, 3), blurRadius: 5),
                  ],
                ),
                child: SmartAssetImage(assetPath: item['assetPath']!, height: 30, width: 30),
              ),

              const SizedBox(width: 20),

              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name']!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text("برای باز کردن لمس کن", style: TextStyle(fontSize: 12, color: AppTheme.textDark.withOpacity(0.5))),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(Icons.arrow_forward_rounded, color: AppTheme.deepPink.withOpacity(0.8), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
