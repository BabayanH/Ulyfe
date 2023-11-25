import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unimatch/pages/account/account_page.dart';
import 'package:unimatch/pages/events/event_page.dart';
import 'package:unimatch/pages/main_page.dart';
import 'auth/auth_page.dart';
import 'pages/account/ThemeNotifier.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      theme: themeNotifier.lightTheme,
      darkTheme: themeNotifier.darkTheme,
      themeMode: themeNotifier.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthPage(),
        '/main': (context) => MainPage(),
        '/account': (context) => AccountPage(),
        EventsPage.routeName: (context) => EventsPage(),
        MainPage.routeName: (context) => MainPage(),

      },
    );
  }
}
