import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:my_love/widgets/smart_asset_image.dart';
import 'dart:math'; // ← اضافه شد
import 'menu_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/all_neccessery_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  // ────── ۵۰ پیام فارسی انگیزشی ──────
  final List<String> _morningMessages = const [
    "صبح بخیر زیباترین، امروز قراره فوق‌العاده باشی.",
    "پاشو که دنیا منتظر لبخند توئه عشقم.",
    "یه روز جدید، یه فرصت جدید برای درخشیدن تو.",
    "چشمات رو باز کن و به خورشید سلام کن، تو نور زندگی منی.",
    "امروز هم مثل همیشه قوی و پرانرژی شروع کن.",
    "امیدوارم امروزت پر از اتفاقات قشنگ باشه، درست مثل خودت.",
    "بریم که امروز رو بترکونیم! تو از پسش برمیای.",
    "صبح بخیر ملکه من، امروز همه چی به نفع توئه.",
    "یادت نره چقدر باهوش و توانمندی عزیز دلم.",
    "انرژی مثبت امروز تقدیم به تو، دلیل نفس کشیدنم.",
    "هر روز صبح که بیدار میشی، یه معجزه‌ای برای من.",
    "امروز رو با عشق و امید شروع کن نفسم.",
    "تو لایق بهترین‌هایی، پس برو بدستشون بیار.",
    "سلام به روی ماهت، صبحت پر از برکت و شادی.",
    "امروز قراره یه قدم به رویاهات نزدیک‌تر بشی.",
    "پاشو و نشون بده رئیس کیه! صبحت بخیر قهرمان.",
    "صبح شده و وقتشه که دوباره دنیا رو قشنگ‌تر کنی.",
    "تو قوی‌ترین دختری هستی که می‌شناسم، صبحت بخیر.",
    "بیدار شو عزیزم، موفقیت منتظرته.",
    "امروزت رو با یه لبخند خوشگل شروع کن که دلم ضعف میره.",
    "یه فنجون قهوه و کلی انرژی مثبت برای تو عشق جان.",
    "خورشید فقط به خاطر دیدن چشمای تو طلوع کرده.",
    "هیچ مانعی نمی‌تونه جلوی تو رو بگیره، صبحت بخیر.",
    "امروز رو بساز، همونطور که دوست داری. منم پشتتم.",
    "دوستت دارم، صبح قشنگت بخیر زندگی من.",
  ];

  final List<String> _dayMessages = const [
    "خسته نباشی عشق من، عالی بودی امروز.",
    "ادامه بده، تو داری فوق‌العاده پیش میری.",
    "بهت افتخار می‌کنم، همین فرمون برو جلو.",
    "می‌دونم خسته‌ای، ولی نتیجه‌اش ارزشش رو داره عزیز دلم.",
    "تو قهرمان زندگی خودتی و زندگی من، کم نیار.",
    "یه استراحت کوتاه کن و دوباره پرقدرت شروع کن.",
    "شب نزدیکه، ولی هنوز وقت داری که بترکونی.",
    "زیبایی تو حتی وقتی خسته‌ای هم خیره‌کننده‌ست.",
    "دمت گرم که اینقدر پرتلاشی دختر قوی.",
    "همه خستگیات فدای یه تار موت، ادامه بده عشقم.",
    "موفقیت یعنی همین تلاش‌های کوچیک تو که کوه رو جابجا میکنه.",
    "تو الگوی منی، جا نزن و قوی بمون.",
    "خورشید داره غروب می‌کنه ولی نور تو هنوز می‌تابه.",
    "یه نفس عمیق بکش و به مسیرت ادامه بده، من کنارتم.",
    "هیچکس مثل تو نمیتونه اینقدر قوی و با اراده باشه.",
    "دارم می‌بینم که چقدر داری زحمت می‌کشی، آفرین به تو.",
    "تو از دیروزت بهتری، شک نکن.",
    "مسیر موفقیت سخته ولی تو از اون سخت‌تری.",
    "خسته نباشی دلاور، خدا قوت عشق زندگیم.",
    "فقط یه کم دیگه مونده، تمومه. طاقت بیار.",
    "انرژی من همیشه همراهته، نگران هیچی نباش.",
    "تو داری آینده‌مون رو می‌سازی، ممنونم ازت.",
    "حتی اگه آروم پیش میری، مهم اینه که متوقف نشدی.",
    "ماه من، خستگی رو بیخیال شو و بخند.",
    "دوستت دارم، تو بهترینی و لایق بهترین‌ها.",
  ];

  late String currentMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    // انتخاب تصادفی پیام بر اساس ساعت
    final bool isMorning = DateTime.now().hour < 12;
    final random = Random();
    currentMessage = isMorning ? _morningMessages[random.nextInt(_morningMessages.length)] : _dayMessages[random.nextInt(_dayMessages.length)];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = const Color(0xFFFFF0F5);

    return Scaffold(
      backgroundColor: baseColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 150),

              // قلب پالسینگ (همون قبلی)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.05),
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: _neumorphicDecoration(color: baseColor, radius: 200, isConcave: true),
                      child: Center(
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: _neumorphicDecoration(color: baseColor, radius: 100, blur: 10),
                          child: Center(
                            child: SmartAssetImage(assetPath: "assets/icons/heart.svg", height: 80, width: 80, svgColor: AppTheme.deepPink.withOpacity(0.8 + (_pulseController.value * 0.2))),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),

              // پیام انگیزشی (حالا تصادفی و فارسی)
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  decoration: _neumorphicDecoration(color: baseColor, radius: 20, isInverse: true),
                  child: Text(
                    currentMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: AppTheme.textDark.withOpacity(0.8), height: 1.5),
                  ),
                ),
              ),

              const Spacer(),

              // دکمه شروع
              NeuButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateTime.now().hour < 12 ? "بریم که شروع کنیم" : "ادامه بده عزیزم",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepPink, letterSpacing: 2),
                      ),
                      const SizedBox(width: 15),
                      const Icon(Icons.arrow_forward_rounded, color: AppTheme.deepPink),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // تابع neumorphic (همون قبلی)
  BoxDecoration _neumorphicDecoration({required Color color, double radius = 20, double blur = 15, bool isInverse = false, bool isConcave = false}) {
    final Color topShadow = Colors.white;
    final Color bottomShadow = AppTheme.deepPink.withOpacity(0.15);
    final Color darkShade = const Color(0xFFF0E0E6);

    if (isInverse) {
      return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkShade, Colors.white]),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      );
    } else {
      return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        gradient: isConcave ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkShade, Colors.white]) : null,
        boxShadow: [
          BoxShadow(color: bottomShadow, offset: const Offset(8, 8), blurRadius: blur),
          BoxShadow(color: topShadow, offset: const Offset(-8, -8), blurRadius: blur),
        ],
      );
    }
  }
}
