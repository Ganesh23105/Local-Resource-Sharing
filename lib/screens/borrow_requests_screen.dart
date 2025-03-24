import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_resource_sharing/screens/database_service.dart';

class BorrowRequestsScreen extends StatefulWidget {
  @override
  _BorrowRequestsScreenState createState() => _BorrowRequestsScreenState();
}

class _BorrowRequestsScreenState extends State<BorrowRequestsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  /// **Handles canceling a borrow request**
  void _cancelRequest(String requestId) async {
    await _databaseService.cancelBorrowRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Borrow request canceled!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Borrow Requests')),
      body: userId == null
          ? Center(child: Text("User not logged in"))
          : StreamBuilder<List<DocumentSnapshot>>(
              stream: _databaseService.getBorrowRequests(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No borrow requests found"));
                }

                var requests = snapshot.data!;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    var request = requests[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Item ID: ${request["itemId"]}"),
                        subtitle: Text("Status: ${request["status"]}"),
                        trailing: request["status"] == "Pending"
                            ? IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => _cancelRequest(requests[index].id),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
