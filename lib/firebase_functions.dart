import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getAnonymousUserID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userID = prefs.getString('anonymousUserID');

  if (userID == null) {
    userID = DateTime.now().millisecondsSinceEpoch.toString(); // Generating a unique ID based on current time
    await prefs.setString('anonymousUserID', userID);
  }

  return userID;
}

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
      'votes': 0, // Initialize votes to 0
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newPostRef.id;
  } catch (error) {
    print('Error adding forum post: $error');
    return null;
  }
}
// Function to add an event to the database
Future<String?> addEvent(Map<String, dynamic> eventData) async {
  try {
    CollectionReference eventsCollection = db.collection("events");

    // Upload thumbnail to Firebase Storage and get its download URL
    String fileNameThumbnail = eventData['thumbnail'].path.split('/').last;
    Reference thumbnailStorageRef = storage.ref().child('eventImages/$fileNameThumbnail');

    // Upload the thumbnail image file
    await thumbnailStorageRef.putFile(eventData['thumbnail']);

    // Get the download URL of the uploaded thumbnail image
    String thumbnailUrl = await thumbnailStorageRef.getDownloadURL();

    // Upload other images to Firebase Storage and get their download URLs
    List<String> imageUrls = [];
    for (var imageFile in eventData['images']) {

      // Extract the file name from the path
      String fileName = imageFile.path.split('/').last;
      Reference storageRef = storage.ref().child('eventImages/$fileName');

      // Upload the image file
      await storageRef.putFile(imageFile);

      // Get the download URL of the uploaded image
      String imageUrl = await storageRef.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    // Create a new event document
    DocumentReference newEventRef = await eventsCollection.add({
      'title': eventData['title'],
      'description': eventData['description'],
      'date': eventData['date'],
      'time': eventData['time'],
      'location': eventData['location'],
      'price': eventData['price'],
      'thumbnail': thumbnailUrl,
      'images': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
      'uid': eventData['uid'],
      'type': eventData['type'],
    });

    return newEventRef.id;
  } catch (error) {
    print('Error adding event: $error');
    return null;
  }
}

// TODO: You can add other functions like addEvent and fetchEvents in a similar manner.
