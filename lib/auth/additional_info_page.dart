import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/main_page.dart';


const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805); // golden
class AdditionalInfoPage extends StatefulWidget {
  @override
  _AdditionalInfoPageState createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  String _name = '';
  String _major = '';
  String _campus = '';
  String _graduationYear = '';

  final List<String> _campuses = ['University', 'College'];

  void _handleInfoSubmit() async {
    if (_name.isEmpty ||
        _major.isEmpty ||
        _campus.isEmpty ||
        _graduationYear.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('All fields are required!')));
      return;
    }

    try {
      final DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userRef.set({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'name': _name,
        'major': _major,
        'campus': _campus,
        'graduationYear': _graduationYear,
        'datingNotSetup': false,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Set scaffold background to black
      appBar: AppBar(
        backgroundColor: backgroundColor, // Change AppBar color to black
        title: Text('Additional Info', style: TextStyle(color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              children: [
                _buildTextField('Name:', _name, (value) => _name = value),
                SizedBox(height: 10),
                _buildDropdownMajor(),
                SizedBox(height: 10),
                _buildDropdown('Campus:', _campuses, _campus,
                        (value) => _campus = value.toString()),
                SizedBox(height: 10),
                _buildTextField('Expected Graduation Year:', _graduationYear,
                        (value) => _graduationYear = value),
                SizedBox(height: 10),
              ElevatedButton(
                onPressed: _handleInfoSubmit,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)
                  ),
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
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
                child: Container(
                  width: double.infinity, // this will make the container expand full width of the button
                  height: 50, // you can adjust the height to your needs
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFfaa805),
                        Color(0xFFd47f00),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: Text('Submit')), // Center to ensure the text is aligned in the middle of the button
                ),
              ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(String label, String currentValue, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
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
      onChanged: (value) => setState(() {
        onChanged(value);
      }),
    );
  }

  Widget _buildDropdownMajor() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('majors')
          .orderBy('major') // Order by major field in ascending order.
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final majors = snapshot.data!.docs
            .map((doc) => doc['major'] as String)
            .toList();
        return _buildDropdown(
            'Major:', majors, _major, (value) => _major = value.toString());
      },
    );
  }

  Widget _buildDropdown(String label, List<String> items, String currentValue,
      Function(String?) onChanged) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor),
        ),
        border: OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          child: Text(item),
          value: item,
        );
      }).toList(),
      onChanged: (value) => setState(() {
        onChanged(value);
      }),
      value: currentValue.isNotEmpty ? currentValue : null,
    );
  }
}
