import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

const backgroundColor = Color(0xFF000000); // Black
const primaryColor = Color(0xFFfaa805); // Golden
const whiteColor = Color(0xFFFFFFFF); // White
const errorColor = Color(0xFFff0000); // Red
const inputBorderColor = Color(0xFFfaa805); // Golden

class AccountNotSetUp extends StatefulWidget {
  @override
  _AccountNotSetUpState createState() => _AccountNotSetUpState();
}

class _AccountNotSetUpState extends State<AccountNotSetUp> {
  bool showForm = false;
  List<File> profileImages = [];
  String bio = '';
  String hobbies = '';
  String race = '';
  String gender = '';
  String age = '';
  final picker = ImagePicker();

  bool _isBioValid = true;
  bool _isHobbiesValid = true;
  bool _isRaceValid = true;
  bool _isGenderValid = true;
  bool _isAgeValid = true;
  bool _isImagesValid = true;

  void toggleForm() {
    setState(() => showForm = !showForm);
  }

  Future<void> handleFileInputChange() async {
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        profileImages.addAll(pickedFiles.map((file) => File(file.path)));
        _isImagesValid = profileImages.length >= 3;
      });
    }
  }

  void _removeImage(File image) {
    setState(() {
      profileImages.remove(image);
      _isImagesValid = profileImages.length >= 3;
    });
  }

  Future<void> handleSubmit() async {
    setState(() {
      _isBioValid = bio.isNotEmpty;
      _isHobbiesValid = hobbies.isNotEmpty;
      _isRaceValid = race.isNotEmpty;
      _isGenderValid = gender.isNotEmpty;
      _isAgeValid = age.isNotEmpty;
      _isImagesValid = profileImages.length >= 3;
    });

    if (!_isBioValid ||
        !_isHobbiesValid ||
        !_isRaceValid ||
        !_isGenderValid ||
        !_isAgeValid ||
        !_isImagesValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Please fill in all required fields and upload at least 3 images.')));
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User not authenticated.')));
        return;
      }

      List<String> uploadedImageUrls = [];
      for (var imageFile in profileImages) {
        String fileName = imageFile.path.split('/').last;
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('datingProfileImages/$fileName');

        await storageRef.putFile(imageFile);
        String downloadURL = await storageRef.getDownloadURL();
        uploadedImageUrls.add(downloadURL);
      }

      var datingProfileData = {
        'profileImages': uploadedImageUrls,
        'bio': bio,
        'hobbies': hobbies,
        'race': race,
        'gender': gender,
        'age': age,
        'uid': currentUser.uid,
      };

      DocumentReference docRef = await FirebaseFirestore.instance.collection('datingProfiles').add(datingProfileData);

      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'datingProfileSetup': true,
        'datingProfile': docRef,
      });

      Navigator.of(context).pushReplacementNamed('/datingPage');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occurred while submitting the form.')));
    }
  }

  InputDecoration _textFieldDecoration(String label, bool isValid) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isValid ? Colors.black : Colors.red),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.black : Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.black : Colors.red),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String value,
    required String hintText,
    required bool isValid,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isNotEmpty ? value : null,
      onChanged: (newValue) {
        onChanged(newValue);
        setState(() {
          isValid = newValue != null && newValue.isNotEmpty;
        });
      },
      decoration: _textFieldDecoration(hintText, isValid),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Colors.black)),
        );
      }).toList(),
      style: TextStyle(color: Colors.black),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: !showForm
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ready to Start Lynking?',
                style: TextStyle(color: Colors.black)),
            Text('Click below to create a Lynking profile!',
                style: TextStyle(color: Colors.black)),
            ElevatedButton(
              onPressed: toggleForm,
              child: Text('Join Now',
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(primary: primaryColor),
            ),
          ],
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  SizedBox(height: 30,),
                  ElevatedButton(
                    onPressed: handleFileInputChange,
                    child: Text('Select Profile Images',
                        style: TextStyle(color: Colors.white)),
                    style:
                    ElevatedButton.styleFrom(primary: primaryColor),
                  ),
                  Wrap(
                    spacing: 8.0, // Horizontal gap between items
                    runSpacing: 8.0, // Vertical gap between lines
                    children: profileImages.map((file) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(file, width: 100, height: 100),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(file),
                                child: Container(
                                  color: Colors.white,
                                  // Background color for contrast
                                  child: Icon(Icons.close,
                                      size: 20, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (!_isImagesValid)
                    Text('Please upload at least 3 images.',
                        style: TextStyle(color: Colors.red)),
                  SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        bio = value;
                        _isBioValid = value.isNotEmpty;
                      });
                    },
                    maxLines: 5,
                    decoration: _textFieldDecoration('Bio', _isBioValid),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        hobbies = value;
                        _isHobbiesValid = value.isNotEmpty;
                      });
                    },
                    decoration:
                    _textFieldDecoration('Hobbies', _isHobbiesValid),
                  ),
                  SizedBox(height: 20),
                  _buildDropdown(
                    items: ['Caucasian', 'African American', 'Asian', 'Hispanic', 'Other'],
                    value: race,
                    hintText: 'Race',
                    isValid: _isRaceValid,
                    onChanged: (newValue) {
                      setState(() {
                        race = newValue ?? '';
                        _isRaceValid = race.isNotEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 20),


                  _buildDropdown(
                    items: ['Male', 'Female', 'Other'],
                    value: gender,
                    hintText: 'Gender',
                    isValid: _isGenderValid,
                    onChanged: (newValue) {
                      setState(() {
                        gender = newValue ?? '';
                        _isGenderValid = gender.isNotEmpty;
                      });
                    },
                  ),

                  SizedBox(height: 20),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        age = value;
                        _isAgeValid = value.isNotEmpty;
                      });
                    },
                    decoration: _textFieldDecoration('Age', _isAgeValid),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: handleSubmit,
                    child: Text('Submit',
                        style: TextStyle(color: whiteColor)),
                    style:
                    ElevatedButton.styleFrom(primary: primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}
