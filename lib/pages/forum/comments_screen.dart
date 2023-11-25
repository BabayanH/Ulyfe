import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../firebase_functions.dart';
import '../../firebase_helper.dart';

const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805); // golden

class CommentsScreen extends StatefulWidget {
  final String postId;

  CommentsScreen({required this.postId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  Map<String, int> _commentVotes = {}; // This will store the votes count for each comment
  Map<String, int> _userVotes = {};   // This will store the user's vote (-1, 0, 1) for each comment
  ValueNotifier<Map<String, int>> _commentVotesNotifier = ValueNotifier({});
  ValueNotifier<Map<String, int>> _userVotesNotifier = ValueNotifier({});


  Future<void> _addComment(String postId, String commentText,
      [String? parentId]) async {
    String userID = await getAnonymousUserID();
    FirebaseFirestore.instance.collection('forumPosts').doc(postId).collection(
        'comments').add({
      'userId': userID,
      'text': commentText,
      'parentId': parentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }


  Future<void> _voteComment(String commentId, int change) async {
    String userID = await getAnonymousUserID();

    int currentVote = _commentVotes[commentId] ?? 0;
    int currentUserVote = _userVotes[commentId] ?? 0;

    if (currentUserVote == change) {
      print("You've already voted in this direction.");
      return;
    }

    int voteIncrement = change;

    if (currentUserVote == -change) {
      voteIncrement = 2 * change;
    }

    _commentVotes[commentId] = currentVote + voteIncrement;
    _userVotes[commentId] = change;

    _commentVotesNotifier.value = {..._commentVotes};  // This ensures the UI reacts to changes
    _userVotesNotifier.value = {..._userVotes};

    try {
      DocumentReference commentRef = FirebaseFirestore.instance.collection('forumPosts').doc(widget.postId).collection('comments').doc(commentId);
      await commentRef.update({
        "userVotes.$userID": change,
        "votes": FieldValue.increment(voteIncrement),
      });
    } catch (error) {
      _commentVotes[commentId] = currentVote;  // Reverting the optimistic UI update
      _userVotes[commentId] = currentUserVote;
      _commentVotesNotifier.value = {..._commentVotes};
      _userVotesNotifier.value = {..._userVotes};

      // Optionally show an error to the user
    }
  }



  Future<void> _addReply(String commentId) async {
    String? replyText = await _showReplyDialog();
    if (replyText != null && replyText.isNotEmpty) {
      _addComment(widget.postId, replyText, commentId);
    }
  }

  Future<String?> _showReplyDialog() async {
    TextEditingController replyController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Write your reply"),
          content: TextField(controller: replyController),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, replyController.text);
              },
              child: Text("Post"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        automaticallyImplyLeading: false,  // Add this line

      ),
      body: Column(
        children: [
          Expanded(child: _buildCommentsList()),
          Divider(),
          _buildCommentInput(),
        ],

      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(

      stream: db.collection('forumPosts').doc(widget.postId).collection(
          'comments').orderBy('createdAt').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        List<DocumentSnapshot> comments = snapshot.data!.docs;
        List<DocumentSnapshot<Object?>> topLevelComments = comments.where((
            doc) =>
        !((doc.data() as Map<String, dynamic>).containsKey('parentId')) ||
            doc['parentId'] == null
        ).toList();

        return ListView.builder(
          itemCount: topLevelComments.length,
          itemBuilder: (context, index) {
            return _buildCommentTile(topLevelComments[index], comments, 0);
          },
        );
      },
    );
  }

  Widget _IconButton(IconData icon, VoidCallback onPressed, Color color) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color),  // Increased the icon size for better visibility
      onPressed: onPressed,
      padding: EdgeInsets.symmetric(horizontal: 5.0),  // Padding to make the buttons closer to each other and the comment
    );
  }


  Widget _buildCommentTile(DocumentSnapshot comment, List<DocumentSnapshot> allComments, int depth) {
    return FutureBuilder<String>(
      future: getAnonymousUserID(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String? userID = snapshot.data;

          Map<String, dynamic> commentData = comment.data() as Map<String, dynamic>;

          if (!_commentVotes.containsKey(comment.id)) {
            _commentVotes[comment.id] = commentData["votes"] ?? 0;
          }

          if (!_userVotes.containsKey(comment.id) && commentData["userVotes"] != null) {
            _userVotes[comment.id] = commentData["userVotes"][userID!] ?? 0;
          }

          return ValueListenableBuilder(
            valueListenable: _userVotesNotifier,
            builder: (context, Map<String, int> userVotes, _) {
              Color upvoteColor = userVotes[comment.id] == 1 ? Colors.green : Colors.white;
              Color downvoteColor = userVotes[comment.id] == -1 ? Colors.red : Colors.white;

              return ValueListenableBuilder(
                valueListenable: _commentVotesNotifier,
                builder: (context, Map<String, int> commentVotes, _) {
                  Text voteCountText = Text("${commentVotes[comment.id] ?? 0}", style: TextStyle(color: Colors.white));

                  List<DocumentSnapshot<Object?>> replies = allComments.where((doc) =>
                  (doc.data() as Map<String, dynamic>).containsKey('parentId') && doc['parentId'] == comment.id).toList();

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.only(left: depth * 20.0, top: 4.0, bottom: 4.0, right: 8.0),
                        title: Text(comment['text'], style: TextStyle(color: Colors.white)),
                        subtitle: Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _IconButton(Icons.arrow_upward_rounded, () {
                                _voteComment(comment.id, 1);
                              }, upvoteColor),
                              voteCountText,
                              _IconButton(Icons.arrow_downward_rounded, () {
                                _voteComment(comment.id, -1);
                              }, downvoteColor),
                              _IconButton(Icons.reply, () => _addReply(comment.id), Colors.white),
                            ],
                          ),
                        ),
                      ),
                      for (var reply in replies)
                        _buildCommentTile(reply, allComments, depth + 1),
                    ],
                  );
                },
              );
            },
          );
        }
      },
    );
  }


  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                filled: true,
                // Set the fill color based on the theme's brightness
                fillColor:   Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: whiteColor),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                _addComment(widget.postId, _commentController.text);
                _commentController.clear();
              }
            },
          ),

        ],
      ),
    );
  }

}
class CommentsWidget extends StatelessWidget {
  final String postId;

  CommentsWidget({required this.postId});

  @override
  Widget build(BuildContext context) {
    return CommentsScreen(postId: postId);
  }
}
