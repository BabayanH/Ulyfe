import 'package:flutter/material.dart';
import 'event.dart';
import 'event_details_page.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Event> events = [
    Event(
      id: 1,
      title: 'Event 1',
      date: 'September 30, 2023',
      price: '10',
      location: 'On Campus',
      thumbnail: 'https://via.placeholder.com/100',
      description: 'Description for Event 1',
    ),
    Event(
      id: 2,
      title: 'Event 2',
      date: 'October 15, 2023',
      price: '15',
      location: 'Off Campus',
      thumbnail: 'https://via.placeholder.com/100',
      description: 'Description for Event 2',
    ),
    // ... add more events as needed
  ];

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price Filters
              DropdownButton<String>(
                hint: Text('Price'),
                items: ['Free', '0-20', '>20'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
              // Location Filters
              DropdownButton<String>(
                hint: Text('Location'),
                items: ['On Campus', 'Off Campus'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
              // Event Type Filters
              DropdownButton<String>(
                hint: Text('Event Type'),
                items: ['Party', 'Club'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
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
            prefixIcon: Icon(Icons.search, color: Colors.white,),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                // Handle tap
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
            ),
          );
        },
      ),
    );
  }
}
