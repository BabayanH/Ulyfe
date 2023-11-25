import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'forum_feed.dart';
import 'create_post.dart';

const backgroundColor = Color(0xFF000000); // black
const primaryColor = Color(0xFFfaa805); // golden
const errorColor = Color(0xFFff0000); // red
const whiteColor = Color(0xFFFFFFFF); // white
const authContainerBackground = Color(0xFF000000); // black
const inputBorderColor = Color(0xFFfaa805); // golden

class ForumPage extends StatefulWidget {
  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool _showCreatePost = false;
  String _selectedTag = '';

  void _handleCreatePostClick() {
    setState(() {
      _showCreatePost = true;
    });
  }

  void _handleTagSelection(String tag) {
    setState(() {
      _selectedTag = tag;
      _showCreatePost = false; // Hide create post view when a tag is selected
    });
    Navigator.of(context).pop(); // Close the drawer after selection
  }

  final categories = [
    {
      "name": "General",
      "tags": [
        {"name": "Professors", "tag": "professors"},
        {"name": "Classes", "tag": "classes"},
        {"name": "Majors", "tag": "majors"},
        {"name": "Clubs", "tag": "clubs"},
        {"name": "Restaurants", "tag": "restaurants"},
        {"name": "Frats/Sororities", "tag": "frats-sororities"},
      ],
    },
    {
      "name": "Academics",
      "tags": [
        {"name": "Study Tips", "tag": "study-tips"},
        {"name": "Internships", "tag": "internships"},
        {"name": "Academic Challenges", "tag": "academic-challenges"},
      ],
    },
    {
      "name": "Campus Life",
      "tags": [
        {"name": "Campus Events", "tag": "campus-events"},
        {"name": "Roommate Issues", "tag": "roommate-issues"},
        {"name": "Dorm Life", "tag": "dorm-life"},
        {"name": "Student Organizations", "tag": "student-organizations"},
        {"name": "Sports and Athletics", "tag": "sports-athletics"},
        {"name": "Campus Safety", "tag": "campus-safety"},
      ],
    },
    {
      "name": "Wellness",
      "tags": [
        {"name": "Mental Health", "tag": "mental-health"},
        {"name": "Fitness and Health", "tag": "fitness-health"},
      ],
    },
    {
      "name": "Finance",
      "tags": [
        {"name": "Part-Time Jobs", "tag": "part-time-jobs"},
        {"name": "Student Loans", "tag": "student-loans"},
        {"name": "Student Discounts", "tag": "student-discounts"},
        {"name": "Student Budgeting", "tag": "student-budgeting"},
      ],
    },
    {
      "name": "Student Life",
      "tags": [
        {"name": "International Students", "tag": "international-students"},
        {"name": "Student Housing", "tag": "student-housing"},
      ],
    },
    {
      "name": "Experiences",
      "tags": [
        {"name": "Travel and Adventure", "tag": "travel-adventure"},
        {"name": "Alumni Stories", "tag": "alumni-stories"},
      ],
    },
    {
      "name": "Creativity",
      "tags": [
        {"name": "Art and Creativity", "tag": "art-creativity"},
        {"name": "LGBTQ+ Support", "tag": "lgbtq-support"},
      ],
    },
    {
      "name": "Tech & Gadgets",
      "tags": [
        {"name": "Technology and Gadgets", "tag": "technology-gadgets"},
      ],
    },
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        // Different colors for light and dark mode
        automaticallyImplyLeading: false,
        // This will remove the default leading button.
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Image.asset(
                  'assets/ULyfelogo.png', // Add the logo here
                  height: 30.0, // Adjust size as needed
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),

                // Icon(
                //   Icons.search,
                //   color: Colors.white,
                // ),
                // SizedBox(width: 8.0),
                // Expanded(
                //   child: TextField(
                //     decoration: InputDecoration(
                //       hintText: 'Search...',
                //       hintStyle: TextStyle(color: Colors.white),
                //       border: InputBorder.none,
                //     ),
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: _handleCreatePostClick,
                      tooltip: 'Create Post',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        title: null,
        // We set the title to null as we are managing layout with flexibleSpace.
        elevation: 0, // This removes the shadow under the AppBar.
      ),
      body:
          _showCreatePost ? CreatePost() : ForumFeed(selectedTag: _selectedTag),
      drawer: buildDrawer(),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView.builder(
        itemCount: categories.length + 1, // Plus 1 for the 'Home' tile
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            // This is the 'Home' list tile
            return ListTile(
              leading: Icon(Icons.home,
                  color: _selectedTag.isEmpty ? primaryColor : Colors.black),
              title: Text('Home',
                  style: TextStyle(
                      color:
                          _selectedTag.isEmpty ? primaryColor : Colors.black)),
              onTap: () {
                setState(() {
                  _selectedTag = ''; // Clear the selected tag
                  _showCreatePost =
                      false; // Optionally reset the show create post flag
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            );
          } else {
            // Adjust the index for categories as we have an extra 'Home' item at index 0
            var categoryIndex = index - 1;
            var category = categories[categoryIndex];
            List tags = category['tags'] as List;

            bool isCategorySelected =
                tags.any((tag) => tag['tag'] == _selectedTag);

            return ExpansionTile(
              title: Text(
                category['name'] as String,
                style: TextStyle(
                  color: isCategorySelected ? primaryColor : Colors.black,
                ),
              ),
              children: tags.map<Widget>((tag) {
                bool isSelected = _selectedTag == tag['tag'];

                return Container(
                  color: isSelected ? primaryColor : Colors.transparent,
                  child: ListTile(
                    title: Text(
                      tag['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      _handleTagSelection(tag['tag'] as String);
                    },
                  ),
                );
              }).toList(),
              iconColor: isCategorySelected ? primaryColor : Colors.black,
              collapsedIconColor:
                  isCategorySelected ? primaryColor : Colors.black,
            );
          }
        },
      ),
    );
  }
}
