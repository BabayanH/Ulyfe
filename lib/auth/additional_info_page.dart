import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/main_page.dart';

class AdditionalInfoPage extends StatefulWidget {
  @override
  _AdditionalInfoPageState createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  String _name = '';
  String _major = '';
  String _campus = '';
  String _graduationYear = '';

  void _handleInfoSubmit() async {
    if (_name.isEmpty || _major.isEmpty || _campus.isEmpty || _graduationYear.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All fields are required!')));
      return;
    }

    try {
      final DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      await userRef.set({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'name': _name,
        'major': _major,
        'campus': _campus,
        'graduationYear': _graduationYear,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving data. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Info'),
        backgroundColor: Color(0xFF0557fa),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name:',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _name = value),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Major:',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _major = value),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Campus:',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _campus = value),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Expected Graduation Year:',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _graduationYear = value),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _handleInfoSubmit,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0557fa),
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
