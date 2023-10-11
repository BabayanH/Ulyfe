import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../firebase_helper.dart';
import '../../firebase_functions.dart';
import './comments_screen.dart';

class ForumFeed extends StatefulWidget {
  @override
  _ForumFeedState createState() => _ForumFeedState();
}

class _ForumFeedState extends State<ForumFeed> {
  Stream<QuerySnapshot>? forumPostsStream;

  @override
  void initState() {
    super.initState();
    forumPostsStream = db.collection('forumPosts').orderBy('createdAt', descending: true).snapshots();
  }

  _vote(String postId, int change) async {
    String userID = await getAnonymousUserID();
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await db.collection('forumPosts').doc(postId).get();
      if (!postSnapshot.exists) {
        throw Exception('Post does not exist!');
      }
      Map<String, dynamic>? postData = postSnapshot.data() as Map<String, dynamic>?;
      List<String> votedUsers = List<String>.from(postData?['votedUsers'] ?? []);
      if (!votedUsers.contains(userID)) {
        int currentVotes = postData != null ? (postData['votes'] ?? 0) : 0;
        int updatedVotes = currentVotes + change;
        votedUsers.add(userID); // Add the user to the voted list
        transaction.update(postSnapshot.reference, {
          'votes': updatedVotes,
          'votedUsers': votedUsers,
        });
      }
    });
  }





  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: forumPostsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> forumPosts = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: forumPosts.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> postData = forumPosts[index].data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postData['forumTitle'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(postData['description']),
                    SizedBox(height: 16),
                    Column(
                      children: List.generate(postData['images'].length, (imgIndex) {
                        return Image.network(postData['images'][imgIndex]);
                      }),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.thumb_up_outlined, color: Color(0xFF0557fa)),
                              onPressed: () => _vote(forumPosts[index].id, 1), // +1 for upvote
                            ),
                            Text('${postData['votes'] ?? 0}'),
                            IconButton(
                              icon: Icon(Icons.thumb_down_outlined, color: Color(0xFF0557fa)),
                              onPressed: () => _vote(forumPosts[index].id, -1), // -1 for downvote
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.comment, color: Color(0xFF0557fa)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsScreen(postId: forumPosts[index].id)));
                              },
                            ),

                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.share, color: Color(0xFF0557fa)),
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
      },
    );
  }
}
