
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homehub/pages/LoginAndSignUp/screens/login_screen.dart';
import 'package:homehub/pages/HomeScreen/home_page.dart';
import 'firebasecontrol/firebase_options.dart';
import 'package:homehub/services/notification_service.dart'; // create this service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Push Notifications
  await NotificationService.initialize();

  // Check if the user is already authenticated
  User? user = await FirebaseAuth.instance.authStateChanges().first;

  runApp(MyApp(isLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final bool isLoggedIn;

  MyApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? HomePage() : LoginScreen(),
    );
  }
}