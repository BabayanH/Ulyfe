import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/main_page.dart';
import 'additional_info_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  void _handleAuthAttempt() async {
    if (!_email.endsWith('.edu')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please use a student email.')));
      return;
    }

    if (!_isLogin && _password != _confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Passwords do not match!')));
      return;
    }

    final FirebaseAuth _auth = FirebaseAuth.instance;
    UserCredential? userCredential;

    try {
      if (_isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Send email verification for new users
        User? user = _auth.currentUser;
        await user!.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent. Please check your email.'),
          ),
        );
      }

      if (_isLogin && userCredential.user != null) {
        final DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid);
        final DocumentSnapshot userDoc = await userRef.get();

        // Check if the user data exists and if the email is verified
        if (userDoc.exists && userCredential.user!.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        } else if (!userDoc.exists && userCredential.user!.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AdditionalInfoPage()), // Navigate to AdditionalInfoPage
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please verify your email to continue.')),
          );
        }
      } else if (!_isLogin) {
        // Redirect user to login page after signup for them to verify their email.
        Navigator.of(context).pushReplacementNamed('/');
      }
    } on FirebaseAuthException catch (e) {
      // Show error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
    } catch (e) {
      // Other exceptions can be handled here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(_isLogin ? 'Login' : 'Signup'),
        backgroundColor: Color(0xFF0557fa),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Student Email:',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password:',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              SizedBox(height: 10),
              if (!_isLogin)
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password:',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      _confirmPassword = value;
                    });
                  },
                ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _handleAuthAttempt,
                child: Text(_isLogin ? 'Login' : 'Signup'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0557fa),
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text('Switch to ${_isLogin ? 'Signup' : 'Login'}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
