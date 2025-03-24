import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_resource_sharing/screens/add_item_screen.dart';
import 'package:local_resource_sharing/screens/explore_resources_screen.dart';
import 'package:local_resource_sharing/screens/my_resources_screen.dart';
import 'package:local_resource_sharing/screens/borrow_requests_screen.dart';
import 'package:local_resource_sharing/screens/profile_screen.dart';
import 'package:local_resource_sharing/screens/nearby_resources_map.dart'; // ✅ Import the map screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Current selected tab index

  final List<Widget> _pages = [
    ExploreResourcesScreen(), // Index 0: Explore Resources
    MyResourcesScreen(), // Index 1: My Resources
    BorrowRequestsScreen(), // Index 2: My Borrow Requests
    NearbyResourcesMap(), // ✅ Index 3: Map of Nearby Resources
    ProfileScreen(), // Index 4: Profile (Settings & Logout)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all icons are visible
        selectedItemColor: Colors.blue, // Color for selected icon
        unselectedItemColor: Colors.grey, // Color for unselected icons
        showUnselectedLabels: true, // Show labels for all items

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'My Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map), // ✅ Map Icon Added
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
