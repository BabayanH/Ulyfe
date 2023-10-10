import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_helper.dart';

// Function to add a forum post to the database
Future<String?> addForumPost(String userId, Map<String, dynamic> postData) async {
  try {
    CollectionReference postsCollection = db.collection("forumPosts");

    // Upload images to Firebase Storage and get their download URLs
    List<String> imageUrls = [];
    for (var imageFile in postData['images']) {

      // Extract the file name from the path
      String fileName = imageFile.path.split('/').last;

      Reference storageRef = storage.ref().child('forumImages/$userId/$fileName');

      // Upload the image file
      await storageRef.putFile(imageFile);

      // Get the download URL of the uploaded image
      String imageUrl = await storageRef.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    // Create a new post document
    DocumentReference newPostRef = await postsCollection.add({
      'userId': userId,
      'forumTitle': postData['forumTitle'],
      'description': postData['description'],
      'images': imageUrls,
      'tags': postData['tags'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newPostRef.id;
  } catch (error) {
    print('Error adding forum post: $error');
    return null;
  }
}

// TODO: You can add other functions like addEvent and fetchEvents in a similar manner.
