import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/views/splash_screen_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //โค้ดติดต่อกับ supabaseกับโปรเจคที่เราทำงานด้วย
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ksgcfxpaooakmvaicswa.supabase.co',
    publishableKey: 'sb_publishable_IXTDzr-3jz11b0AbL2FAzw_HEtQP9Bg',
  );//แก้แล้วเป็นของงานใหม่

  runApp(
    FlutterFoodTrackerApp(),
  );
}

class FlutterFoodTrackerApp extends StatefulWidget {
  const FlutterFoodTrackerApp({super.key});

  @override
  State<FlutterFoodTrackerApp> createState() => _FlutterFoodTrackerAppState();
}

class _FlutterFoodTrackerAppState extends State<FlutterFoodTrackerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenUi(),
      theme: ThemeData(//ใช้ kanit
        textTheme: TextTheme.of(context).apply(
          fontFamily: GoogleFonts.kanit().fontFamily,
          fontFamilyFallback: GoogleFonts.kanit().fontFamilyFallback,
        ),
      ),
    );
  }
}
