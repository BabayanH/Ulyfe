import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unimatch/pages/events/CreateEvent.dart';
import 'package:unimatch/pages/events/event.dart';
import 'package:unimatch/pages/events/event_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';



const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const whiteColor = Color(0xFFFFFFFF); // white

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
  static const String routeName = '/eventspage';
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _events = [];
  List<String> _selectedPrices = [];
  List<String> _selectedLocations = [];
  List<String> _selectedEventTypes = [];

  String getCurrentUserId() {
    // Get the current user's UID
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<List<Event>> _fetchEvents({
    String? searchKeyword,
    List<String>? selectedPrices,
    List<String>? selectedLocations,
    List<String>? selectedEventTypes,
  }) async {
    Query eventsQuery = FirebaseFirestore.instance.collection('events');

    if (searchKeyword != null && searchKeyword.isNotEmpty) {
      eventsQuery = eventsQuery
          .where('title', isGreaterThanOrEqualTo: searchKeyword)
          .where('title', isLessThan: searchKeyword + 'z');
    }

    QuerySnapshot eventsSnapshot = await eventsQuery.get();
    List<Event> eventsList = eventsSnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

    // Combine date and time and sort logic
    DateTime now = DateTime.now();
    eventsList = eventsList
        .where((event) {
      DateTime eventDateTime = DateTime.parse('${event.date} ${event.time}');
      return eventDateTime.isAfter(now) || eventDateTime.isAtSameMomentAs(now);
    })
        .toList()
      ..sort((a, b) {
        DateTime dateTimeA = DateTime.parse('${a.date} ${a.time}');
        DateTime dateTimeB = DateTime.parse('${b.date} ${b.time}');
        return dateTimeA.compareTo(dateTimeB);
      });

    if (selectedPrices != null && selectedPrices.isNotEmpty) {
      eventsList = eventsList.where((event) {
        int price = int.tryParse(event.price) ?? 0;
        if (selectedPrices.contains('Free') && price == 0) return true;
        if (selectedPrices.contains('1-15') && price >= 1 && price <= 15) return true;
        if (selectedPrices.contains('16-25') && price >= 16 && price <= 25) return true;
        if (selectedPrices.contains('26+') && price >= 26) return true;
        return false;
      }).toList();
    }

    if (selectedLocations != null && selectedLocations.isNotEmpty) {
      eventsList = eventsList.where((event) => selectedLocations.contains(event.location)).toList();
    }

    if (selectedEventTypes != null && selectedEventTypes.isNotEmpty) {
      eventsList = eventsList.where((event) => selectedEventTypes.contains(event.type)).toList();
    }


    return eventsList;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Filter Events'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildFilterCheckboxListTile('Free', 'Free', _selectedPrices, setState),
                    _buildFilterCheckboxListTile('1-15', '1-15', _selectedPrices, setState),
                    _buildFilterCheckboxListTile('16-25', '16-25', _selectedPrices, setState),
                    _buildFilterCheckboxListTile('26+', '26+', _selectedPrices, setState),
                    Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildFilterCheckboxListTile('on campus', 'on campus', _selectedLocations, setState),
                    _buildFilterCheckboxListTile('off campus', 'off campus', _selectedLocations, setState),
                    Text('Event Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildFilterCheckboxListTile('party', 'party', _selectedEventTypes, setState),
                    _buildFilterCheckboxListTile('clubs', 'clubs', _selectedEventTypes, setState),
                    _buildFilterCheckboxListTile('school', 'school', _selectedEventTypes, setState),
                    _buildFilterCheckboxListTile('others', 'others', _selectedEventTypes, setState),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: primaryColor)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _resetFilters();
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Reset', style: TextStyle(color: primaryColor)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _applyFilters();
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Apply', style: TextStyle(color: primaryColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterCheckboxListTile(String title, String filterValue, List<String> selectedFilters, StateSetter setState) {
    return CheckboxListTile(
      title: Text(title),
      value: selectedFilters.contains(filterValue),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedFilters.add(filterValue);
          } else {
            selectedFilters.remove(filterValue);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: primaryColor,
    );
  }

  void _resetFilters() {
    _selectedPrices.clear();
    _selectedLocations.clear();
    _selectedEventTypes.clear();
    _fetchEvents().then((events) {
      setState(() => _events = events);
    });
  }

  void _applyFilters() {
    _fetchEvents(
      searchKeyword: _searchController.text,
      selectedPrices: _selectedPrices,
      selectedLocations: _selectedLocations,
      selectedEventTypes: _selectedEventTypes,
    ).then((events) => setState(() => _events = events));
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents().then((events) {
      setState(() => _events = events);
    });
    _searchController.addListener(() {
      _fetchEvents(searchKeyword: _searchController.text).then((events) {
        setState(() => _events = events);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = getCurrentUserId();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Image.asset(
                'assets/ULyfelogo.png',
                height: 30,
                fit: BoxFit.fitHeight,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Events',
                      hintStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.search, color: whiteColor),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: whiteColor),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: whiteColor),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ],
        ),
      ),
      body: _events.isNotEmpty ? ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          bool isCreator = event.uid.isNotEmpty && event.uid == currentUserId;

          return isCreator ? Dismissible(
            key: Key(event.docId ?? 'default'), // Use a unique key for Dismissible
            background: Container(
              color: Colors.grey,
              child: Container(
                color: Colors.red,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ),
            ),
            // secondaryBackground: Container(
            //   color: Colors.red,
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 20),
            //       child: Icon(Icons.delete, color: Colors.white),
            //     ),
            //   ),
            // ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
                // Delete functionality with confirmation dialog
                final confirmDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text("Are you sure you want to delete this event?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel", style: TextStyle(color:primaryColor),),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Delete", style: TextStyle(color:primaryColor)),
                        ),
                      ],
                    );
                  },
                );
                if (confirmDelete && event.docId != null) {
                  await FirebaseFirestore.instance.collection('events').doc(event.docId).delete();
                  print("event deleted");
                  setState(() {
                    _events.removeAt(index);
                  });
                  return true;
                }

                // return false;

              return false;
            },

            onDismissed: (direction) {
              // Optional: Handle the swipe dismissal
            },
            child: buildEventCard(event),
          ) : buildEventCard(event);
        },
      ) : Center(
        child: Text('No Events found', style: TextStyle(color: whiteColor, fontSize: 18.0)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateEvent())),
        child: Icon(Icons.add, size: 40),
        backgroundColor: primaryColor,
      ),
    );
  }
  Widget buildEventCard(Event event) {
    return Card(
      color: Color(0xFF111111),
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)),
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
                        Text(event.title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: whiteColor)),
                        SizedBox(height: 8.0),
                        Text(event.time, style: TextStyle(color: whiteColor)),
                        Text(event.location, style: TextStyle(color: whiteColor)),
                      ],
                    ),
                  ),
                  Text('\$${event.price}', style: TextStyle(color: whiteColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
