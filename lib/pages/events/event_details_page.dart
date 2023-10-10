import 'package:flutter/material.dart';
import 'event.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Date: ${event.date}'),
            Text('Price: ${event.price}'),
            Text('Location: ${event.location}'),
            SizedBox(height: 10),
            Text('Description: ${event.description}'),
          ],
        ),
      ),
    );
  }
}
