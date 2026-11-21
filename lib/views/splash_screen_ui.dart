import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/views/show_all_food_ui.dart';

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShowAllFoodTrackerUi(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF44336), 
      body: Stack(
        children: [
          // ชั้นที่ 1 แสดง Logo ชื่อแอป ไอคอนอาหาร และ ProgressIndicator
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: screenWidth * 0.45,
                  height: screenWidth * 0.45,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  'Food Tracker', 
                  style: TextStyle(
                    color: const Color(0xFFFFD54F),
                    fontSize: screenHeight * 0.036,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '🍔 🍟 🌭 🍿 🍨 🧁', // แถวไอคอนอาหารตามภาพ
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 36),
                const CircularProgressIndicator(
                  color: Color(0xFFFFD54F),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}