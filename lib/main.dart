import 'package:flutter/material.dart';
import './screens/home_page.dart';
import './screens/favori_page.dart';

void main() {
  runApp(MyApp()); // Initializing the application.
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book App', // Application title.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Theme color.
      ),
      home: AppNavigator(), // Using AppNavigator for the home page.
    );
  }
}

class AppNavigator extends StatefulWidget {
  @override
  _AppNavigatorState createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _currentIndex = 0; // Initially selected page index.

  final List<Widget> _pages = [
    FavoriPage(), // Favorite page.
    HomePage(), // Home page.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Displayed page.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Changing the page based on the tapped bottom navigation bar item.
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Bottom navigation bar item - Home.
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search', // Bottom navigation bar item - Search.
          ),
        
        ],
      ),
    );
  }
}
