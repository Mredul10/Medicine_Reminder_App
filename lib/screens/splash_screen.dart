import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medicine_reminder_app/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _ctl.forward();
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (a, b, c) => HomeScreen(), transitionsBuilder: (ctx, anim, sec, child) {
        return FadeTransition(opacity: anim, child: child);
      }));
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: GradientBackground(
      child: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _ctl, curve: Curves.elasticOut),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', width: 300,height: 200,),
              SizedBox(height: 12),
              Text('MediTech',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 12),
              Text('Stay Healthy, Stay Notified!',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ),
    ),
  );
}
}