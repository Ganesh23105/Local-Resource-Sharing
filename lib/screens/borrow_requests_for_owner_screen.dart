import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_resource_sharing/screens/database_service.dart';

class BorrowRequestsForOwnerScreen extends StatefulWidget {
  final String itemId;
  BorrowRequestsForOwnerScreen({required this.itemId});

  @override
  _BorrowRequestsForOwnerScreenState createState() => _BorrowRequestsForOwnerScreenState();
}

class _BorrowRequestsForOwnerScreenState extends State<BorrowRequestsForOwnerScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String? userId;
  Map<String, dynamic>? itemDetails; // Store resource details

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchItemDetails();
  }

  /// **Fetch resource details**
  void _fetchItemDetails() async {
    DocumentSnapshot itemDoc = await FirebaseFirestore.instance.collection("items").doc(widget.itemId).get();
    if (itemDoc.exists) {
      setState(() {
        itemDetails = itemDoc.data() as Map<String, dynamic>;
      });
    }
  }

  /// **Delete resource and its borrow requests**
  void _deleteResource() async {
    await _databaseService.deleteResource(widget.itemId, userId!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resource deleted successfully!')),
    );
    Navigator.pop(context); // Go back after deleting
  }

  /// **Updates request status (Approve/Reject)**
  void _updateRequestStatus(String requestId, String newStatus) async {
    await FirebaseFirestore.instance.collection("borrow_requests").doc(requestId).update({
      "status": newStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request marked as $newStatus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Borrow Requests')),
      body: Column(
        children: [
          // **Show item details (Name, Description, Delete Button)**
          if (itemDetails != null)
            Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(itemDetails!["name"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(itemDetails!["description"]),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteResource, // Delete resource
                ),
              ),
            ),

          // **List of Borrow Requests**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("borrow_requests")
                  .where("itemId", isEqualTo: widget.itemId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No requests for this item"));
                }

                var requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    var request = requests[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Requested by: ${request["borrowerId"]}"),
                        subtitle: Text("Status: ${request["status"]}"),
                        trailing: request["status"] == "Pending"
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _updateRequestStatus(requests[index].id, "Approved"),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _updateRequestStatus(requests[index].id, "Rejected"),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
