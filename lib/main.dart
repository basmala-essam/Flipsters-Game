 import 'package:flutter/material.dart';
 import 'package:firebase_core/firebase_core.dart';
 import 'Screens/splash_screen.dart';
 import 'Screens/home_screen.dart';
 import 'Screens/name_screen.dart';
 import 'Screens/level_screen.dart';
 import 'game_screen.dart';

void main() async {
  // Firebase needs this before runApp
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Myapp());
}


class Myapp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     debugShowCheckedModeBanner: false,
     home: SplashScreen(),
   );
  }
}
