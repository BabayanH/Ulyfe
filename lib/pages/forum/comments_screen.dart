import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_functions.dart';
import '../../firebase_helper.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  CommentsScreen({required this.postId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();

  _addComment(String postId, String commentText) async {
    String userID = await getAnonymousUserID();
    FirebaseFirestore.instance
        .collection('forumPosts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': userID,
      'text': commentText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  _voteComment(String commentId, int change) async {
    // Add voting logic for comments here, similar to the post voting logic
  }

  _addReply(String commentId) {
    // Add logic to add a reply to the comment here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments', ),
        backgroundColor: Color(0xFF0557fa),
        centerTitle: true,

      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('forumPosts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> commentData =
                        comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Adjust as needed
                      leading: Container(
                        width: 35.0,
                        alignment: Alignment.center,
                        child: Icon(Icons.person, color: Color(0xFF0557fa)),
                      ),
                      title: Text(commentData['text']),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5.0), // Adjust as needed
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.thumb_up, size: 15, color: Color(0xFF0557fa)),
                              onPressed: () => _voteComment(comments[index].id, 1), // +1 for upvote
                              padding: EdgeInsets.zero, // Remove padding
                            ),
                            IconButton(
                              icon: Icon(Icons.thumb_down, size: 15, color: Color(0xFF0557fa)),
                              onPressed: () => _voteComment(comments[index].id, -1), // -1 for downvote
                              padding: EdgeInsets.zero, // Remove padding
                            ),
                            IconButton(
                              icon: Icon(Icons.reply, size: 15, color: Color(0xFF0557fa)),
                              onPressed: () => _addReply(comments[index].id), // Reply to comment
                              padding: EdgeInsets.zero, // Remove padding
                            ),
                          ],
                        ),
                      ),
                    );

                  },
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      _addComment(widget.postId, _commentController.text);
                      _commentController.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
