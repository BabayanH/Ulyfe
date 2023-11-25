import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DatingProfileView.dart';
import 'dating_page.dart'; // Assuming this is where your UserProfile model is defined

class MatchedProfilesWidget extends StatefulWidget {
  @override
  _MatchedProfilesWidgetState createState() => _MatchedProfilesWidgetState();
}

class _MatchedProfilesWidgetState extends State<MatchedProfilesWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserProfile> matches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _fetchMatches() async {
    setState(() => isLoading = true);
    try {
      String currentUserId = getCurrentUserId();
      DocumentReference userActionsRef =
          _firestore.collection('userActions').doc(currentUserId);
      DocumentSnapshot userActionsSnapshot = await userActionsRef.get();

      if (userActionsSnapshot.exists) {
        Map<String, dynamic> userActionsData =
            userActionsSnapshot.data() as Map<String, dynamic>? ?? {};
        List<dynamic> matchIds =
            List.from(userActionsData['matches'] ?? []).reversed.toList();

        List<UserProfile> fetchedMatches = [];
        for (var uid in matchIds) {
          var profileSnapshot = await _firestore
              .collection('datingProfiles')
              .where('uid', isEqualTo: uid)
              .get();
          var userSnapshot =
              await _firestore.collection('users').doc(uid).get();

          if (profileSnapshot.docs.isNotEmpty && userSnapshot.exists) {
            Map<String, dynamic> profileData =
                profileSnapshot.docs.first.data() as Map<String, dynamic>;
            Map<String, dynamic> userData =
                userSnapshot.data() as Map<String, dynamic>;

            UserProfile userProfile = UserProfile.fromMap({
              ...profileData,
              'name': userData['name'] ?? '',
              'major': userData['major'] ?? '',
              'graduationYear': userData['graduationYear'] ?? '',
            });
            fetchedMatches.add(userProfile);
          }
        }

        setState(() {
          matches = fetchedMatches;
          isLoading = false;
        });
      } else {
        print("User actions document does not exist.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching matches: $e");
      setState(() => isLoading = false);
    }
  }

  void _showProfileDetail(BuildContext context, UserProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Profile Detail"),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                profile.profileImages.isNotEmpty
                    ? Image.network(profile.profileImages.first,
                        fit: BoxFit.cover)
                    : Placeholder(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.bio, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Age: ${profile.age}"),
                      Text("Gender: ${profile.gender}"),
                      Text("Hobbies: ${profile.hobbies}"),
                      Text("Race: ${profile.race}"),
                      // Add other details you want to show
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : matches.isNotEmpty
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    childAspectRatio:
                        4 / 5, // Adjust the ratio to make images smaller
                    crossAxisSpacing: 8, // Space between columns
                    mainAxisSpacing: 8, // Space between rows
                  ),
                  padding: EdgeInsets.all(8), // Padding around the grid
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    UserProfile match = matches[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                DatingProfileView(userProfile: match),
                          ),
                        );
                      },
                      child: GridTile(
                        /*footer: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.bottomLeft,
                child: Text(
                  match.name, // Display the name
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),*/
                        child: Container(
                          margin: EdgeInsets.all(4), // Margin around each image
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(match.profileImages.isNotEmpty
                                  ? match.profileImages.first
                                  : 'fallbackImageUrl'),
                              // Replace with a fallback image URL
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Text('No matches yet.', style: TextStyle(color: Colors.white)),
    );
  }
}
