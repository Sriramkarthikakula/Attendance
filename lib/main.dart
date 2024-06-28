
import 'package:attendance/screens/admin_home_Screen.dart';
import 'package:attendance/screens/faculty_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance/screens/loginpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Data/lists_data.dart';


void main() async {

  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCeMmJDX1d2rM7lqvZTpraRI4CI1y4PY4k',
      appId: '1:91348246199:android:882747af209aacc67e7732',
      messagingSenderId: '91348246199',
      projectId: 'attendance-e35d5',
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? role = prefs.getString('role') ?? " ";
  displayimageURL = prefs.getString('display_image') ?? "";
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp(isLoggedIn: isLoggedIn, role: role));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;
  MyApp({Key? key, required this.isLoggedIn,this.role}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget home;
    if (isLoggedIn) {
      if (role == 'admin') {
        home = AdminPage();
      } else {
        home = Faculty_main();
      }
    } else {
      home = LoginPage();
    }
    return MaterialApp(
      home: home,
    );
  }
}