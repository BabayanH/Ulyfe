import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/main_page.dart';
import 'additional_info_page.dart';
import 'dart:ui';


const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805); // golden

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
          .showSnackBar(SnackBar(content: Text("Please check your Email or Password")));
    } catch (e) {
      // Other exceptions can be handled here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Set scaffold background to black
      appBar: AppBar(
        backgroundColor: backgroundColor, // Change AppBar color to white
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: whiteColor, // Change container color to white
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            padding: EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(

                    labelText: 'Student Email:',
                    labelStyle: TextStyle(color: primaryColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: inputBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: inputBorderColor),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: backgroundColor),
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
                    labelStyle: TextStyle(color: primaryColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: inputBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: inputBorderColor),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: backgroundColor),
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
                      labelStyle: TextStyle(color: primaryColor),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(color: backgroundColor),
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
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    foregroundColor: MaterialStateProperty.all(whiteColor),

                    overlayColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.black12;
                      }
                      return null;
                    }),
                    side: MaterialStateProperty.all(BorderSide.none),
                    elevation: MaterialStateProperty.all(0),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ).withGradientBackground(
                  LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFfaa805),
                      Color(0xFFd47f00),
                    ],
                  ),
                ),



                // Adjust the "Switch to Signup/Login" button to be a TextButton
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text('Switch to ${_isLogin ? 'Signup' : 'Login'}',
                      style: TextStyle(color: primaryColor), ), // change text color to golden
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
extension GradientBackground on Widget {
  Widget withGradientBackground(LinearGradient gradient) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5), // Ensure that the gradient has rounded corners
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: this,
      ),
    );
  }
}
