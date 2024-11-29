import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photos/service/imageservice.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNewUser = prefs.getBool('isNewUser') ?? true;

    if (isNewUser) {
      context.go('/indexing');
    } else {
      List<String> savedDirectories = prefs.getStringList('selectedDirectories') ?? [];
      int previousMediaCount = prefs.getInt('mediaCount') ?? 0;
      int currentMediaCount = await ImageService.getMediaCountFromDirectories(savedDirectories);
      print(previousMediaCount);
      if (currentMediaCount > previousMediaCount) {
        prefs.setInt('mediaCount', currentMediaCount);
        print(previousMediaCount);
        context.go('/indexing');
      } else {
        context.go('/indexing');
        //context.go('/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("data") //Image.asset("assets/twoo.png", height: 70, width: 70),
        ),
      ),
    );
  }
}