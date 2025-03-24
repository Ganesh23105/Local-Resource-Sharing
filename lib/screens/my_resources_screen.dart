import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_resource_sharing/screens/database_service.dart';
import 'package:local_resource_sharing/screens/add_item_screen.dart';
import 'package:local_resource_sharing/screens/borrow_requests_for_owner_screen.dart';

class MyResourcesScreen extends StatefulWidget {
  @override
  _MyResourcesScreenState createState() => _MyResourcesScreenState();
}

class _MyResourcesScreenState extends State<MyResourcesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  /// **Opens borrow requests for the selected item**
  void _viewRequestsForItem(String itemId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BorrowRequestsForOwnerScreen(itemId: itemId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Resources')),
      body: userId == null
          ? Center(child: Text("User not logged in"))
          : StreamBuilder<List<DocumentSnapshot>>(
              stream: _databaseService.getMyResources(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("You have not added any resources"));
                }

                var items = snapshot.data!;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(item["name"]),
                        subtitle: Text(item["description"]),
                        trailing: Text(item["status"] ?? "Available"),
                        onTap: () => _viewRequestsForItem(items[index].id), // Opens borrow requests
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: "Add Resource",
      ),
    );
  }
}
