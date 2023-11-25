
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "dart:io";
import "../main_page.dart";
import 'dart:io';

import 'package:image_picker/image_picker.dart';


const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805); // golden
class CreateEvent extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();

}

class _CreateEventState extends State<CreateEvent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String locationValue = '';
  String typeValue = '';
  // List<dynamic> images = [];
  // dynamic thumbnail;
  List<File> images = [];
  File? thumbnail;

  bool showSuccessNotification = false;
  // Add boolean flags for validation
  bool _isTitleValid = true;
  bool _isDescriptionValid = true;
  bool _isDateValid = true;
  bool _isTimeValid = true;
  bool _isPriceValid = true;
  bool _isLocationValid = true;
  bool _isTypeValid = true;
  bool _isThumbnailValid = true;
  bool _isImagesValid = true;

  Future<void> addEvent(Map<String, dynamic> eventData) async {
    try {
      CollectionReference eventsCollection = FirebaseFirestore.instance.collection("events");

      // Upload thumbnail to Firebase Storage and get its download URL
      String fileNameThumbnail = thumbnail?.path.split('/').last ?? '';
      Reference thumbnailStorageRef = FirebaseStorage.instance.ref().child('eventImages/$fileNameThumbnail');

      if (thumbnail != null) {
        await thumbnailStorageRef.putFile(thumbnail!);
        String thumbnailUrl = await thumbnailStorageRef.getDownloadURL();

        // Upload other images to Firebase Storage and get their download URLs
        List<String> imageUrls = [];
        for (var imageUri in images) {  // using images instead of imageFiles
          String fileName = imageUri.path.split('/').last;
          Reference storageRef = FirebaseStorage.instance.ref().child('eventImages/$fileName');

          // Upload the image file
          await storageRef.putFile(File(imageUri.path));

          // Get the download URL of the uploaded image
          String imageUrl = await storageRef.getDownloadURL();
          imageUrls.add(imageUrl);
        }

        // Create a new event document
        await eventsCollection.add({
          'title': eventData['title'],
          'description': eventData['description'],
          'date': eventData['date'],
          'time': eventData['time'],
          'location': eventData['location'],
          'price': eventData['price'],
          'thumbnail': thumbnailUrl,
          'images': imageUrls,
          'uid': eventData['uid'],
          'type': eventData['type'],
          'created': Timestamp.now(),

        });

      }
    } catch (error) {
      print('Error adding event: $error');
      throw error;  // rethrowing the error to handle it in the _handleSubmit function
    }
  }
  Widget _buildCancelButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage(startingIndex: 2)),
          );
        },
        child: Text('Cancel '),
        style: ElevatedButton.styleFrom(
          primary: primaryColor,
          minimumSize: Size(double.infinity, 50),
        ),
      ),
    );
  }
