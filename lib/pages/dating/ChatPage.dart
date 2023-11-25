import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dating_page.dart'; // Ensure this is correctly imported for UserProfile

class ChatPage extends StatefulWidget {
  final UserProfile profileUser;

  ChatPage({Key? key, required this.profileUser}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  String? _chatRoomId;

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _findOrCreateChatRoom();
  }

  Future<void> _findOrCreateChatRoom() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final otherUserId = widget.profileUser.uid;

    _chatRoomId = generateChatRoomId(currentUserId, otherUserId);


    final chatRoomRef = _firestore.collection('chatRooms').doc(_chatRoomId);
    final chatRoomSnapshot = await chatRoomRef.get();

    if (!chatRoomSnapshot.exists) {
      await chatRoomRef.set({
        'participants': [currentUserId, otherUserId],
      });
    }

    setState(() {}); // Update the UI with the new chat room ID
  }

  String generateChatRoomId(String currentUserId, String otherUserId) {
    if (currentUserId.compareTo(otherUserId) < 0) {
      return currentUserId + "_" + otherUserId;
    } else {
      return otherUserId + "_" + currentUserId;
    }
  }


  Future<void> _sendMessage() async {
    if (_chatRoomId != null && _messageController.text.isNotEmpty) {
      await _firestore.collection('chatRooms').doc(_chatRoomId).collection(
          'messages').add({
        'text': _messageController.text,
        'sender': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  Stream<QuerySnapshot> _chatMessagesStream() {
    return _firestore
        .collection('chatRooms')
        .doc(_chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true, // Centers the title widget
        title: widget.profileUser.profileImages.isNotEmpty
            ? CircleAvatar(

          backgroundImage: NetworkImage(widget.profileUser.profileImages.first),
        )
            : CircleAvatar(
          child: Icon(Icons.person), // Default icon if no image available
        ),
      ),
      body: Container(
        color: Color(0xFF111111), // Background color
        child: Column(
          children: [
            Expanded(
              child: _chatRoomId == null
                  ? Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                stream: _chatMessagesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index].data() as Map<
                          String,
                          dynamic>;
                      bool isMe = message['sender'] == currentUserId;
                      return Align(
                        alignment: isMe ? Alignment.topRight : Alignment
                            .topLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: isMe ? Color(0xFFfaa805) : Colors.grey[300],
                            // Light grey for other user
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: isMe ? Colors.white : Colors
                                .black), // Black text for light background
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.black), // Text color
                      decoration: InputDecoration(
                        labelText: 'Type a message',
                        labelStyle: TextStyle(color: Colors.black),
                        // Label text color
                        fillColor: Colors.white,
                        // Background color of the text field
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.white), // Icon color
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
