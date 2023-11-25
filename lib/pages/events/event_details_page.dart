import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'event.dart';

class EventDetailsPage extends StatelessWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(event.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Check if there is more than one image
              if (event.images.isNotEmpty)
                event.images.length > 1
                    ? CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    enlargeCenterPage: true,
                    autoPlay: event.images.length > 1,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    pauseAutoPlayOnTouch: true,
                    aspectRatio: 2.0,
                  ),
                  items: event.images.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        );
                      },
                    );
                  }).toList(),
                )
                    : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(event.images.first),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              SizedBox(height: 20),

              // Date
              Text('Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white)),
              SizedBox(height: 5),
              Text(event.date, style: TextStyle(fontSize: 15.0, color: Colors.white)),
              Text(event.time, style: TextStyle(fontSize: 15.0, color: Colors.white)),

              // Price
              SizedBox(height: 15),
              Text('Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white)),
              SizedBox(height: 5),
              Text(event.price, style: TextStyle(fontSize: 15.0, color: Colors.green)),

              // Location
              SizedBox(height: 15),
              Text('Location:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white)),
              SizedBox(height: 5),
              Text(event.location, style: TextStyle(fontSize: 15.0, color: Colors.white)),

              // Description
              SizedBox(height: 20),
              Divider(thickness: 1.0, color: Colors.white),
              SizedBox(height: 20),
              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white)),
              SizedBox(height: 10),
              Text(event.description, style: TextStyle(fontSize: 15.0, height: 1.5, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
