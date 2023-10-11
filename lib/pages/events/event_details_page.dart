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
        centerTitle: true,
        backgroundColor: Color(0xFF0557fa),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Displaying the thumbnail
              if (event.thumbnail != null && event.thumbnail.isNotEmpty)
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(event.thumbnail),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10.0,
                          spreadRadius: 1.0,
                          color: Colors.black12,
                        )
                      ],
                    ),
                  ),
                ),
              if (event.thumbnail != null && event.thumbnail.isNotEmpty)
                SizedBox(height: 20),

              // Using varied font styles
              Text('Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
              SizedBox(height: 5),
              Text(event.date, style: TextStyle(fontSize: 15.0)),

              SizedBox(height: 15),

              Text('Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
              SizedBox(height: 5),
              Text(event.price, style: TextStyle(fontSize: 15.0, color: Colors.green)),

              SizedBox(height: 15),

              Text('Location:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
              SizedBox(height: 5),
              Text(event.location, style: TextStyle(fontSize: 15.0)),

              SizedBox(height: 20),
              Divider(thickness: 1.0),
              SizedBox(height: 20),

              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              SizedBox(height: 10),
              Text(event.description, style: TextStyle(fontSize: 15.0, height: 1.5)),

            ],
          ),
        ),
      ),
    );
  }
}
