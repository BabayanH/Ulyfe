import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../firebase_helper.dart';
class ForumFeed extends StatefulWidget {
  @override
  _ForumFeedState createState() => _ForumFeedState();
}

class _ForumFeedState extends State<ForumFeed> {
  List<Map<String, dynamic>> forumPosts = []; // Initialize with an empty list

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch forum post data from Firestore
  fetchData() async {
    try {
      CollectionReference postsCollection = db.collection('forumPosts');
      // Order the posts by 'createdAt' in ascending order
      QuerySnapshot querySnapshot = await postsCollection.orderBy('createdAt', descending: false).get();
      List<Map<String, dynamic>> postsData = [];

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        postsData.add({
          'id': doc.id,
          'title': data['forumTitle'],
          'content': data['description'],
          'images': data['images'],
        });
      });
      setState(() {
        forumPosts = postsData;
      });
    } catch (error) {
      print('Error fetching forum posts: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (forumPosts.isEmpty) {
      // Show loading spinner if forumPosts is empty
      return Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: forumPosts.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forumPosts[index]['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(forumPosts[index]['content']),
                SizedBox(height: 16),
                Column(
                  children: List.generate(forumPosts[index]['images'].length, (imgIndex) {
                    return Image.network(forumPosts[index]['images'][imgIndex]);
                  }),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thumb_up_outlined, color: Colors.grey),
                        SizedBox(width: 50),
                        Icon(Icons.thumb_down_outlined, color: Colors.grey),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.comment, color: Colors.grey),

                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.share, color: Colors.grey),

                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
