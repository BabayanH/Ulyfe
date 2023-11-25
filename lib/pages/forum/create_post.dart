import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../firebase_functions.dart';
import '../main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805); // golden

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController _forumTitleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();
  XFile? _image;

  final ImagePicker _picker = ImagePicker();
  List<String> selectedTags = [];

  _pickImage({bool useCamera = false}) async {
    XFile? selectedImage = await _picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });
  }


  _handleSubmit() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in!')));
      return;
    }
    final String userId = currentUser.uid;

    try {
      if (_forumTitleController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          selectedTags.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('All fields are required except for the picture!')));
        return;
      }

      // Convert XFile to File
      File? imageFile;
      if (_image != null) {
        imageFile = File(_image!.path);
      }

      // Prepare postData for addForumPost function
      Map<String, dynamic> postData = {
        'forumTitle': _forumTitleController.text,
        'description': _descriptionController.text,
        'tags': selectedTags,
        'images': imageFile == null ? [] : [imageFile],  // Use the converted File object here
      };

      // Call the addForumPost function using the fetched userId
      String? postId = await addForumPost(userId, postData);

      if (postId != null) {
        // Reset form fields
        _forumTitleController.clear();
        _descriptionController.clear();
        _tagsController.clear();
        setState(() {
          _image = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post created successfully!')));

        // Close the CreatePost and navigate back to the MainPage.
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating post!')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')));
    }
  }


  final List<Map<String, String>> tagOptions = [
    // General
    { 'value': "professors", 'label': "Professors" },
    { 'value': "classes", 'label': "Classes" },
    { 'value': "majors", 'label': "Majors" },
    { 'value': "clubs", 'label': "Clubs" },
    { 'value': "restaurants", 'label': "Restaurants" },
    { 'value': "frats-sororities", 'label': "Frats/Sororities" },

    // Academics
    { 'value': "study-tips", 'label': "Study Tips" },
    { 'value': "internships", 'label': "Internships" },
    { 'value': "academic-challenges", 'label': "Academic Challenges" },

    // Campus Life
    { 'value': "campus-events", 'label': "Campus Events" },
    { 'value': "roommate-issues", 'label': "Roommate Issues" },
    { 'value': "dorm-life", 'label': "Dorm Life" },
    { 'value': "student-organizations", 'label': "Student Organizations" },
    { 'value': "sports-athletics", 'label': "Sports and Athletics" },
    { 'value': "campus-safety", 'label': "Campus Safety" },

    // Wellness
    { 'value': "mental-health", 'label': "Mental Health" },
    { 'value': "fitness-health", 'label': "Fitness and Health" },

    // Finance
    { 'value': "part-time-jobs", 'label': "Part-Time Jobs" },
    { 'value': "student-loans", 'label': "Student Loans" },
    { 'value': "student-discounts", 'label': "Student Discounts" },
    { 'value': "student-budgeting", 'label': "Student Budgeting" },

    // Student Life
    { 'value': "international-students", 'label': "International Students" },
    { 'value': "student-housing", 'label': "Student Housing" },

    // Experiences
    { 'value': "travel-adventure", 'label': "Travel and Adventure" },
    { 'value': "alumni-stories", 'label': "Alumni Stories" },

    // Creativity
    { 'value': "art-creativity", 'label': "Art and Creativity" },
    { 'value': "lgbtq-support", 'label': "LGBTQ+ Support" },

    // Tech & Gadgets
    { 'value': "technology-gadgets", 'label': "Technology and Gadgets" },
  ];

  Widget buildTags() {
    return Wrap(
      spacing: 8.0,
      children: List<Widget>.generate(
        tagOptions.length,
            (int index) {
          return ChoiceChip(
            label: Text(tagOptions[index]['label']!),
            selected: selectedTags.contains(tagOptions[index]['value']),
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  selectedTags.add(tagOptions[index]['value']!);
                } else {
                  selectedTags.removeWhere((String tagValue) {
                    return tagValue == tagOptions[index]['value'];
                  });
                }
              });
            },
            selectedColor: primaryColor, // <- Here's the color change for the tags when they are selected
          );
        },
      ).toList(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Create Post"),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _forumTitleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Forum Title',
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 20),
            Text("Select Tags:"),
            buildTags(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(),
                  icon: Icon(Icons.photo),
                  label: Text('Select from Gallery'),
                  style: ElevatedButton.styleFrom(primary: primaryColor,),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(useCamera: true),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Use Camera'),
                  style: ElevatedButton.styleFrom(primary: primaryColor,),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 5,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
              },
              child: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
                minimumSize: Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}