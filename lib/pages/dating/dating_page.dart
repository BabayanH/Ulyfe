import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class DatingPage extends StatefulWidget {
  @override
  _DatingPageState createState() => _DatingPageState();
}

class _DatingPageState extends State<DatingPage> {
  List<UserProfile> users = [
    UserProfile(
        id: 1,
        name: 'Davit',
        image: AssetImage('assets/dav.jpeg'),
        bio: "I am Davit and I am Autistic"),
    UserProfile(
        id: 2,
        name: 'Hovsep',
        image: AssetImage('assets/hos.jpeg'),
        bio: "Howdy I am Hovsep and I am retarded"),
  ];

  int currentIndex = 0;

  void handleAction(String action) {
    print('User action: $action on profile ${users[currentIndex].name}');
    setState(() {
      currentIndex = (currentIndex + 1) % users.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0557FA),
          title: TabBar(
            tabs: [
              Tab(text: 'Lynks'),
              Tab(text: 'People'),
              Tab(text: 'Chats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Likes Tab
            Center(child: Text('Lynk Tab ')),

            // Matches Tab
            Center(
              child: Column(
                children: [
                  Expanded(
                    child: CardSwiper(
                      cardsCount: users.length,
                      cardBuilder: (context, index, percentThresholdX,
                          percentThresholdY) {
                        final user = users[index];
                        return Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 400,
                                height: 530,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: user.image,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      bottom: 20,
                                      left: 20,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            user.bio,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => handleAction('dislike'),
                        color: Colors.red,
                        iconSize: 40,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => handleAction('back'),
                        color: Colors.yellow,
                        iconSize: 40,
                      ),
                      IconButton(
                        icon: Icon(Icons.star),
                        onPressed: () => handleAction('superlike'),
                        color: Colors.blue,
                        iconSize: 40,
                      ),
                      IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () => handleAction('like'),
                        color: Colors.green,
                        iconSize: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Messages Tab
            Center(child: Text('Chats Tab ')),
          ],
        ),
      ),
    );
  }
}

class UserProfile {
  final int id;
  final String name;
  final ImageProvider image;
  final String bio;

  UserProfile({
    required this.id,
    required this.name,
    required this.image,
    required this.bio,
  });
}
