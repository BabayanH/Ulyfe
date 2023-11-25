import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dating_page.dart';

class SwipeableCard extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback? onSuperlike;
  final VoidCallback? onReverse;

  const SwipeableCard({
    Key? key,
    required this.userProfile,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.onSuperlike,
    this.onReverse,
  }) : super(key: key);

  @override
  _SwipeableCardState createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> {
  double dragStartPosition = 0.0;
  double currentDrag = 0.0;
  String userName = "";
  String major = "";
  String graduationYear = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    try {
      var userDoc = await _firestore
          .collection('users')
          .doc(widget.userProfile.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['name'] ?? 'No Name';
          major = userDoc.data()?['major'] ?? 'No Major';
          graduationYear =
              userDoc.data()?['graduationYear'] ?? 'No Graduation Year';
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  void onDragStart(DragStartDetails details) {
    dragStartPosition = details.globalPosition.dx;
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      currentDrag = details.globalPosition.dx - dragStartPosition;
    });
  }

  void onDragEnd(DragEndDetails details) {
    if (currentDrag.abs() > 100) {
      // Threshold for swipe
      if (currentDrag > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
    }
    setState(() {
      currentDrag = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double rotate = currentDrag / 500; // Control the rotation
    Matrix4 transform = Matrix4.rotationZ(rotate)..translate(currentDrag);

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragStart: onDragStart,
            onHorizontalDragUpdate: onDragUpdate,
            onHorizontalDragEnd: onDragEnd,
            onTap: () => setState(() {
              currentImageIndex = (currentImageIndex + 1) %
                  widget.userProfile.profileImages.length;
            }),
            child: Transform(
              transform: transform,
              alignment: Alignment.center,
              child: Card(
                color: Color(0xFF111111), // Black background for the card
                child: SingleChildScrollView(
                  // Make the card scrollable
                  child: Column(
                    children: [
                      // Fixed size profile image
                      GestureDetector(
                        onTapUp: (details) {
                          double width = MediaQuery.of(context).size.width;
                          if (details.globalPosition.dx < width / 2) {
                            // Tap on the left side
                            setState(() {
                              currentImageIndex = currentImageIndex > 0
                                  ? currentImageIndex - 1
                                  : widget.userProfile.profileImages.length - 1;
                            });
                          } else {
                            // Tap on the right side
                            setState(() {
                              currentImageIndex = (currentImageIndex + 1) %
                                  widget.userProfile.profileImages.length;
                            });
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              widget.userProfile.profileImages[currentImageIndex],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 400, // Fixed height
                            ),
                            Positioned(
                              left: 16,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                    color: Color(0xFFfaa805)),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex = currentImageIndex > 0
                                        ? currentImageIndex - 1
                                        : widget.userProfile.profileImages
                                                .length -
                                            1;
                                  });
                                },
                              ),
                            ),
                            Positioned(
                              right: 16,
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: Color(0xFFfaa805)),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex = (currentImageIndex + 1) %
                                        widget.userProfile.profileImages.length;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Centered title for user's name and age
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '${userName.isNotEmpty ? userName : 'Loading...'}, ${widget.userProfile.age}',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Profile details section
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoText('Gender: ', widget.userProfile.gender),
                            _buildDivider(),
                            _buildInfoText('Race: ', widget.userProfile.race),
                            _buildDivider(),
                            _buildInfoText('Major: ', major),
                            _buildDivider(),
                            _buildInfoText('Graduation Year: ', graduationYear),
                            _buildDivider(),
                            _buildInfoText(
                                'Hobbies: ', widget.userProfile.hobbies),
                            _buildDivider(),
                            _buildInfoText('Bio: ', widget.userProfile.bio),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildButtonBar(),


        ),
        SizedBox(height: 10,),
      ],
    );
  }

  Widget _buildButtonBar() {
    return Container(
      color: Color(0xFF111111).withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.undo, color: Colors.yellow, size: 40),
            onPressed: () {
              widget.onReverse?.call();
            },
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red, size: 40),
            onPressed: () {
              widget.onSwipeLeft();
            },
          ),
          IconButton(
            icon: Icon(Icons.star, color: Colors.blue, size: 40),
            onPressed: () {
              widget.onSuperlike?.call();
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.green, size: 40),
            onPressed: () {
              widget.onSwipeRight();
            },
          ),
        ],
      ),
    );
  }


  Widget _buildInfoText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
              text: label, style: TextStyle(color: Colors.grey, fontSize: 18)),
          TextSpan(
              text: value, style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Column(
      children: [
        SizedBox(height: 8), // Space above the divider
        Divider(color: Colors.grey),
        SizedBox(height: 8), // Space below the divider
      ],
    );
  }
}
