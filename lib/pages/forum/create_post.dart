import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
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
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _forumTitleController,
            decoration: InputDecoration(labelText: 'Forum Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: _tagsController,
            decoration: InputDecoration(labelText: 'Tags (comma separated)'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: () => _pickImage(),
                tooltip: 'Select image from gallery',
              ),
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () => _pickImage(useCamera: true),
                tooltip: 'Capture image with camera',
              ),
            ],
          ),
          if (_image != null)
            Image.file(
              File(_image!.path),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ElevatedButton(
            onPressed: _handleSubmit,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}