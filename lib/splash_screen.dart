import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/OnboardingScreen/onboarding_screen.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final preferences = await SharedPreferences.getInstance();
      final token = preferences.getString('auth_token');
      if (!mounted) return;

      final nextScreen = token != null && token.isNotEmpty
          ? const Dashboard()
          : const OnboardingScreen();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryMain,
      body: Stack(
        children: [
          Positioned(top: 90, right: 35, child: _circle(70)),
          Positioned(bottom: 180, left: 30, child: _circle(65)),
          Positioned(bottom: 80, right: -10, child: _circle(90)),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', height: 90),
                const SizedBox(height: 20),
                const Text(
                  'COURIER PVT. LIMITED',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.yellow,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 12),
      ),
    );
  }
}
