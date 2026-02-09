import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:my_love/widgets/smart_asset_image.dart';
import 'dart:ui'; // For ImageFilter
import '../bloc/app_bloc.dart';
import '../bloc/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/all_neccessery_widgets.dart';
import 'prize_view_screen.dart'; // To open the prize again

class PrizeArchiveScreen extends StatelessWidget {
  const PrizeArchiveScreen({super.key});

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
            top: -60,
            right: -60,
            child: SpinPerfect(
              duration: const Duration(seconds: 30),
              infinite: true,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.15), blurRadius: 60, spreadRadius: 10)],
                ),
              ),
            ),
          ),

          // 3. Animated Blob (Bottom Left)
          Positioned(
            bottom: 50,
            left: -40,
            child: FadeInUp(
              duration: const Duration(seconds: 3),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
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
                            "صندوقچه گنج",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          Text("مجموعه خاطره‌هات", style: TextStyle(fontSize: 14, color: AppTheme.textDark.withOpacity(0.6))),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- CONTENT AREA ---
                Expanded(
                  child: BlocBuilder<AppBloc, AppState>(
                    builder: (context, state) {
                      final claimedDays = state.days.where((d) => d.isPrizeClaimed).toList();

                      // EMPTY STATE
                      if (claimedDays.isEmpty) {
                        return Center(
                          child: FadeInUp(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_clock, size: 80, color: AppTheme.deepPink.withOpacity(0.3)),
                                const SizedBox(height: 20),
                                Text(
                                  "هنوز هیچ گنجی پیدا نشده…",
                                  style: TextStyle(fontSize: 18, color: AppTheme.textDark.withOpacity(0.6), fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Text("هدفت رو هر روز کامل کن تا هدیه‌ها برات باز بشن!", style: TextStyle(fontSize: 14, color: AppTheme.textDark.withOpacity(0.4))),
                              ],
                            ),
                          ),
                        );
                      }

                      // GRID WITH GLASS CONTAINER
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0), // Bottom margin handled by grid padding
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                              ),
                              child: GridView.builder(
                                clipBehavior: Clip.none,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 25,
                                  childAspectRatio: 0.85, // Taller cards
                                ),
                                itemCount: claimedDays.length,
                                itemBuilder: (context, index) {
                                  return _buildPrizeCard(context, claimedDays[index], index);
                                },
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildPrizeCard(BuildContext context, DayModel day, int index) {
    final Color topShadow = Colors.white;
    final Color bottomShadow = AppTheme.deepPink.withOpacity(0.15);

    return FadeInUp(
      delay: Duration(milliseconds: index * 100),
      child: NeuButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PrizeViewScreen(day: day)));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              height: 70,
              width: 70,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.backgroundPink,
                boxShadow: [
                  BoxShadow(color: bottomShadow, blurRadius: 8, offset: const Offset(4, 4)),
                  BoxShadow(color: topShadow, blurRadius: 8, offset: const Offset(-4, -4)),
                ],
              ),
              child: SmartAssetImage(assetPath: "assets/icons/gift.svg", height: 20, width: 20, svgColor: AppTheme.deepPink),
            ),

            const SizedBox(height: 14),

            Text(
              day.jalaliDate,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
            ),

            const SizedBox(height: 4),

            Text("باز کردن", style: TextStyle(fontSize: 12, color: AppTheme.textDark.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}