// Date and Time Picker Functions
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        // Format the TimeOfDay to a 24-hour format (HH:mm)
        final hours = picked.hour.toString().padLeft(2, '0');
        final minutes = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hours:$minutes";
      });
    }
  }


  InputDecoration _textFieldDecoration(String label, bool isValid) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isValid ? Colors.black : errorColor),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.black : errorColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: isValid ? Colors.black : errorColor),
      ),
      border: OutlineInputBorder(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Event'),
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _titleController,
                decoration: _textFieldDecoration('Title', _isTitleValid),
              ),
            ),

            // Description TextField
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _descriptionController,
                decoration: _textFieldDecoration('Description', _isDescriptionValid),
                maxLines: 4,
              ),
            ),

            // Date Picker TextField
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _dateController,
                decoration: _textFieldDecoration('Date',_isDateValid),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode()); // Prevent keyboard from appearing
                  _selectDate(context);
                },
              ),
            ),

            // Time Picker TextField
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _timeController,
                decoration: _textFieldDecoration('Time', _isTimeValid),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode()); // Prevent keyboard from appearing
                  _selectTime(context);
                },
              ),
            ),

            // Price TextField
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _priceController,
                decoration: _textFieldDecoration('Price', _isPriceValid),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 8.0,),
            _buildDropdown(
                items: ['on campus', 'off campus'],
                value: locationValue,
                onChanged: (value) {
                  setState(() => locationValue = value!);
                },
                hint: 'Select a location',
              isValid: _isLocationValid,
            ),

            SizedBox(height: 8.0,),

            _buildDropdown(
                items: ['party', 'clubs', 'school', 'other'],
                value: typeValue,
                onChanged: (value) {
                  setState(() => typeValue = value!);
                },
                hint: 'Select an event type',
                isValid: _isTypeValid,),
            _buildImagePicker(
              onThumbnailPicked: (selectedImage) {
                setState(() {
                  thumbnail = selectedImage;
                });
              },
              onImagesPicked: (selectedImages) {
                setState(() {
                  images = selectedImages;
                });
              },
              isMultiple: false,
              pickerLabel: "Select Thumbnail",
              isValid: _isThumbnailValid,



            ),
            _buildImagePicker(
              onThumbnailPicked: (selectedImage) {
                setState(() {
                  thumbnail = selectedImage;
                });
              },
              onImagesPicked: (selectedImages) {
                setState(() {
                  images = selectedImages;
                });
              },
              isMultiple: true,
              pickerLabel: "Select images",
              isValid: _isImagesValid,


            ),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text('Create Event'),
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            if (showSuccessNotification) Text('Event created successfully. Redirecting...')
          ],
        ),
      ),
      bottomNavigationBar: _buildCancelButton(context),

    );
  }



  Widget _buildDropdown({
    required List<String> items,
    required String value,
    required ValueChanged<String?> onChanged,
    required String hint,
    required bool isValid,
  }) {
    return DropdownButtonFormField(
      value: value.isEmpty ? null : value,
      items: items.map((String item) {
        return DropdownMenuItem(value: item, child: Text(item, style: TextStyle(color: Colors.black)));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: isValid ? Colors.black : errorColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isValid ? Colors.black : errorColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isValid ? Colors.black : errorColor),
        ),
        border: OutlineInputBorder(),
      ),
      style: TextStyle(color: Colors.black),
    );
  }


  Widget _buildImagePicker({
    required Function(File) onThumbnailPicked,
    required Function(List<File>) onImagesPicked,
    required bool isMultiple,
    required String pickerLabel,
    required bool isValid,

  }) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              if (isMultiple) {
                final List<XFile>? pickedFiles = await _picker.pickMultiImage();
                if (pickedFiles != null) {
                  List<File> pickedImages = pickedFiles.map((file) => File(file.path)).toList();
                  onImagesPicked(pickedImages);
                }
              } else {
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  File pickedThumbnail = File(pickedFile.path);
                  onThumbnailPicked(pickedThumbnail);
                }
              }
            },
          ),
          Text(pickerLabel, style: TextStyle(color: isValid ? Colors.black : errorColor),
          ),
        ],
      ),
    );
  }


  void _handleSubmit() async {
    // You will need to adapt this logic for your needs
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user is logged in.');
      setState(() {
        _isTitleValid = _titleController.text.isNotEmpty;
        _isDescriptionValid = _descriptionController.text.isNotEmpty;
        _isDateValid = _dateController.text.isNotEmpty;
        _isTimeValid = _timeController.text.isNotEmpty;
        _isPriceValid = _priceController.text.isNotEmpty;
        _isLocationValid = locationValue.isNotEmpty;
        _isTypeValid = typeValue.isNotEmpty;
        _isThumbnailValid = thumbnail != null;
        _isImagesValid = images.isNotEmpty;
      });

      if (!_isTitleValid ||
          !_isDescriptionValid ||
          !_isDateValid ||
          !_isTimeValid ||
          !_isPriceValid ||
          !_isLocationValid ||
          !_isTypeValid ||
          !_isThumbnailValid ||
          !_isImagesValid) {
        // Show error or handle mandatory fields not filled
        print('Please fill all fields and pick at least one image.');
        return;
      }
      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'location': locationValue,
        'price': _priceController.text,
        'thumbnail': thumbnail != null ? thumbnail!.path : '',
        'images': images.map((file) => file.path).toList(),
        'type': typeValue,
        'uid': currentUser.uid,
      };

      await addEvent(eventData);

      setState(() => showSuccessNotification = true);

      // Future.delayed(Duration(seconds: 3), () {
      //   Navigator.pop(context);
      // });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage(startingIndex: 2)),
        );
      }
    } catch (e) {
      print('Error adding event: $e');
    }
  }
}
