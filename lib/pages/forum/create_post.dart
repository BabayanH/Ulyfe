import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../firebase_functions.dart';

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


  _pickImage({bool useCamera = false}) async {
    XFile? selectedImage = await _picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });
  }

  _handleSubmit() async {
    try {
      if (_forumTitleController.text.isEmpty || _descriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Forum title and description are required!')));
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
        'tags': _tagsController.text.split(',').map((tag) => tag.trim()).toList(), // Assuming comma-separated tags
        'images': imageFile == null ? [] : [imageFile],  // Use the converted File object here
      };

      // Assuming "your-user-id" is a placeholder. Replace with the actual user ID logic
      String userId = "your-user-id";
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating post!')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')));
    }
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
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tags (comma separated)',
                helperText: 'Enter related tags, separated by commas',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(),
                  icon: Icon(Icons.photo),
                  label: Text('Select from Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(useCamera: true),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Use Camera'),
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
                minimumSize: Size(double.infinity, 50), // double.infinity means it takes full width
              ),
            ),
          ],
        ),
      ),
    );
  }
}