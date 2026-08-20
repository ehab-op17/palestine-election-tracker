import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization.dart';
import 'screens/home_screen.dart';
import 'services/background_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Best-effort periodic background refresh. Android will throttle or skip
  // this under battery optimization / Doze — the app also always refreshes
  // on open and on pull-to-refresh, which is the reliable path.
  if (!kIsWeb && Platform.isAndroid) {
    try {
      await BackgroundService.init();
    } catch (_) {
      // Non-fatal if WorkManager setup fails on a given device/OS version.
    }
  }

  runApp(const ElectionTrackerApp());
}

class ElectionTrackerApp extends StatefulWidget {
  const ElectionTrackerApp({super.key});

  @override
  State<ElectionTrackerApp> createState() => _ElectionTrackerAppState();
}

class _ElectionTrackerAppState extends State<ElectionTrackerApp> {
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLC Election Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: _locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: HomeScreen(onToggleLanguage: _toggleLanguage),
    );
  }

  void _toggleLanguage() => setState(() {
        _locale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
      });
}
