import 'package:flutter/material.dart';

import 'pages/main_page.dart';
import 'pages/account/account_page.dart';
import 'auth/auth_page.dart';


import 'package:firebase_core/firebase_core.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthPage(),
        '/main': (context) => MainPage(),
        '/account': (context) => AccountPage(),  // Ensure you have imported AccountPage
      },
    );
  }
}

