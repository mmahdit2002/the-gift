import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:my_love/widgets/toast_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

import 'package:my_love/repositories/app_repository.dart';
import 'package:my_love/widgets/smart_asset_image.dart';
import 'prize_view_screen.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_state.dart';
import '../bloc/app_event.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/all_neccessery_widgets.dart';

class DayScreen extends StatelessWidget {
  final String dayId;

  // This ValueNotifier holds the quote once and never changes
  final ValueNotifier<String> _motivationNotifier = ValueNotifier(AppRepository.getMotivationForDay());

  DayScreen({required this.dayId, Key? key}) : super(key: key);

  String _toPersian(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], persian[i]);
    }
    return input;
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    String formatted = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    return _toPersian(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final day = state.days.firstWhere((d) => d.id == dayId);

        if (day.isAllTasksComplete && !day.isPrizeClaimed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPrizeDialog(context, day);
          });
        }

        int totalTasks = day.categories.expand((c) => c.tasks).length;
        int completedTasks = day.categories.expand((c) => c.tasks).where((t) => t.isCompleted).length;
        double progress = totalTasks == 0 ? 0 : completedTasks / totalTasks;

        bool isAnyTaskRunning = day.categories.expand((c) => c.tasks).any((t) => t.startTime != null && !t.isCompleted);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFFF0F5), Color(0xFFFFC1E3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                ),
                Positioned(
                  top: -100,
                  right: -50,
                  child: SpinPerfect(
                    duration: const Duration(seconds: 20),
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
                                  "اهداف امروز",
                                  style: TextStyle(fontSize: 14, color: AppTheme.textDark.withOpacity(0.6), fontWeight: FontWeight.w600, fontFamily: 'Vazir'),
                                ),
                                Text(
                                  _toPersian(day.jalaliDate),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.favorite, size: 52, color: Colors.white.withOpacity(0.6)),
                                ShaderMask(
                                  blendMode: BlendMode.srcATop,
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      stops: [progress, progress],
                                      colors: [AppTheme.deepPink, Colors.white.withOpacity(0.1)],
                                    ).createShader(bounds);
                                  },
                                  child: const Icon(Icons.favorite, size: 52, color: Colors.white),
                                ),
                                Text(
                                  "${_toPersian((progress * 100).toInt().toString())}٪",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
                        child: FadeInDown(
                          from: 20,
                          child: GlassContainer(
                            height: 100,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.format_quote, size: 20, color: AppTheme.deepPink),
                                    ValueListenableBuilder<String>(
                                      valueListenable: _motivationNotifier,
                                      builder: (context, quote, child) {
                                        return Text(
                                          quote,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: AppTheme.textDark, height: 1.5),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                            boxShadow: [BoxShadow(color: AppTheme.deepPink.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            child: ListView.separated(
                              clipBehavior: Clip.none,
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                              itemCount: day.categories.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 30),
                              itemBuilder: (context, index) {
                                final category = day.categories[index];
                                bool isLocked = index > 0 && !day.categories[index - 1].isComplete;

                                return FadeInUp(
                                  delay: Duration(milliseconds: index * 150),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: isLocked ? 0.6 : 1.0,
                                    child: IgnorePointer(ignoring: isLocked, child: _buildBeautifulCategoryCard(context, category, day.id, isLocked, isAnyTaskRunning)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeautifulCategoryCard(BuildContext context, TaskCategory category, String dayId, bool isLocked, bool isAnyTaskRunning) {
    const Color baseColor = Color(0xFFFFF0F5);
    final Color shadowColor = const Color(0xFF8B80A8).withOpacity(0.15);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.95), offset: const Offset(-6, -6), blurRadius: 12, spreadRadius: 0),
          BoxShadow(color: shadowColor, offset: const Offset(6, 6), blurRadius: 12, spreadRadius: -2),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: !category.isComplete && !isLocked,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: EdgeInsets.zero,
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: category.isComplete ? const LinearGradient(colors: [AppTheme.primaryPink, AppTheme.deepPink]) : null,
              color: category.isComplete ? null : baseColor,
              shape: BoxShape.circle,
              boxShadow: [
                if (category.isComplete)
                  BoxShadow(color: AppTheme.deepPink.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))
                else ...[
                  const BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-2, -2)),
                  BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(2, 2)),
                ],
              ],
            ),
            child: Icon(isLocked ? Icons.lock_outline : (category.isComplete ? Icons.check : Icons.star_outline_rounded), color: category.isComplete ? Colors.white : AppTheme.deepPink, size: 22),
          ),
          title: Text(
            category.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.textDark),
          ),
          subtitle: Text(
            isLocked ? "ابتدا مراحل قبلی را تکمیل کنید" : "${_toPersian(category.tasks.where((t) => t.isCompleted).length.toString())} از ${_toPersian(category.tasks.length.toString())} تکمیل شده",
            style: TextStyle(fontSize: 12, color: AppTheme.textDark.withOpacity(0.5)),
          ),
          children: [const SizedBox(height: 12), ...category.tasks.map((task) => _buildTaskItem(context, task, dayId, category.title, isAnyTaskRunning)).toList(), const SizedBox(height: 8)],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskItem task, String dayId, String catTitle, bool isAnyTaskRunning) {
    bool isTimerRunning = task.startTime != null && !task.isCompleted;
    const Color baseColor = Color(0xFFFFF0F5);
    final Color shadowColor = const Color(0xFF8B80A8).withOpacity(0.12);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          BoxShadow(color: shadowColor, offset: const Offset(4, 4), blurRadius: 8, spreadRadius: -1),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: task.link != null
              ? () async {
                  final uri = Uri.parse(task.link!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                    if (task.startTime == null && !task.isCompleted && !isAnyTaskRunning) {
                      context.read<AppBloc>().add(StartTask(dayId, catTitle, task.id));
                    }
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(task.link != null ? Icons.link : Icons.circle, size: task.link != null ? 20 : 8, color: task.link != null ? Colors.blueAccent : AppTheme.deepPink.withOpacity(0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? Colors.grey : AppTheme.textDark,
                        ),
                      ),
                      if (task.minSeconds > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "مدت زمان: ${_formatDuration(task.minSeconds)}",
                            style: TextStyle(fontSize: 12, color: isTimerRunning ? AppTheme.deepPink : Colors.grey[600], fontWeight: isTimerRunning ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (task.isCompleted) return;

                    // START LOGIC
                    if (task.startTime == null) {
                      if (isAnyTaskRunning) {
                        // REPLACE: ScaffoldMessenger with ToastManager
                        ToastManager().showToast(
                          context: context,
                          message: "عزیزم، اول کار فعلی رو تموم کن! نمی‌تونی چند تا کار رو با هم انجام بدی.",
                          icon: Icons.warning_amber_rounded,
                          backgroundColor: Colors.orangeAccent,
                        );
                        return;
                      }

                      context.read<AppBloc>().add(StartTask(dayId, catTitle, task.id));
                      // REPLACE: ScaffoldMessenger with ToastManager
                      ToastManager().showToast(
                        context: context,
                        message: "بزن بریم. ${_formatDuration(task.minSeconds)} دیگه میتونی کار بعدیت رو شروع کنی",
                        icon: Icons.timer,
                        backgroundColor: AppTheme.deepPink,
                      );
                    }
                    // COMPLETE LOGIC
                    else {
                      context.read<AppBloc>().add(CompleteTask(dayId, catTitle, task.id));
                      final duration = DateTime.now().difference(task.startTime!).inSeconds;
                      if (duration < task.minSeconds) {
                        // REPLACE: ScaffoldMessenger with ToastManager
                        ToastManager().showToast(
                          context: context,
                          message: "خیلی عجله داری! هنوز ${_toPersian(_formatDuration(task.minSeconds - duration).toString())} مونده. تقلب نکن!",
                          icon: Icons.error_outline_rounded,
                          backgroundColor: Colors.redAccent,
                        );
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? AppTheme.deepPink : baseColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: task.isCompleted
                          ? [BoxShadow(color: AppTheme.deepPink.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))]
                          : [const BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-3, -3)), BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(3, 3))],
                    ),
                    child: Center(
                      child: task.isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : (task.startTime == null ? const Icon(Icons.play_arrow_rounded, color: AppTheme.deepPink, size: 24) : null),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrizeDialog(BuildContext context, DayModel day) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ZoomIn(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(30)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [SmartAssetImage(assetPath: "assets/icons/color-gift.svg", height: 80, width: 80)],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "تبریک می‌گم!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 10),
                  Text("همه کارها با موفقیت انجام شد.", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepPink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                      ),
                      onPressed: () {
                        context.read<AppBloc>().add(UnlockPrize(day.id));
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PrizeViewScreen(day: day)));
                      },
                      child: const Text(
                        "باز کردن هدیه",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
