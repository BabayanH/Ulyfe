import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ChatPage.dart';
import 'dating_page.dart'; // Assuming this is where your UserProfile model is defined

class DatingProfileView extends StatefulWidget {
  final UserProfile userProfile;

  const DatingProfileView({Key? key, required this.userProfile}) : super(key: key);

  @override
  _DatingProfileViewState createState() => _DatingProfileViewState();
}

class _DatingProfileViewState extends State<DatingProfileView> {
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
          graduationYear = userDoc.data()?['graduationYear'] ?? 'No Graduation Year';
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Color(0xFF111111),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      currentImageIndex = (currentImageIndex + 1) %
                          widget.userProfile.profileImages.length;
                    }),
                    child: widget.userProfile.profileImages.isNotEmpty
                        ? Image.network(
                      widget.userProfile.profileImages[currentImageIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 400, // Fixed height
                    )
                        : Placeholder(),
                  ),
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37)),
                        onPressed: () {
                          setState(() {
                            currentImageIndex = currentImageIndex > 0
                                ? currentImageIndex - 1
                                : widget.userProfile.profileImages.length - 1;
                          });
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37)),
                        onPressed: () {
                          setState(() {
                            currentImageIndex = (currentImageIndex + 1) %
                                widget.userProfile.profileImages.length;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
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
                    _buildInfoText('Hobbies: ', widget.userProfile.hobbies),
                    _buildDivider(),
                    _buildInfoText('Bio: ', widget.userProfile.bio),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: double.infinity,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.chat, color: Color(0xFFfaa805), size: 30, ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(profileUser: widget.userProfile),
                        ),
                      );
                    },
                  )
                ),
              ),
            ],

          ),

        ),
      ),
    );
  }


  Widget _buildInfoText(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              // You might also specify other style properties if needed
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              // Additional style properties can be added here
            ),
          ),
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
