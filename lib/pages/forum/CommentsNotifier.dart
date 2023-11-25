
import 'package:flutter/material.dart';
// Comment model
class Comment {
  final String id;
  final String text;
  final String userId;
  final String? parentId;
  final DateTime createdAt;
  int votes;
  int userVote;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    this.parentId,
    required this.createdAt,
    this.votes = 0,
    this.userVote = 0,
  });
}

// CommentNotifier
class CommentsNotifier extends ChangeNotifier {
  List<Comment> comments = [];

  void setComments(List<Comment> newComments) {
    comments = newComments;
    notifyListeners();
  }

  void updateVote(String commentId, int change) {
    final comment = comments.firstWhere((c) => c.id == commentId);
    if (comment.userVote == change) return;

    int voteIncrement = change;
    if (comment.userVote == -change) {
      voteIncrement = 2 * change;
    }

    comment.votes += voteIncrement;
    comment.userVote = change;



    notifyListeners();
  }
}
