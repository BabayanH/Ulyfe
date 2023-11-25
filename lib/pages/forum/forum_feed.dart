import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../firebase_helper.dart';
import 'SinglePostScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';

const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805); // golden

class ForumFeed extends StatefulWidget {
  final String? selectedTag;
  ForumFeed({Key? key, required this.selectedTag}) : super(key: key);


  // ForumFeed({this.selectedTag});

  @override
  _ForumFeedState createState() => _ForumFeedState();
}

class _ForumFeedState extends State<ForumFeed> {
  Stream<QuerySnapshot>? forumPostsStream;

  @override
  void initState() {
    super.initState();
    setupForumPostsStream(widget.selectedTag);
  }
  @override
  void didUpdateWidget(ForumFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTag != oldWidget.selectedTag) {
      setupForumPostsStream(widget.selectedTag);
    }

  }

  void setupForumPostsStream(String? tag) {
    var query =
    db.collection('forumPosts').orderBy('createdAt', descending: true);

    if (tag != null && tag.isNotEmpty) {
      query = query.where('tags', arrayContains: tag);
    }

    setState(() {
      forumPostsStream = query.snapshots();
    });
  }

  void updateTagAndRefresh(String? newTag) {
    setupForumPostsStream(newTag);
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
          await db.collection('forumPosts').doc(postId).get();

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


  @override
  Widget build(BuildContext context) {

    return Container(
      color: backgroundColor,
      child: Builder(
          builder: (context) {
            final User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) {
              // Handle the case when the user is not authenticated.
              // For instance, you can return a message or a sign-in button.
              return Center(child: Text('Please log in to view the feed!'));
            }

            final String userID = currentUser.uid;


            return StreamBuilder<QuerySnapshot>(

              stream: forumPostsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> forumSnapshot) {
                List<DocumentSnapshot> forumPosts =
                    forumSnapshot.data?.docs ?? [];
                if (forumSnapshot.hasError) {
                  print("Stream encountered an error: ${forumSnapshot.error}");
                  return Center(child: Text('Error: ${forumSnapshot.error}'));
                }

                switch (forumSnapshot.connectionState) {
                  case ConnectionState.none:
                    print("Stream is null");
                    break;
                  case ConnectionState.waiting:
                    print("Waiting for stream data...");
                    break;
                  case ConnectionState.active:
                    print("Stream is active");
                    break;
                  case ConnectionState.done:
                    print("Stream is done");
                    break;
                }

                if (!forumSnapshot.hasData) {
                  print("Stream has no data.");
                  return Center(child: Text('No posts found.'));
                }
                if (forumSnapshot.hasError) {
                  return Center(child: Text('Error: ${forumSnapshot.error}'));
                }

                if (forumSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (forumPosts.isEmpty) {
                  String noPostsMessage;
                  if (widget.selectedTag != null && widget.selectedTag!.isNotEmpty) {
                    // Show a text message that there are no posts for the selected tag
                    noPostsMessage = 'No posts made on the tag "${widget.selectedTag}".';
                  } else {
                    // This will handle the case where there are no posts at all, regardless of the tag
                    noPostsMessage = 'No posts made yet.';
                  }




                  return Center(child: Text(noPostsMessage));
                }

                return ListView.builder(
                  itemCount: forumPosts.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> postData =
                        forumPosts[index].data() as Map<String, dynamic>;

                    // Determine the user's vote.
                    Map<String, dynamic>? votesMap;
                    if (postData['votes'] is Map<String, dynamic>) {
                      votesMap = postData['votes'];
                    }
                    int? userVote = votesMap?[userID];

                    // Set the button colors based on the user's vote.
                    Color upvoteColor =
                        (userVote == 1) ? Colors.green : Colors.white;
                    Color downvoteColor =
                        (userVote == -1) ? Colors.red : Colors.white;

                    return Card(
                      color: Color(0xFF111111),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: InkWell(onTap: () {
                        // Navigate to the SinglePostScreen when the entire post is clicked
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SinglePostScreen(postId: forumPosts[index].id),
                          ),
                        );
                      },
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
                                    color: whiteColor),
                              ),
                              SizedBox(height: 8),
                              Text(
                                postData['description'],
                                style: TextStyle(color: whiteColor),
                              ),
                              SizedBox(height: 16),
                              if (postData['images'] != null && postData['images'].length > 0)
                                CarouselSlider.builder(
                                  itemCount: postData['images'].length,
                                  itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                                    return Image.network(postData['images'][itemIndex]);
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
                                Container(), // Display an empty container or any placeholder widget you want


                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.thumb_up_outlined,
                                              color: upvoteColor),
                                          onPressed: () => _vote(
                                              forumPosts[index].id,
                                              1), // +1 for upvote
                                        ),
                                        Text(
                                          '${postData['votesCount'] ?? 0}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.thumb_down_outlined,
                                              color: downvoteColor),
                                          onPressed: () =>
                                              _vote(forumPosts[index].id, -1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.comment,
                                            color: Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SinglePostScreen(
                                                          postId:
                                                              forumPosts[index]
                                                                  .id)));
                                        },
                                      ),
                                    ],
                                  ),
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
                    );
                  },
                );
              },
            );
          }),
    );
  }
}
