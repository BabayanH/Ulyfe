import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AccountNotSetUp.dart';
import 'ChatsListWidget.dart';
import 'MatchedProfilesWidget.dart';
import 'SwipeableCard.dart';

class DatingPage extends StatefulWidget {
  @override
  _DatingPageState createState() => _DatingPageState();
}

class _DatingPageState extends State<DatingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserProfile> users = [];
  List<UserProfile> matches = [];
  bool isLoading = true;
  UserProfile? lastInteractedUser;
  String? lastAction;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _fetchProfiles() async {
    setState(() => isLoading = true);

    try {
      String currentUserId = getCurrentUserId();
      var userActionsRef =
          _firestore.collection('userActions').doc(currentUserId);
      var userActionsSnapshot = await userActionsRef.get();
      var userActionsData = userActionsSnapshot.data();

      List<String> interactedUserIds = [];
      if (userActionsData != null) {
        interactedUserIds
            .addAll(List<String>.from(userActionsData['likes'] ?? []));
        interactedUserIds
            .addAll(List<String>.from(userActionsData['dislikes'] ?? []));
        interactedUserIds
            .addAll(List<String>.from(userActionsData['superlikes'] ?? []));
      }

      var collection = _firestore.collection('datingProfiles');
      var querySnapshot = await collection.get();
      var allProfiles = querySnapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .where((profile) => profile.uid != currentUserId)
          .toList();

      setState(() {
        users = allProfiles
            .where((profile) => !interactedUserIds.contains(profile.uid))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching profiles: $e");
      setState(() => isLoading = false);
    }
  }

  void _handleUserAction(String action, UserProfile user,
      {bool isReverse = false}) async {
    String currentUserId = getCurrentUserId();
    DocumentReference currentUserRef =
        _firestore.collection('userActions').doc(currentUserId);
    DocumentReference otherUserRef =
        _firestore.collection('userActions').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot currentUserSnapshot =
          await transaction.get(currentUserRef);
      DocumentSnapshot otherUserSnapshot = await transaction.get(otherUserRef);

      Map<String, dynamic> currentUserData = currentUserSnapshot.exists
          ? currentUserSnapshot.data() as Map<String, dynamic>
          : {};
      Map<String, dynamic> otherUserData = otherUserSnapshot.exists
          ? otherUserSnapshot.data() as Map<String, dynamic>
          : {};

      List<String> currentUserMatches =
          List<String>.from(currentUserData['matches'] ?? []);
      List<String> otherUserMatches =
          List<String>.from(otherUserData['matches'] ?? []);

      if (!isReverse) {
        List<String> updatedActions =
            List<String>.from(currentUserData[action] ?? []);
        if (!updatedActions.contains(user.uid)) {
          updatedActions.add(user.uid);
          currentUserData[action] = updatedActions;
          transaction.set(currentUserRef, currentUserData);
        }

        if ((action == 'likes' || action == 'superlikes') &&
            List<String>.from(otherUserData['likes'] ?? [])
                .contains(currentUserId)) {
          if (!currentUserMatches.contains(user.uid)) {
            currentUserMatches.add(user.uid);
            currentUserData['matches'] = currentUserMatches;
            transaction.set(currentUserRef, currentUserData);
          }

          if (!otherUserMatches.contains(currentUserId)) {
            otherUserMatches.add(currentUserId);
            otherUserData['matches'] = otherUserMatches;
            transaction.set(otherUserRef, otherUserData);
          }
        }
      } else {
        if (currentUserMatches.contains(user.uid) ||
            otherUserMatches.contains(currentUserId)) {
          // Do not allow reverse if they have already matched
          return;
        }

        currentUserData['likes'] =
            List<String>.from(currentUserData['likes'] ?? [])
                .where((id) => id != user.uid)
                .toList();
        currentUserData['dislikes'] =
            List<String>.from(currentUserData['dislikes'] ?? [])
                .where((id) => id != user.uid)
                .toList();
        currentUserData['superlikes'] =
            List<String>.from(currentUserData['superlikes'] ?? [])
                .where((id) => id != user.uid)
                .toList();
        transaction.set(currentUserRef, currentUserData);
      }
    });

    if (!isReverse) {
      setState(() {
        users.remove(user);
        lastInteractedUser = user;
        lastAction = action;
      });
    }
  }

  // Implement a method to handle the reverse action
  void _onReverse() async {
    if (lastInteractedUser != null && lastAction != null) {
      String currentUserId = getCurrentUserId();
      DocumentReference userActionsRef =
          _firestore.collection('userActions').doc(currentUserId);
      DocumentSnapshot userActionsSnapshot = await userActionsRef.get();
      Map<String, dynamic> userActionsData =
          userActionsSnapshot.data() as Map<String, dynamic> ?? {};

      // Correctly cast the matches list
      List<String> matchIds =
          List<String>.from(userActionsData['matches'] ?? []);

      // Check if the last interacted user is in the matches list
      if (!matchIds.contains(lastInteractedUser!.uid)) {
        _handleUserAction(lastAction!, lastInteractedUser!, isReverse: true);
        setState(() {
          users.add(lastInteractedUser!);
        });
      } else {
        // Optionally, show a message that the action can't be reversed due to a match
        print("Action can't be reversed as you've matched with this user.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: Colors.black,
          bottom: TabBar(
            labelColor: Colors.orange, // Replace with your primaryColor
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'People'),
              Tab(text: 'Lynks'),
              Tab(text: 'Chats'),
            ],
            indicatorColor: Colors.orange, // Replace with your primaryColor
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : users.isNotEmpty
                      ? Stack(
                          children: users.map((user) {
                            return SwipeableCard(
                              userProfile: user,
                              onSwipeLeft: () =>
                                  _handleUserAction('dislikes', user),
                              onSwipeRight: () =>
                                  _handleUserAction('likes', user),
                              onSuperlike: () =>
                                  _handleUserAction('superlikes', user),
                              onReverse: _onReverse, // Implement this
                            );
                          }).toList(),
                        )
                      : Text('No more profiles. Come back later',
                          style: TextStyle(color: Colors.white)),
            ),
            MatchedProfilesWidget(),
            ChatsListWidget(),
          ],
        ),
      ),
    );
  }
}

class UserProfile {
  final String age;
  final String bio;
  final String gender;
  final String hobbies;
  final List<String> profileImages;
  final String race;
  final String uid;
  final String major; // Assuming these fields can be null
  final String graduationYear;

  UserProfile({
    required this.age,
    required this.bio,
    this.gender = '',
    required this.hobbies,
    required this.profileImages,
    this.race = '',
    required this.uid,
    this.major = '',
    this.graduationYear = '',
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      age: data['age'] ?? '',
      bio: data['bio'] ?? '',
      gender: data['gender'] ?? '',
      hobbies: data['hobbies'] ?? '',
      profileImages: List<String>.from(data['profileImages'] ?? []),
      race: data['race'] ?? '',
      uid: data['uid'] ?? '',
      major: data['major'] ?? '',
      graduationYear: data['graduationYear'] ?? '',
    );
  }
}
