import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatelessWidget {

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to another page if necessary
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      // Handle sign out error if necessary
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signOut(context),
          child: Text('Sign Out'),
        ),
      ),
    );
  }
}
