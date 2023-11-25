import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805);
class AccountPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar:  AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15.0), // Adjust padding as needed
              child: Image.asset(
                'assets/ULyfelogo.png', // Your logo asset path
                height: 30, // Adjust the size as needed
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),

      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _signOut(context),
              child: Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
                // minimumSize: Size(double.infinity, 40),
              ),
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
