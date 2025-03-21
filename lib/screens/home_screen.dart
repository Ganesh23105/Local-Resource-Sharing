import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_resource_sharing/screens/add_item_screen.dart';
import 'package:local_resource_sharing/screens/login_screen.dart';
import 'package:local_resource_sharing/models/resource_item.dart';
import 'package:local_resource_sharing/widgets/resource_card.dart';

/// **HomeScreen Class**
/// Displays user info, resource list, and logout functionality.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String userEmail = '';

  List<ResourceItem> items = [
    ResourceItem(
      name: 'Drill Machine',
      category: 'Home Appliances',
      image: 'assets/images/drill_machine.png',
      icon: Icons.construction,
      owner: 'Rahul Sharma',
      description: 'Powerful drill for various tasks',
    ),
    ResourceItem(
      name: 'Lawn Mower',
      category: 'Gardening',
      image: 'assets/images/lawn_mower.png',
      icon: Icons.grass,
      owner: 'Priya Patel',
      description: 'Efficient lawn mower for a perfect lawn',
    ),
    ResourceItem(
      name: 'Projector',
      category: 'Electronics',
      image: 'assets/images/projector.png',
      icon: Icons.tv,
      owner: 'Amit Verma',
      description: 'High-resolution projector for home theater',
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// **Loads user data from SharedPreferences**
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
      userEmail = prefs.getString('userEmail') ?? 'user@example.com';
    });
  }

  /// **Handles user logout and clears session**
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate to LoginScreen and remove all previous screens
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Resource Sharing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: $userEmail',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Resource List
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ResourceCard(item: items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
