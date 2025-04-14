import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qms/screens/navigation_wrapper.dart';
import 'package:qms/screens/menu_screen.dart';
import 'package:qms/screens/display_screen.dart';
import 'package:qms/screens/admin_panel.dart';
import 'package:qms/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(const QueueApp());
}

class QueueApp extends StatelessWidget {
  const QueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Queue Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: NavigationWrapper(),
    );
  }
}