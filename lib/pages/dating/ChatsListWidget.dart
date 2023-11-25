import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatPage.dart';
import 'dating_page.dart';

class ChatsListWidget extends StatefulWidget {
  @override
  _ChatsListWidgetState createState() => _ChatsListWidgetState();
}

class _ChatsListWidgetState extends State<ChatsListWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chatRooms')
          .where('participants', arrayContains: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
          return Center(child: Text("No chats available"));
        }

        List<QueryDocumentSnapshot> chatRooms = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            var chatRoomId = chatRooms[index].id;
            var participants = (chatRooms[index].data() as Map)['participants'] as List;
            var otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');

            return FutureBuilder<QuerySnapshot>(
              future: _firestore.collection('datingProfiles').where('uid', isEqualTo: otherUserId).limit(1).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                  return ListTile(title: Text("Loading..."));
                }

                UserProfile otherUser = UserProfile.fromMap(userSnapshot.data!.docs.first.data() as Map<String, dynamic>);

                return FutureBuilder<DocumentSnapshot>(
                  future: _getLatestMessage(chatRoomId),
                  builder: (context, messageSnapshot) {
                    if (!messageSnapshot.hasData) {
                      return ListTile(title: Text("Loading..."));
                    }

                    var lastMessage = messageSnapshot.data!.data() as Map<String, dynamic> ?? {};

                    return Card(
                      color: Colors.grey[350], // Slightly darker shade for the card
                      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Space between cards
                      child: ListTile(
                        leading: otherUser.profileImages.isNotEmpty
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(otherUser.profileImages.first),
                        )
                            : CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        subtitle: Text(lastMessage['text'] ?? "No messages"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(profileUser: otherUser),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<DocumentSnapshot> _getLatestMessage(String chatRoomId) async {
    var messagesSnapshot = await _firestore.collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    return messagesSnapshot.docs.first;
  }
}
