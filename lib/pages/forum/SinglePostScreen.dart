import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_functions.dart';
import '../../firebase_helper.dart';
import './comments_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const whiteColor = Color(0xFFFFFFFF); // white

class SinglePostScreen extends StatefulWidget {
  final String postId;

  SinglePostScreen({required this.postId});

  @override
  _SinglePostScreenState createState() => _SinglePostScreenState();
}

class _SinglePostScreenState extends State<SinglePostScreen> {
  late Stream<DocumentSnapshot> postStream;
  late Stream<QuerySnapshot> commentsStream;

  @override
  void initState() {
    super.initState();
    postStream = FirebaseFirestore.instance.collection('forumPosts').doc(widget.postId).snapshots();
    commentsStream = FirebaseFirestore.instance.collection('forumPosts').doc(widget.postId).collection('comments').snapshots();
  }

  _vote(String postId, int change) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the situation where the user is not logged in.
      // For instance, you can show a snackbar message.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to vote!'))
      );
      return;
    }

    String userID = currentUser.uid;
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot =
      await FirebaseFirestore.instance.collection('forumPosts').doc(postId).get();
      if (!postSnapshot.exists) {
        throw Exception('Post does not exist!');
      }
      Map<String, dynamic>? postData =
      postSnapshot.data() as Map<String, dynamic>?;

      // Get the votes map or initialize it if it doesn't exist.
      Map<String, dynamic> votes =
          postData?['votes'] as Map<String, dynamic>? ?? {};

      // Check if user has already voted.
      int? userVote = votes[userID] as int?;

      if (userVote == null) {
        // User hasn't voted yet.
        votes[userID] = change;
      } else if (userVote != change) {
        // User is changing from upvote to downvote or vice versa.
        votes[userID] = change;
      } else {
        // User is retracting their vote (e.g., undoing an upvote or downvote).
        votes.remove(userID);
      }

      // Compute the total votes.
      int totalVotes = 0;
      votes.forEach((key, value) {
        totalVotes += value as int;
      });

      transaction.update(postSnapshot.reference, {
        'votes': votes,
        'votesCount': totalVotes, // Update the total vote count.
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(
        child: Text('Please log in to view the post details.'),
      );
    }

    String userID = currentUser.uid;
    String timeAgoSinceDate(Timestamp timestamp) {
      DateTime notificationDate = timestamp.toDate();
      final dateNow = DateTime.now();
      final difference = dateNow.difference(notificationDate);

      if (difference.inDays >= 365) {
        return 'A year ago';
      } else if (difference.inDays >= 60) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays >= 30) {
        return '1 month ago';
      } else if (difference.inDays >= 14) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays >= 7) {
        return '1 week ago';
      } else if (difference.inDays >= 2) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays >= 1) {
        return '1 day ago';
      } else if (difference.inHours >= 2) {
        return '${difference.inHours} hours ago';
      } else if (difference.inHours >= 1) {
        return 'An hour ago';
      } else if (difference.inMinutes >= 2) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inMinutes >= 1) {
        return 'A minute ago';
      } else {
        return 'Just now';
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: postStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return Center(child: Text('Post not found'));
          }

          Map<String, dynamic> postData = snapshot.data!.data() as Map<String, dynamic>;

          int? userVote = postData['votes'][userID] as int?;
          Color upvoteColor = (userVote == 1)
              ? Colors.green
              : Colors.white;
          Color downvoteColor = (userVote == -1)
              ? Colors.red
              : Colors.white;

          return Column(
            children: [
              SingleChildScrollView(
                child: Card(
                  color: Color(0xFF111111),
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          postData['forumTitle'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: whiteColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          postData['description'],
                          style: TextStyle(color: whiteColor),
                        ),
                        SizedBox(height: 16),
                        if (postData['images'] != null &&
                            postData['images'].length > 0)
                          CarouselSlider.builder(
                            itemCount: postData['images'].length,
                            itemBuilder: (BuildContext context,
                                int itemIndex, int pageViewIndex) {
                              return Image.network(
                                  postData['images'][itemIndex]);
                            },
                            options: CarouselOptions(
                              autoPlay: false,
                              enlargeCenterPage: true,
                              viewportFraction: 0.9,
                              aspectRatio: 2.0,
                              initialPage: 0,
                            ),
                          )
                        else
                          Container(),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.thumb_up_outlined,
                                        color: upvoteColor),
                                    onPressed: () =>
                                        _vote(widget.postId, 1),
                                  ),
                                  Text(
                                    '${postData['votesCount'] ?? 0}',
                                    style: TextStyle(
                                        color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.thumb_down_outlined,
                                        color: downvoteColor),
                                    onPressed: () =>
                                        _vote(widget.postId, -1),
                                  ),
                                ],
                              ),
                            ),
                            // Uncomment the following lines if you want the comments button:
                            /*
                          IconButton(
                            icon: Icon(Icons.comment, color: Colors.grey),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommentsScreen(postId: widget.postId),
                                ),
                              );
                            },
                          ),
                          */

                          ],

                        ),
                        Text(
                          timeAgoSinceDate(postData['createdAt'] as Timestamp),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[500]),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: CommentsWidget(postId: widget.postId),
              ),
            ],
          );
        },
      ),
    );
  }

}
