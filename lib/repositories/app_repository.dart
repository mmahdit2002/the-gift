import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/models.dart';

class AppRepository {
  static const String _storageKey = "app_data_v2";
  static const String _startDateKey = "journey_start_date";

  // --- START DATE MANAGEMENT ---
  Future<DateTime?> loadStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dateStr = prefs.getString(_startDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  Future<void> saveStartDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startDateKey, date.toIso8601String());
  }

  // --- DAYS DATA MANAGEMENT ---
  Future<List<DayModel>> loadDays() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      try {
        List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((e) => DayModel.fromJson(e)).toList();
      } catch (e) {
        return _generateInitialData();
      }
    } else {
      final initialDays = _generateInitialData();
      await saveDays(initialDays);
      return initialDays;
    }
  }

  Future<void> saveDays(List<DayModel> days) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(days.map((d) => d.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // --- CONTENT GENERATION (Hardcoded 60 Days) ---
  List<DayModel> _generateInitialData() {
    Jalali startDate = Jalali.now();

    return List.generate(60, (index) {
      final config = _hardcodedJourneyData[index];
      Jalali date = startDate.addDays(index);

      // Parse the list of categories from the config
      List<TaskCategory> dayCategories = (config['categories'] as List).map((catData) {
        return TaskCategory(title: catData['title'] as String, tasks: catData['tasks'] as List<TaskItem>);
      }).toList();

      return DayModel(
        id: "day_$index",
        jalaliDate: "${date.year}/${date.month}/${date.day}",
        // Logic: First day is unlocked, others locked
        isDayUnlocked: index == 0,
        isExpired: false,
        prizeType: config['prizeType'] as PrizeType,
        prizeContent: config['prizeContent'] as String,
        categories: dayCategories,
      );
    });
  }

  // --- HARDCODED DATA DEFINITION ---
  // Structure Updated: 'title' and 'tasks' are now inside a 'categories' list.
  static final List<Map<String, dynamic>> _hardcodedJourneyData = [
    // --- WEEK 1: THE BEGINNING ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w0_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w0_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w0_d0_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w0_d0_t4", title: "اسکوات معمولی × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d0_t5", title: "لانج جلو × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w0_d0_t6", title: "اسکوات پالس × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d0_t7", title: "لانج کنار × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w0_d0_t8", title: "جامپینگ جک × 30 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w0_d0_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w0_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w0_d0_t11", title: "دیدن 20 قسمت از اولین دوره فیگما", minSeconds: 5400),
            TaskItem(id: "w0_d0_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w0_d0_t13", title: "دراوردن پیش نیاز های آزمون ارشد و شروع دوره دروس", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_01.jpg",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w0_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w0_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w0_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w0_d1_t4", title: "پوش‌آپ روی زانو × 10–12 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d1_t5", title: "دیپ پشت بازو با صندلی × 10 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d1_t6", title: "پلانک شانه (Shoulder Tap) × 20 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d1_t7", title: "سوپرمن × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d1_t8", title: "چرخش دست با بطری آب × 20 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d1_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w0_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w0_d1_t11", title: "تمام کردن اولین دوره فیگما", minSeconds: 5400),
            TaskItem(id: "w0_d1_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w0_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_02.mp4",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w0_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w0_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w0_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w0_d2_t4", title: "High Knees 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w0_d2_t5", title: "اسکوات + دست بالا 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w0_d2_t6", title: "مانتین کلایمبر 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w0_d2_t7", title: "کیک عقب 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w0_d2_t8", title: "Jumping Jack 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w0_d2_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w0_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w0_d2_t11", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w0_d2_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w0_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_03.jpg",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w0_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w0_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w0_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w0_d3_t4", title: "لانج عقب × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w0_d3_t5", title: "فایر هایدرنت × 15 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w0_d3_t6", title: "دانکی کیک × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d3_t7", title: "وال سیت × 40 ثانیه سه ست", minSeconds: 300),
            TaskItem(id: "w0_d3_t8", title: "لانج ضربدری × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d3_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w0_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w0_d3_t11", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w0_d3_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w0_d3_t13", title: "دراوردن پیش نیاز های آزمون ارشد و شروع دوره دروس", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_04.mp4",
    },
    //day 5
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w0_d4_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w0_d4_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w0_d4_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w0_d4_t4", title: "کرانچ × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d4_t5", title: "لگ ریز × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d4_t6", title: "پلانک × 30–45 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w0_d4_t7", title: "روسین توئیست × 20 سه ست", minSeconds: 300),
            TaskItem(id: "w0_d4_t8", title: "ددباگ × 12 هر سمت سه ست", minSeconds: 180),
            TaskItem(id: "w0_d4_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w0_d4_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w0_d4_t11", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w0_d4_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w0_d4_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_05.mp4",
    },
    //day 6
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w0_d5_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w0_d5_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w0_d5_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w0_d5_t4", title: "اسکوات + پرس دست × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d5_t5", title: "لانج + چرخش تنه × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d5_t6", title: "پلانک راه‌رو × 30 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w0_d5_t7", title: "استپ بک × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w0_d5_t8", title: "10 دقیقه کشش و نفس عمیق", minSeconds: 600),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w0_d5_t9", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w0_d5_t10", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w0_d5_t11", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w0_d5_t12", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_06.mp4",
    },
    //day 7
    {
      'categories': [
        {
          'title': "پایان هفته اول",
          'tasks': [TaskItem(id: "w0_d6_t1", title: "مرور موفقیت‌های هفته", minSeconds: 300), TaskItem(id: "w0_d6_t2", title: "تماس با یک دوست", minSeconds: 300)],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_07.jpg",
    },

    // --- WEEK 2: BUILDING HABITS ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w1_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w1_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w1_d0_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w1_d0_t4", title: "اسکوات معمولی × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d0_t5", title: "لانج جلو × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w1_d0_t6", title: "اسکوات پالس × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d0_t7", title: "لانج کنار × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w1_d0_t8", title: "جامپینگ جک × 30 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w1_d0_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w1_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w1_d0_t11", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w1_d0_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w1_d0_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_08.jpg",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w1_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w1_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w1_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w1_d1_t4", title: "پوش‌آپ روی زانو × 10–12 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d1_t5", title: "دیپ پشت بازو با صندلی × 10 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d1_t6", title: "پلانک شانه (Shoulder Tap) × 20 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d1_t7", title: "سوپرمن × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d1_t8", title: "چرخش دست با بطری آب × 20 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d1_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w1_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w1_d1_t11", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w1_d1_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w1_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_09.mp4",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w1_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w1_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w1_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w1_d2_t4", title: "High Knees 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w1_d2_t5", title: "اسکوات + دست بالا 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w1_d2_t6", title: "مانتین کلایمبر 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w1_d2_t7", title: "کیک عقب 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w1_d2_t8", title: "Jumping Jack 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w1_d2_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w1_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w1_d2_t11", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w1_d2_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w1_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_10.jpg",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w1_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w1_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w1_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w1_d3_t4", title: "لانج عقب × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w1_d3_t5", title: "فایر هایدرنت × 15 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w1_d3_t6", title: "دانکی کیک × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d3_t7", title: "وال سیت × 40 ثانیه سه ست", minSeconds: 300),
            TaskItem(id: "w1_d3_t8", title: "لانج ضربدری × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d3_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w1_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w1_d3_t11", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w1_d3_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w1_d3_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_11.mp4",
    },
    //day 5
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w1_d4_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w1_d4_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w1_d4_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w1_d4_t4", title: "کرانچ × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d4_t5", title: "لگ ریز × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d4_t6", title: "پلانک × 30–45 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w1_d4_t7", title: "روسین توئیست × 20 سه ست", minSeconds: 300),
            TaskItem(id: "w1_d4_t8", title: "ددباگ × 12 هر سمت سه ست", minSeconds: 180),
            TaskItem(id: "w1_d4_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w1_d4_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w1_d4_t11", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w1_d4_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w1_d4_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_12.jpg",
    },
    //day 6
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w1_d5_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w1_d5_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w1_d5_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w1_d5_t4", title: "اسکوات + پرس دست × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d5_t5", title: "لانج + چرخش تنه × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d5_t6", title: "پلانک راه‌رو × 30 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w1_d5_t7", title: "استپ بک × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w1_d5_t8", title: "10 دقیقه کشش و نفس عمیق", minSeconds: 600),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w1_d5_t9", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w1_d5_t10", title: "اتمام دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w1_d5_t11", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w1_d5_t12", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_13.jpg",
    },
    //day7
    {
      'categories': [
        {
          'title': "پایان هفته دوم",
          'tasks': [TaskItem(id: "w1_d6_t1", title: "مرور موفقیت‌های هفته", minSeconds: 300), TaskItem(id: "w1_d6_t2", title: "تماس با یک دوست", minSeconds: 300)],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_14.mp4",
    },

    // --- WEEK 3: MOMENTUM ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w2_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w2_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w2_d0_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w2_d0_t4", title: "اسکوات معمولی × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d0_t5", title: "لانج جلو × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w2_d0_t6", title: "اسکوات پالس × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d0_t7", title: "لانج کنار × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w2_d0_t8", title: "جامپینگ جک × 30 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w2_d0_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w2_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w2_d0_t11", title: "دیدن یک ساعت از سومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w2_d0_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w2_d0_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_15.jpg",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w2_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w2_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w2_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w2_d1_t4", title: "پوش‌آپ روی زانو × 10–12 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d1_t5", title: "دیپ پشت بازو با صندلی × 10 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d1_t6", title: "پلانک شانه (Shoulder Tap) × 20 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d1_t7", title: "سوپرمن × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d1_t8", title: "چرخش دست با بطری آب × 20 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d1_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w2_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w2_d1_t11", title: "دیدن یک ساعت از سومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w2_d1_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w2_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_16.jpg",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w2_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w2_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w2_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w2_d2_t4", title: "High Knees 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w2_d2_t5", title: "اسکوات + دست بالا 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w2_d2_t6", title: "مانتین کلایمبر 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w2_d2_t7", title: "کیک عقب 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w2_d2_t8", title: "Jumping Jack 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w2_d2_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w2_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w2_d2_t11", title: "دیدن یک ساعت از سومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w2_d2_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w2_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_17.mp4",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w2_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w2_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w2_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w2_d3_t4", title: "لانج عقب × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w2_d3_t5", title: "فایر هایدرنت × 15 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w2_d3_t6", title: "دانکی کیک × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d3_t7", title: "وال سیت × 40 ثانیه سه ست", minSeconds: 300),
            TaskItem(id: "w2_d3_t8", title: "لانج ضربدری × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d3_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w2_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w2_d3_t11", title: "دیدن یک ساعت از سومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w2_d3_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w2_d3_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_18.jpg",
    },
    //day 5
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w2_d4_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w2_d4_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w2_d4_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w2_d4_t4", title: "کرانچ × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d4_t5", title: "لگ ریز × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d4_t6", title: "پلانک × 30–45 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w2_d4_t7", title: "روسین توئیست × 20 سه ست", minSeconds: 300),
            TaskItem(id: "w2_d4_t8", title: "ددباگ × 12 هر سمت سه ست", minSeconds: 180),
            TaskItem(id: "w2_d4_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w2_d4_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w2_d4_t11", title: "دیدن یک ساعت از سومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w2_d4_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w2_d4_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_19.mp4",
    },
    //day 6
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w2_d5_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w2_d5_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w2_d5_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w2_d5_t4", title: "اسکوات + پرس دست × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d5_t5", title: "لانج + چرخش تنه × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d5_t6", title: "پلانک راه‌رو × 30 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w2_d5_t7", title: "استپ بک × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w2_d5_t8", title: "10 دقیقه کشش و نفس عمیق", minSeconds: 600),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w2_d5_t9", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w2_d5_t10", title: "دیدن یک ساعت از دومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w2_d5_t11", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w2_d5_t12", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_20.mp4",
    },
    //day 7
    {
      'categories': [
        {
          'title': "پایان هفته سوم",
          'tasks': [TaskItem(id: "w2_d6_t1", title: "مرور موفقیت‌های هفته", minSeconds: 300), TaskItem(id: "w2_d6_t2", title: "تماس با یک دوست", minSeconds: 300)],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_21.jpg",
    },

    // --- WEEK 4: CHALLENGE ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w3_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w3_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w3_d0_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w3_d0_t4", title: "اسکوات معمولی × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d0_t5", title: "لانج جلو × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w3_d0_t6", title: "اسکوات پالس × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d0_t7", title: "لانج کنار × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w3_d0_t8", title: "جامپینگ جک × 30 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w3_d0_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w3_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w3_d0_t11", title: "دیدن یک ساعت از سومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w3_d0_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w3_d0_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_22.mp4",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w3_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w3_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w3_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w3_d1_t4", title: "پوش‌آپ روی زانو × 10–12 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d1_t5", title: "دیپ پشت بازو با صندلی × 10 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d1_t6", title: "پلانک شانه (Shoulder Tap) × 20 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d1_t7", title: "سوپرمن × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d1_t8", title: "چرخش دست با بطری آب × 20 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d1_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w3_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w3_d1_t11", title: "دیدن یک ساعت از سومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w3_d1_t12", title: "دیدن دو ساعت از اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w3_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_23.jpg",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w3_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w3_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w3_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w3_d2_t4", title: "High Knees 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w3_d2_t5", title: "اسکوات + دست بالا 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w3_d2_t6", title: "مانتین کلایمبر 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w3_d2_t7", title: "کیک عقب 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w3_d2_t8", title: "Jumping Jack 30 ثانیه تمرین / 30 ثانیه استراحت – 3 دور", minSeconds: 180),
            TaskItem(id: "w3_d2_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w3_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w3_d2_t11", title: "دیدن یک ساعت از سومین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w3_d2_t12", title: "اتمام اولین دوره MBA", minSeconds: 7200),
            TaskItem(id: "w3_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_24.mp4",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w3_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w3_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w3_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w3_d3_t4", title: "لانج عقب × 12 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w3_d3_t5", title: "فایر هایدرنت × 15 هر پا سه ست", minSeconds: 180),
            TaskItem(id: "w3_d3_t6", title: "دانکی کیک × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d3_t7", title: "وال سیت × 40 ثانیه سه ست", minSeconds: 300),
            TaskItem(id: "w3_d3_t8", title: "لانج ضربدری × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d3_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w3_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w3_d3_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w3_d3_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w3_d3_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_25.mp4",
    },
    //day 5
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w3_d4_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w3_d4_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w3_d4_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w3_d4_t4", title: "کرانچ × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d4_t5", title: "لگ ریز × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d4_t6", title: "پلانک × 30–45 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w3_d4_t7", title: "روسین توئیست × 20 سه ست", minSeconds: 300),
            TaskItem(id: "w3_d4_t8", title: "ددباگ × 12 هر سمت سه ست", minSeconds: 180),
            TaskItem(id: "w3_d4_t9", title: "سرد کردن", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w3_d4_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w3_d4_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w3_d4_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w3_d4_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_26.jpg",
    },
    //day 6
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w3_d5_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w3_d5_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w3_d5_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w3_d5_t4", title: "اسکوات + پرس دست × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d5_t5", title: "لانج + چرخش تنه × 12 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d5_t6", title: "پلانک راه‌رو × 30 ثانیه سه ست", minSeconds: 180),
            TaskItem(id: "w3_d5_t7", title: "استپ بک × 15 سه ست", minSeconds: 180),
            TaskItem(id: "w3_d5_t8", title: "10 دقیقه کشش و نفس عمیق", minSeconds: 600),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w3_d5_t9", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w3_d5_t10", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w3_d5_t11", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w3_d5_t12", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_27.jpg",
    },
    //day 7
    {
      'categories': [
        {
          'title': "پایان هفته چهارم",
          'tasks': [TaskItem(id: "w3_d6_t1", title: "مرور موفقیت‌های هفته", minSeconds: 300), TaskItem(id: "w3_d6_t2", title: "تماس با یک دوست", minSeconds: 300)],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_28.mp4",
    },

    // --- WEEK 5: CONSISTENCY ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w4_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w4_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(
              id: "w5_d0_t3",
              title: "گرم‌کن (5–7 دقیقه): پیاده‌روی تند در جا 1 دقیقه، پرش سبک یا قدم کنار 1 دقیقه، داینامیک لانج با پیچش 1 دقیقه، دست‌ها دَوَران 30 ثانیه، اسکات با دامنه کامل 1 دقیقه.",
              minSeconds: 600,
            ),
            TaskItem(id: "w4_d0_t4", title: "اسکات (جلو) — 12–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d0_t5", title: "پوش-آپ (کامل یا از زانو/دیوار) — 8–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d0_t6", title: "لانج معکوس (هر پا) — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d0_t7", title: "دیپ صندلی — 10–12 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d0_t8", title: "پلِ گلوت (Hip Thrust) — 15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d0_t9", title: "سرد کردن (5 دقیقه): کشش چهارسر، همسترینگ، سینه، پشت ران.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w4_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w4_d0_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w4_d0_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w4_d0_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_29.jpg",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w4_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w4_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w4_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w4_d1_t4", title: "پرش جک یا مارش در جا — 40 ث. سه ست", minSeconds: 600),
            TaskItem(id: "w4_d1_t5", title: "کوهنورد (Mountain Climber) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d1_t6", title: "برپی (یا برپی بدون پرش برای ملایم‌تر) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d1_t7", title: "پلانک با ضربهٔ شانه (Plank Shoulder Tap) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d1_t8", title: "کرانچ دوچرخه‌ای (Bicycle Crunch) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d1_t9", title: "سرد کردن: سرشانه و کشش شکم/خم شدن رو به جلو.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w4_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w4_d1_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w4_d1_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w4_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_30.jpg",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w4_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w4_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w4_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w4_d2_t4", title: "Bulgarian Split Squat یا اسکات تک‌پا اصلاح‌شده — 8–10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d2_t5", title: "جهش اسکات (Squat Jump) یا اسکات اکسِنترِیک کنترل‌شده — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d2_t6", title: "پل یک‌پا (Single-leg Glute Bridge) — 10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d2_t7", title: "لانج جانبی (Lateral Lunge) — 10 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d2_t8", title: "کالف ریز ایستاده — 20 تکرار. – 3 دور", minSeconds: 180),
            TaskItem(id: "w4_d2_t9", title: "سرد کردن: کشش باسن، همسترینگ، ساق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w4_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w4_d2_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w4_d2_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w4_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_31.mp4",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w4_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w4_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w4_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w4_d3_t4", title: "پوش-آپ با دست‌های باز یا زاویه‌ای (درجه دشواری بر اساس موقعیت) — 8–15. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d3_t5", title: "روئینگ معکوس زیر میز (Inverted Row) یا سوپرمن اگر میز نیست — 8–12. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d3_t6", title: "دیپ صندلی (برای پشت بازو) — 10–12. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d3_t7", title: "پایک پوش-آپ یا پرس شانهٔ بدنی (Pike Push-up / Shoulder Tap Progression) — 8–12. سه ست", minSeconds: 300),
            TaskItem(id: "w4_d3_t8", title: "پلنک + کشش دست (Plank to Reach) یا پلانک آرنولدی برای ثبات‌ شانه — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d3_t9", title: "سرد کردن: کشش شانه، پشت و سینه.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w4_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w4_d3_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w4_d3_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w4_d3_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_32.jpg",
    },
    //day 5
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w4_d4_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w4_d4_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w4_d4_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w4_d4_t4", title: "های‌نیز (High Knees) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d4_t5", title: "اسکِیتِر (Skater Hops) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d4_t6", title: "پامپ اسکات (Pulse Squat) یا اسکات سرعتی — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d4_t7", title: "کوهنورد سریع — 40 ث. سه ست", minSeconds: 300),
            TaskItem(id: "w4_d4_t8", title: "درازنشست با چرخش (Sit-up to Twist) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d4_t9", title: "جاگینگ یا قدم‌زنی در جا برای بازیابی — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d4_t10", title: "سرد کردن: کشش ملایم و تنفس عمیق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w4_d4_t11", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w4_d4_t12", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w4_d4_t13", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w4_d4_t14", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_33.mp4",
    },
    //day 6
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w4_d5_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w4_d5_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w4_d5_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w4_d5_t4", title: "پلانک جانبی (هر طرف) — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d5_t5", title: "دِد-بگ (Dead Bug) — 12–15 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d5_t6", title: "Bird-Dog — 12 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d5_t7", title: "Glute Bridge March — 12 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d5_t8", title: "Side-lying Leg Raise (برای پهلوها) — 15 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w4_d5_t9", title: "سرد کردن: کشش پایین کمر، باسن و پهلو.", minSeconds: 600),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w4_d5_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w4_d5_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w4_d5_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w4_d5_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_34.mp4",
    },
    //day 7
    {
      'categories': [
        {
          'title': "پایان هفته پنجم",
          'tasks': [TaskItem(id: "w4_d6_t1", title: "مرور موفقیت‌های هفته", minSeconds: 300), TaskItem(id: "w4_d6_t2", title: "تماس با یک دوست", minSeconds: 300)],
        },
        {
          'title': "استراحت فعال",
          'tasks': [
            TaskItem(id: "w4_d6_t3", title: "30–45 دقیقه پیاده‌روی تند یا دویدن خیلی سبک یا دوچرخهٔ ثابت", minSeconds: 1800),
            TaskItem(id: "w4_d6_t4", title: "15–20 دقیقه موبیلیتی/یوگا سبک: تمرکز روی باز شدن قفسه، کشش همسترینگ، باز شدن لگن و تنفّس عمیق.", minSeconds: 1200),
          ],
        },
      ],
      'prizeType': PrizeType.voice,
      'prizeContent': "assets/prizes/prize_35.mp3",
    },

    // --- WEEK 6: DEEP WORK ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w5_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w5_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(
              id: "w5_d0_t3",
              title: "گرم‌کن (5–7 دقیقه): پیاده‌روی تند در جا 1 دقیقه، پرش سبک یا قدم کنار 1 دقیقه، داینامیک لانج با پیچش 1 دقیقه، دست‌ها دَوَران 30 ثانیه، اسکات با دامنه کامل 1 دقیقه.",
              minSeconds: 600,
            ),
            TaskItem(id: "w5_d0_t4", title: "اسکات (جلو) — 12–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d0_t5", title: "پوش-آپ (کامل یا از زانو/دیوار) — 8–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d0_t6", title: "لانج معکوس (هر پا) — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d0_t7", title: "دیپ صندلی — 10–12 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d0_t8", title: "پلِ گلوت (Hip Thrust) — 15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d0_t9", title: "سرد کردن (5 دقیقه): کشش چهارسر، همسترینگ، سینه، پشت ران.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w5_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w5_d0_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w5_d0_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w5_d0_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_36.mp4",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w5_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w5_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w5_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w5_d1_t4", title: "پرش جک یا مارش در جا — 40 ث. سه ست", minSeconds: 600),
            TaskItem(id: "w5_d1_t5", title: "کوهنورد (Mountain Climber) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d1_t6", title: "برپی (یا برپی بدون پرش برای ملایم‌تر) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d1_t7", title: "پلانک با ضربهٔ شانه (Plank Shoulder Tap) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d1_t8", title: "کرانچ دوچرخه‌ای (Bicycle Crunch) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d1_t9", title: "سرد کردن: سرشانه و کشش شکم/خم شدن رو به جلو.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w5_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w5_d1_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w5_d1_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w5_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_37.mp4",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w5_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w5_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w5_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w5_d2_t4", title: "Bulgarian Split Squat یا اسکات تک‌پا اصلاح‌شده — 8–10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d2_t5", title: "جهش اسکات (Squat Jump) یا اسکات اکسِنترِیک کنترل‌شده — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d2_t6", title: "پل یک‌پا (Single-leg Glute Bridge) — 10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d2_t7", title: "لانج جانبی (Lateral Lunge) — 10 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d2_t8", title: "کالف ریز ایستاده — 20 تکرار. – 3 دور", minSeconds: 180),
            TaskItem(id: "w5_d2_t9", title: "سرد کردن: کشش باسن، همسترینگ، ساق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w5_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w5_d2_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w5_d2_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w5_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_38.jpg",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w5_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w5_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w5_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w5_d3_t4", title: "پوش-آپ با دست‌های باز یا زاویه‌ای (درجه دشواری بر اساس موقعیت) — 8–15. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d3_t5", title: "روئینگ معکوس زیر میز (Inverted Row) یا سوپرمن اگر میز نیست — 8–12. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d3_t6", title: "دیپ صندلی (برای پشت بازو) — 10–12. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d3_t7", title: "پایک پوش-آپ یا پرس شانهٔ بدنی (Pike Push-up / Shoulder Tap Progression) — 8–12. سه ست", minSeconds: 300),
            TaskItem(id: "w5_d3_t8", title: "پلنک + کشش دست (Plank to Reach) یا پلانک آرنولدی برای ثبات‌ شانه — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d3_t9", title: "سرد کردن: کشش شانه، پشت و سینه.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w5_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w5_d3_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w5_d3_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w5_d3_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_39.jpg",
    },
    //day 5
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w5_d4_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w5_d4_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w5_d4_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w5_d4_t4", title: "های‌نیز (High Knees) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d4_t5", title: "اسکِیتِر (Skater Hops) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d4_t6", title: "پامپ اسکات (Pulse Squat) یا اسکات سرعتی — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d4_t7", title: "کوهنورد سریع — 40 ث. سه ست", minSeconds: 300),
            TaskItem(id: "w5_d4_t8", title: "درازنشست با چرخش (Sit-up to Twist) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d4_t9", title: "جاگینگ یا قدم‌زنی در جا برای بازیابی — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d4_t10", title: "سرد کردن: کشش ملایم و تنفس عمیق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w5_d4_t11", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w5_d4_t12", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w5_d4_t13", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w5_d4_t14", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_40.mp4",
    },
    //day 6
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w5_d5_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w5_d5_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w5_d5_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w5_d5_t4", title: "پلانک جانبی (هر طرف) — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d5_t5", title: "دِد-بگ (Dead Bug) — 12–15 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d5_t6", title: "Bird-Dog — 12 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d5_t7", title: "Glute Bridge March — 12 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d5_t8", title: "Side-lying Leg Raise (برای پهلوها) — 15 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w5_d5_t9", title: "سرد کردن: کشش پایین کمر، باسن و پهلو.", minSeconds: 600),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w5_d5_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w5_d5_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w5_d5_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w5_d5_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_41.jpg",
    },
    //day 7
    {
      'categories': [
        {
          'title': "پایان هفته ششم",
          'tasks': [TaskItem(id: "w5_d6_t1", title: "مرور موفقیت‌های هفته", minSeconds: 300), TaskItem(id: "w5_d6_t2", title: "تماس با یک دوست", minSeconds: 300)],
        },
        {
          'title': "استراحت فعال",
          'tasks': [
            TaskItem(id: "w5_d6_t3", title: "30–45 دقیقه پیاده‌روی تند یا دویدن خیلی سبک یا دوچرخهٔ ثابت", minSeconds: 1800),
            TaskItem(id: "w5_d6_t4", title: "15–20 دقیقه موبیلیتی/یوگا سبک: تمرکز روی باز شدن قفسه، کشش همسترینگ، باز شدن لگن و تنفّس عمیق.", minSeconds: 1200),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_42.mp4",
    },
    // --- WEEK 7: MASTERY ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w6_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w6_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(
              id: "w6_d0_t3",
              title: "گرم‌کن (5–7 دقیقه): پیاده‌روی تند در جا 1 دقیقه، پرش سبک یا قدم کنار 1 دقیقه، داینامیک لانج با پیچش 1 دقیقه، دست‌ها دَوَران 30 ثانیه، اسکات با دامنه کامل 1 دقیقه.",
              minSeconds: 600,
            ),
            TaskItem(id: "w6_d0_t4", title: "اسکات (جلو) — 12–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d0_t5", title: "پوش-آپ (کامل یا از زانو/دیوار) — 8–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d0_t6", title: "لانج معکوس (هر پا) — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d0_t7", title: "دیپ صندلی — 10–12 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d0_t8", title: "پلِ گلوت (Hip Thrust) — 15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d0_t9", title: "سرد کردن (5 دقیقه): کشش چهارسر، همسترینگ، سینه، پشت ران.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w6_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w6_d0_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w6_d0_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w6_d0_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_43.mp4",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w6_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w6_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w6_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w6_d1_t4", title: "پرش جک یا مارش در جا — 40 ث. سه ست", minSeconds: 600),
            TaskItem(id: "w6_d1_t5", title: "کوهنورد (Mountain Climber) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d1_t6", title: "برپی (یا برپی بدون پرش برای ملایم‌تر) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d1_t7", title: "پلانک با ضربهٔ شانه (Plank Shoulder Tap) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d1_t8", title: "کرانچ دوچرخه‌ای (Bicycle Crunch) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d1_t9", title: "سرد کردن: سرشانه و کشش شکم/خم شدن رو به جلو.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w6_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w6_d1_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w6_d1_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w6_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_44.jpg",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w6_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w6_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w6_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w6_d2_t4", title: "Bulgarian Split Squat یا اسکات تک‌پا اصلاح‌شده — 8–10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d2_t5", title: "جهش اسکات (Squat Jump) یا اسکات اکسِنترِیک کنترل‌شده — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d2_t6", title: "پل یک‌پا (Single-leg Glute Bridge) — 10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d2_t7", title: "لانج جانبی (Lateral Lunge) — 10 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d2_t8", title: "کالف ریز ایستاده — 20 تکرار. – 3 دور", minSeconds: 180),
            TaskItem(id: "w6_d2_t9", title: "سرد کردن: کشش باسن، همسترینگ، ساق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w6_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w6_d2_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w6_d2_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w6_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_45.jpg",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w6_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w6_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w6_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w6_d3_t4", title: "پوش-آپ با دست‌های باز یا زاویه‌ای (درجه دشواری بر اساس موقعیت) — 8–15. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d3_t5", title: "روئینگ معکوس زیر میز (Inverted Row) یا سوپرمن اگر میز نیست — 8–12. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d3_t6", title: "دیپ صندلی (برای پشت بازو) — 10–12. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d3_t7", title: "پایک پوش-آپ یا پرس شانهٔ بدنی (Pike Push-up / Shoulder Tap Progression) — 8–12. سه ست", minSeconds: 300),
            TaskItem(id: "w6_d3_t8", title: "پلنک + کشش دست (Plank to Reach) یا پلانک آرنولدی برای ثبات‌ شانه — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d3_t9", title: "سرد کردن: کشش شانه، پشت و سینه.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w6_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w6_d3_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w6_d3_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w6_d3_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_46.jpg",
    },
    //day 5
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w6_d4_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w6_d4_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w6_d4_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w6_d4_t4", title: "های‌نیز (High Knees) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d4_t5", title: "اسکِیتِر (Skater Hops) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d4_t6", title: "پامپ اسکات (Pulse Squat) یا اسکات سرعتی — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d4_t7", title: "کوهنورد سریع — 40 ث. سه ست", minSeconds: 300),
            TaskItem(id: "w6_d4_t8", title: "درازنشست با چرخش (Sit-up to Twist) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d4_t9", title: "جاگینگ یا قدم‌زنی در جا برای بازیابی — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d4_t10", title: "سرد کردن: کشش ملایم و تنفس عمیق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w6_d4_t11", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w6_d4_t12", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w6_d4_t13", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w6_d4_t14", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_47.mp4",
    },
    //day 6
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w6_d5_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w6_d5_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w6_d5_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w6_d5_t4", title: "پلانک جانبی (هر طرف) — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d5_t5", title: "دِد-بگ (Dead Bug) — 12–15 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d5_t6", title: "Bird-Dog — 12 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d5_t7", title: "Glute Bridge March — 12 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d5_t8", title: "Side-lying Leg Raise (برای پهلوها) — 15 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w6_d5_t9", title: "سرد کردن: کشش پایین کمر، باسن و پهلو.", minSeconds: 600),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w6_d5_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w6_d5_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w6_d5_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w6_d5_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_48.jpg",
    },
    //day 7
    {
      'categories': [
        {
          'title': "پایان هفته هفتم",
          'tasks': [TaskItem(id: "w6_d6_t1", title: "مرور موفقیت‌های هفته", minSeconds: 300), TaskItem(id: "w6_d6_t2", title: "تماس با یک دوست", minSeconds: 300)],
        },
        {
          'title': "استراحت فعال",
          'tasks': [
            TaskItem(id: "w6_d6_t3", title: "30–45 دقیقه پیاده‌روی تند یا دویدن خیلی سبک یا دوچرخهٔ ثابت", minSeconds: 1800),
            TaskItem(id: "w6_d6_t4", title: "15–20 دقیقه موبیلیتی/یوگا سبک: تمرکز روی باز شدن قفسه، کشش همسترینگ، باز شدن لگن و تنفّس عمیق.", minSeconds: 1200),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_49.mp4",
    },

    // --- WEEK 8: THE FINAL PUSH ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w7_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w7_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(
              id: "w7_d0_t3",
              title: "گرم‌کن (5–7 دقیقه): پیاده‌روی تند در جا 1 دقیقه، پرش سبک یا قدم کنار 1 دقیقه، داینامیک لانج با پیچش 1 دقیقه، دست‌ها دَوَران 30 ثانیه، اسکات با دامنه کامل 1 دقیقه.",
              minSeconds: 600,
            ),
            TaskItem(id: "w7_d0_t4", title: "اسکات (جلو) — 12–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d0_t5", title: "پوش-آپ (کامل یا از زانو/دیوار) — 8–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d0_t6", title: "لانج معکوس (هر پا) — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d0_t7", title: "دیپ صندلی — 10–12 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d0_t8", title: "پلِ گلوت (Hip Thrust) — 15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d0_t9", title: "سرد کردن (5 دقیقه): کشش چهارسر، همسترینگ، سینه، پشت ران.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w7_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w7_d0_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w7_d0_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w7_d0_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_50.mp4",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w7_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w7_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w7_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w7_d1_t4", title: "پرش جک یا مارش در جا — 40 ث. سه ست", minSeconds: 600),
            TaskItem(id: "w7_d1_t5", title: "کوهنورد (Mountain Climber) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d1_t6", title: "برپی (یا برپی بدون پرش برای ملایم‌تر) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d1_t7", title: "پلانک با ضربهٔ شانه (Plank Shoulder Tap) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d1_t8", title: "کرانچ دوچرخه‌ای (Bicycle Crunch) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d1_t9", title: "سرد کردن: سرشانه و کشش شکم/خم شدن رو به جلو.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w7_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w7_d1_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w7_d1_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w7_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_51.jpg",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w7_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w7_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w7_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w7_d2_t4", title: "Bulgarian Split Squat یا اسکات تک‌پا اصلاح‌شده — 8–10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d2_t5", title: "جهش اسکات (Squat Jump) یا اسکات اکسِنترِیک کنترل‌شده — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d2_t6", title: "پل یک‌پا (Single-leg Glute Bridge) — 10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d2_t7", title: "لانج جانبی (Lateral Lunge) — 10 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d2_t8", title: "کالف ریز ایستاده — 20 تکرار. – 3 دور", minSeconds: 180),
            TaskItem(id: "w7_d2_t9", title: "سرد کردن: کشش باسن، همسترینگ، ساق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w7_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w7_d2_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w7_d2_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w7_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_52.jpg",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w7_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w7_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w7_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w7_d3_t4", title: "پوش-آپ با دست‌های باز یا زاویه‌ای (درجه دشواری بر اساس موقعیت) — 8–15. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d3_t5", title: "روئینگ معکوس زیر میز (Inverted Row) یا سوپرمن اگر میز نیست — 8–12. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d3_t6", title: "دیپ صندلی (برای پشت بازو) — 10–12. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d3_t7", title: "پایک پوش-آپ یا پرس شانهٔ بدنی (Pike Push-up / Shoulder Tap Progression) — 8–12. سه ست", minSeconds: 300),
            TaskItem(id: "w7_d3_t8", title: "پلنک + کشش دست (Plank to Reach) یا پلانک آرنولدی برای ثبات‌ شانه — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d3_t9", title: "سرد کردن: کشش شانه، پشت و سینه.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w7_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w7_d3_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w7_d3_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w7_d3_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_53.mp4",
    },
    //day 5
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w7_d4_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w7_d4_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w7_d4_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w7_d4_t4", title: "های‌نیز (High Knees) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d4_t5", title: "اسکِیتِر (Skater Hops) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d4_t6", title: "پامپ اسکات (Pulse Squat) یا اسکات سرعتی — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d4_t7", title: "کوهنورد سریع — 40 ث. سه ست", minSeconds: 300),
            TaskItem(id: "w7_d4_t8", title: "درازنشست با چرخش (Sit-up to Twist) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d4_t9", title: "جاگینگ یا قدم‌زنی در جا برای بازیابی — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d4_t10", title: "سرد کردن: کشش ملایم و تنفس عمیق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w7_d4_t11", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w7_d4_t12", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w7_d4_t13", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w7_d4_t14", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_54.mp4",
    },
    //day 6
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w7_d5_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w7_d5_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w7_d5_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w7_d5_t4", title: "پلانک جانبی (هر طرف) — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d5_t5", title: "دِد-بگ (Dead Bug) — 12–15 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d5_t6", title: "Bird-Dog — 12 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d5_t7", title: "Glute Bridge March — 12 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d5_t8", title: "Side-lying Leg Raise (برای پهلوها) — 15 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w7_d5_t9", title: "سرد کردن: کشش پایین کمر، باسن و پهلو.", minSeconds: 600),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w7_d5_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w7_d5_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w7_d5_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w7_d5_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_55.jpg",
    },
    //day 7
    {
      'categories': [
        {
          'title': "پایان هفته هشتم",
          'tasks': [TaskItem(id: "w7_d6_t1", title: "مرور موفقیت‌های هفته", minSeconds: 300), TaskItem(id: "w7_d6_t2", title: "تماس با یک دوست", minSeconds: 300)],
        },
        {
          'title': "استراحت فعال",
          'tasks': [
            TaskItem(id: "w7_d6_t1", title: "30–45 دقیقه پیاده‌روی تند یا دویدن خیلی سبک یا دوچرخهٔ ثابت", minSeconds: 1800),
            TaskItem(id: "w7_d6_t2", title: "15–20 دقیقه موبیلیتی/یوگا سبک: تمرکز روی باز شدن قفسه، کشش همسترینگ، باز شدن لگن و تنفّس عمیق.", minSeconds: 1200),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_56.jpg",
    },

    // --- THE FINAL DAYS ---
    //day 1
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w8_d0_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w8_d0_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(
              id: "w8_d0_t3",
              title: "گرم‌کن (5–7 دقیقه): پیاده‌روی تند در جا 1 دقیقه، پرش سبک یا قدم کنار 1 دقیقه، داینامیک لانج با پیچش 1 دقیقه، دست‌ها دَوَران 30 ثانیه، اسکات با دامنه کامل 1 دقیقه.",
              minSeconds: 600,
            ),
            TaskItem(id: "w8_d0_t4", title: "اسکات (جلو) — 12–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d0_t5", title: "پوش-آپ (کامل یا از زانو/دیوار) — 8–15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d0_t6", title: "لانج معکوس (هر پا) — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d0_t7", title: "دیپ صندلی — 10–12 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d0_t8", title: "پلِ گلوت (Hip Thrust) — 15 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d0_t9", title: "سرد کردن (5 دقیقه): کشش چهارسر، همسترینگ، سینه، پشت ران.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w8_d0_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w8_d0_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w8_d0_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w8_d0_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_57.jpg",
    },
    //day 2
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w8_d1_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w8_d1_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w8_d1_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 600),
            TaskItem(id: "w8_d1_t4", title: "پرش جک یا مارش در جا — 40 ث. سه ست", minSeconds: 600),
            TaskItem(id: "w8_d1_t5", title: "کوهنورد (Mountain Climber) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d1_t6", title: "برپی (یا برپی بدون پرش برای ملایم‌تر) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d1_t7", title: "پلانک با ضربهٔ شانه (Plank Shoulder Tap) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d1_t8", title: "کرانچ دوچرخه‌ای (Bicycle Crunch) — 40 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d1_t9", title: "سرد کردن: سرشانه و کشش شکم/خم شدن رو به جلو.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w8_d1_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w8_d1_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w8_d1_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w8_d1_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_58.mp4",
    },
    //day 3
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w8_d2_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w8_d2_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w8_d2_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w8_d2_t4", title: "Bulgarian Split Squat یا اسکات تک‌پا اصلاح‌شده — 8–10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d2_t5", title: "جهش اسکات (Squat Jump) یا اسکات اکسِنترِیک کنترل‌شده — 10 تکرار. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d2_t6", title: "پل یک‌پا (Single-leg Glute Bridge) — 10 هر پا. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d2_t7", title: "لانج جانبی (Lateral Lunge) — 10 هر طرف. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d2_t8", title: "کالف ریز ایستاده — 20 تکرار. – 3 دور", minSeconds: 180),
            TaskItem(id: "w8_d2_t9", title: "سرد کردن: کشش باسن، همسترینگ، ساق.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w8_d2_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w8_d2_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w8_d2_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w8_d2_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.video,
      'prizeContent': "assets/prizes/prize_59.mp4",
    },
    //day 4
    {
      'categories': [
        {
          'title': "کارهای اول صبح",
          'tasks': [TaskItem(id: "w8_d3_t1", title: "شستن دست و صورت", minSeconds: 300), TaskItem(id: "w8_d3_t2", title: "انجام روتین صبحانه پوستی", minSeconds: 480)],
        },
        {
          'title': "ورزش و تحرک",
          'tasks': [
            TaskItem(id: "w8_d3_t3", title: "گرم‌کردن(راه رفتن درجا + چرخش مفاصل + اسکوات سبک)", minSeconds: 300),
            TaskItem(id: "w8_d3_t4", title: "پوش-آپ با دست‌های باز یا زاویه‌ای (درجه دشواری بر اساس موقعیت) — 8–15. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d3_t5", title: "روئینگ معکوس زیر میز (Inverted Row) یا سوپرمن اگر میز نیست — 8–12. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d3_t6", title: "دیپ صندلی (برای پشت بازو) — 10–12. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d3_t7", title: "پایک پوش-آپ یا پرس شانهٔ بدنی (Pike Push-up / Shoulder Tap Progression) — 8–12. سه ست", minSeconds: 300),
            TaskItem(id: "w8_d3_t8", title: "پلنک + کشش دست (Plank to Reach) یا پلانک آرنولدی برای ثبات‌ شانه — 30–45 ث. سه ست", minSeconds: 180),
            TaskItem(id: "w8_d3_t9", title: "سرد کردن: کشش شانه، پشت و سینه.", minSeconds: 300),
          ],
        },
        {
          'title': "مهارت های فردی",
          'tasks': [
            TaskItem(id: "w8_d3_t10", title: "انجام تمرین های بازیگری", minSeconds: 1800),
            TaskItem(id: "w8_d3_t11", title: "دیدن یک ساعت از چهارمین دوره فیگما", minSeconds: 3600),
            TaskItem(id: "w8_d3_t12", title: "دیدن سه ساعت از دومین دوره MBA", minSeconds: 10800),
            TaskItem(id: "w8_d3_t13", title: "مطالعه دروس دانشگاه", minSeconds: 1800),
          ],
        },
      ],
      'prizeType': PrizeType.letter,
      'prizeContent': "assets/prizes/prize_60.jpg",
    },
  ];

  static String getMotivationForDay() {
    const List<String> messages = [
      "بهت ایمان دارم، بیشتر از چیزی که کلمات بتونن بگن.",
      "هر قدمی که برمیداری، ما رو به رویاهامون نزدیک‌تر میکنه.",
      "تو قشنگ‌ترین پروژه زندگی منی، هیچوقت تسلیم نشو.",
      "عشق من، ادامه بده. من شاهد پیشرفتت هستم.",
      "قدرت تو توی اراده‌ته، و اراده‌ت توی قلب من.",
      "هیچ مانعی نمیتونه جلوی درخشش تو رو بگیره عزیزم.",
      "امروز هم مثل همیشه فوق‌العاده باش، چون تو لایقشی.",
      "من کنارتم، حتی توی سخت‌ترین لحظات مسیر.",
      "تلاش امروزت، لبخند فردای ماست.",
      "تو قهرمان دنیای کوچیک ما دو نفری.",
      "خستگی‌هات رو به جون میخرم، فقط تو جا نزن.",
      "تو قوی‌تر از اون چیزی هستی که فکرشو میکنی.",
      "دنیا به آدمای با پشتکاری مثل تو نیاز داره.",
      "بذار موفقیتت سر و صدا کنه، نه حرفات. من بهت باور دارم.",
      "هر روز که تلاش میکنی، من بیشتر عاشقت میشم.",
      "تو فقط یک بار زندگی میکنی، پس شاهکار بساز نفسم.",
      "رویاهات تاریخ انقضا ندارن، نفس عمیق بکش و دوباره شروع کن.",
      "مهم نیست چقدر آهسته میری، مهم اینه که متوقف نمیشی.",
      "پشت هر زن موفق، کوهی از تلاش و عشقی بی‌پایانه.",
      "تو الماس منی، و الماس فقط زیر فشار ساخته میشه.",
      "امروز قراره بترکونی، مطمئنم.",
      "به خودت افتخار کن، چون من خیلی بهت افتخار میکنم.",
      "مسیر سخته، ولی منظره‌ی قله بی‌نظیره. ادامه بده.",
      "تو معجزه زندگی منی، پس کارهای معجزه‌آسا کن.",
      "با هر زمین خوردن، قوی‌تر بلند شو عشق جان.",
      "اجازه نده ترس‌ها، رویاهاتو ازت بگیرن.",
      "تو توانایی تغییر دنیای خودت رو داری.",
      "تمرکزت رو بذار روی هدف، بقیه چیزا حاشیه است.",
      "خورشید فقط واسه این طلوع کرده که تلاش تو رو ببینه.",
      "من و تو با هم از پس همه چی برمیایم.",
      "آرامش یعنی دیدن موفقیت تو.",
      "دستان تو برای خلق زیبایی‌ها ساخته شدن.",
      "قلب من با ریتم تلاش‌های تو میتپه.",
      "موفقیت به تو میاد، درست مثل لبخندت.",
      "تو دلیل انگیزه من برای زندگی هستی.",
      "هر کدی که میزنی، یه قدم به آینده‌مون نزدیک‌تری.",
      "عشق یعنی حمایت کردن از رویاهای همدیگه.",
      "توی چشمای تو، من آینده‌ای روشن می‌بینم.",
      "وقتی تو موفقی، انگار دنیا مال منه.",
      "خستگیت رو در میکنم، فقط تو با قدرت ادامه بده.",
      "امروز یه فرصت جدیده، هدرش نده عزیزم.",
      "نظم و دیسیپلین تو، جذاب‌ترین ویژگی توئه.",
      "کار امروز رو به فردا ننداز، تو بهترینی.",
      "یادت باشه چرا شروع کردی.",
      "سخت کار کن، اما یادت نره لبخند بزنی.",
      "برنده شدن تو خون توئه.",
      "هیچکس نمیتونه جای تو رو بگیره، تو منحصر به فردی.",
      "استعدادت خدادادیه، اما تلاش‌ت قابل ستایشه.",
      "به صدای قلبت گوش کن، اون راه درست رو میدونه.",
      "تو لایق رسیدن به اوج هستی.",
      "شک و تردید رو بریز دور، تو از پسش برمیای.",
      "وقتی فکر میکنی نمیتونی، دقیقا همون لحظه معجزه میشه.",
      "محدودیت فقط توی ذهنته، تو نامحدودی.",
      "آسمون سقف آرزوهای تو نیست، بالاتر برو.",
      "من همیشه هواتو دارم، نترس و بپر.",
      "اشتباهات فقط درس‌هایی برای موفقیتن.",
      "تو خودِ خودِ انگیزه‌ای.",
      "نگاهت رو به هدف بدوز، نه به موانع.",
      "یه روزی بابت تلاش‌های امروزت از خودت تشکر میکنی.",
      "تو ستاره‌ی زندگی منی، همیشه بدرخش.",
      "باگ‌ها رو یکی یکی حل کن، مثل مشکلات زندگی.",
      "کد زندگیت رو بدون خطا بنویس عشق من.",
      "تو بهترین معماری هستی که برای آینده‌مون میشناسم.",
      "کیبوردت سلاح توئه، باهاش دنیا رو فتح کن.",
      "پیچیدگی‌ها رو ساده کن، تو استادی.",
      "هر خط کدی که مینویسی ارزشمنده.",
      "تو الگوریتم قلب منو هک کردی.",
      "پرفورمنس تو همیشه عالیه.",
      "دوست داشتن تو یعنی حمایت از پرواز تو.",
      "بال‌هاتو باز کن و پرواز کن، من زمینت میشم.",
      "تو فقط یک رویا نیستی، تو واقعیتی که محقق میشه.",
      "زندگی با تلاش‌های تو رنگ میگیره.",
      "توی دیکشنری من، جلوی واژه موفقیت اسم تو رو نوشتن.",
      "قدر لحظه‌ها رو بدون، زمان طلای توست.",
      "من به هوش و درایتت اعتماد کامل دارم.",
      "تو زیباترین اتفاق ممکن برای این جهانی.",
      "بذار دنیا صدای پای موفقیتت رو بشنوه.",
      "حتی اگر همه دنیا بگن نمیشه، من میگم تو میتونی.",
      "فقط انجامش بده!",
      "تو بی‌نظیری.",
      "ناامیدی ممنوع!",
      "رویاهاتو بساز.",
      "قوی بمون عشقم.",
      "تو برنده‌ای.",
      "ادامه بده...",
      "خواستن توانستنه.",
      "تو شاهکاری.",
      "آینده مال توئه.",
      "هیچوقت برای تبدیل شدن به اون چیزی که میخوای دیر نیست.",
      "سرنوشتت توی دستای خودته، قشنگ بنویسش.",
      "من عاشق دیدن پیشرفت توام.",
      "تو منبع الهام منی.",
      "کارایی که امروز میکنی، آینده‌ت رو تضمین میکنه.",
      "به خودت ایمان داشته باش، همونطور که من دارم.",
      "تو لایق بهترین ورژن از زندگی هستی.",
      "مسیرت روشنه، فقط قدم بردار.",
      "با عشق همه چی ممکنه، حتی غیرممکن‌ها.",
      "دوستت دارم، و این بزرگترین انگیزه است.",
    ];
    return messages[Random().nextInt(messages.length)];
  }
}
