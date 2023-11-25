import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String price;
  final String thumbnail;
  final List<String> images;
  final String type;
  final String uid;
  final String? docId;

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.thumbnail,
    required this.images,
    required this.type,
    required this.uid,
    required this.docId,

  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    return Event(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      price: data['price'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      type: data['type'] ?? '',
      uid: data['uid'] ?? '',
      docId: doc.id,
    );
  }
}
