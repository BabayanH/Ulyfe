import 'package:flutter/material.dart';
import 'forum_feed.dart';
import 'create_post.dart';

class ForumPage extends StatefulWidget {
  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool _showCreatePost = false;

  void _handleCreatePostClick() {
    setState(() {
      _showCreatePost = true;
    });
  }

  final categories = [
    {
      "name": "Professors",
      "subcategories": ["Professor 1", "Professor 2", "Professor 3"]
    },
    {
      "name": "Classes",
      "subcategories": ["Class 1", "Class 2", "Class 3"]
    },
    {
      "name": "Majors",
      "subcategories": ["Major 1", "Major 2", "Major 3"]
    },
    {
      "name": "Restaurants",
      "subcategories": ["Restaurant 1", "Restaurant 2", "Restaurant 3"]
    },
    {
      "name": "Clubs",
      "subcategories": ["Club 1", "Club 2", "Club 3"]
    },
    {
      "name": "Frats/Sorority",
      "subcategories": ["Frat/Sorority 1", "Frat/Sorority 2", "Frat/Sorority 3"]
    },
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF0557FA),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _handleCreatePostClick,
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: _showCreatePost ? CreatePost() : ForumFeed(),
      drawer: buildDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle FAB press
        },
        child: Icon(Icons.chat),
      ),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        children: categories.map<Widget>((category) {
          return ExpansionTile(
            title: Text(category['name'] as String),
            children:
            (category['subcategories'] as List).map<Widget>((subcategory) {
              return ListTile(
                title: Text(subcategory as String),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}


