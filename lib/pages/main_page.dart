import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account/ThemeNotifier.dart';
import 'dating/dating_page.dart';
import 'forum/forum_page.dart';
import 'events/event_page.dart';
import 'account/account_page.dart';

const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805); // golden

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
  static const String routeName = '/mainpage';
  final int startingIndex;
  MainPage({this.startingIndex = 0}) {
    print('MainPage started with index: $startingIndex');
  }

}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startingIndex;
  }

  final List<Widget> _pages = [
    ForumPage(),
    DatingPage(),
    EventsPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // var themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor, // Background color for the bottom part
          border: Border(
            top: BorderSide(
              color: primaryColor, // Primary color for the divider
              width: 2.0, // Thickness of the divider
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: backgroundColor,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.forum),
              label: 'Forum',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Lynk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}