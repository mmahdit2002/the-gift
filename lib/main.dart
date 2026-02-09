import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'bloc/app_bloc.dart';
import 'bloc/app_event.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({Key? key, required this.isFirstTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc()..add(LoadAppData()),
      child: MaterialApp(
        title: 'For My Love',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // ────── FORCE PERSIAN + RTL ──────
        locale: const Locale('fa', 'IR'), // Persian (Iran)
        supportedLocales: const [
          Locale('fa', 'IR'), // Persian
          // Locale('en', 'US'), // you can add English later if needed
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate, // Material widgets (buttons, dialogs…)
          GlobalWidgetsLocalizations.delegate, // ← this one sets RTL for fa/ar/he
          GlobalCupertinoLocalizations.delegate,
        ],

        // ─────────────────────────────────
        home: isFirstTime ? const OnboardingScreen() : const HomeScreen(),
      ),
    );
  }
}
