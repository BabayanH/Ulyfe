import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../firebase_helper.dart';
import 'event.dart';
import 'event_details_page.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _events = [];
  String? _selectedPrice;
  String? _selectedLocation;
  String? _selectedEventType;

  Future<List<Event>> _fetchEvents({String? searchKeyword}) async {
    List<Event> eventsList = [];
    Query eventsQuery = db.collection('events');

    if (searchKeyword != null && searchKeyword.isNotEmpty) {
      eventsQuery = eventsQuery
          .where('title', isGreaterThanOrEqualTo: searchKeyword)
          .where('title', isLessThan: searchKeyword + 'z');
    }

    QuerySnapshot eventsSnapshot = await eventsQuery.get();
    for (var eventDoc in eventsSnapshot.docs) {
      eventsList.add(Event(
        id: eventDoc.id.hashCode,
        title: eventDoc['title'],
        date: eventDoc['date'],
        time: eventDoc['time'],
        price: eventDoc['price'],
        location: eventDoc['location'],
        thumbnail: eventDoc['thumbnail'],
        description: eventDoc['description'],
      ));
    }

    return eventsList;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text('Price'),
                value: _selectedPrice,
                items: ['Free', '0-20', '>20'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPrice = value;
                  });
                },
              ),
              DropdownButton<String>(
                hint: Text('Location'),
                value: _selectedLocation,
                items: ['On Campus', 'Off Campus'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
              ),
              DropdownButton<String>(
                hint: Text('Event Type'),
                value: _selectedEventType,
                items: ['Party', 'Club'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEventType = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents().then((events) => setState(() {
          _events = events;
        }));

    _searchController.addListener(() {
      _fetchEvents(searchKeyword: _searchController.text)
          .then((events) => setState(() {
                _events = events;
              }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0557fa),
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Events',
              hintStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            style: TextStyle(color: Colors.white),

          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return Card(
                  margin: EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(event: event),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(event.thumbnail),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(event.title,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8.0),
                                    Text(event.date),
                                    Text(event.location),
                                  ],
                                ),
                              ),
                              Text('\$${event.price}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ));
            }));
  }
}
