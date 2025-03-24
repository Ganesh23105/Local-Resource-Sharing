import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_resource_sharing/screens/database_service.dart';

class ExploreResourcesScreen extends StatefulWidget {
  @override
  _ExploreResourcesScreenState createState() => _ExploreResourcesScreenState();
}

class _ExploreResourcesScreenState extends State<ExploreResourcesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String? userId;
  List<DocumentSnapshot> nearbyItems = [];
  Map<String, bool> requestedItems = {}; // Stores requested item IDs
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchNearbyResources();
    _fetchUserRequests();
  }

  /// **Fetch Nearby Resources (Excludes User's Own Items)**
  void _fetchNearbyResources() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position position = await _databaseService.getCurrentLocation();
      List<DocumentSnapshot> items = await _databaseService.getNearbyItems(
        position.latitude,
        position.longitude,
        10, // 10 km radius
      );

      // ✅ Remove user's own resources
      items = items.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data["ownerId"] != userId; // Exclude user's own items
      }).toList();

      setState(() {
        nearbyItems = items;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// **Fetch all items user has already requested**
  void _fetchUserRequests() async {
    if (userId == null) return;

    QuerySnapshot requests = await FirebaseFirestore.instance
        .collection("borrow_requests")
        .where("borrowerId", isEqualTo: userId)
        .get();

    setState(() {
      requestedItems = {
        for (var doc in requests.docs) doc["itemId"]: true,
      };
    });
  }

  /// **Handles borrow request (Prevents duplicate requests & self-requests)**
  void _requestToBorrow(String itemId, String ownerId) async {
    if (userId == null) return;

    // 🔒 Prevent user from requesting their own item
    if (userId == ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot request your own resource!')),
      );
      return;
    }

    // ✅ Check if a request already exists
    QuerySnapshot existingRequests = await FirebaseFirestore.instance
        .collection("borrow_requests")
        .where("itemId", isEqualTo: itemId)
        .where("borrowerId", isEqualTo: userId)
        .get();

    if (existingRequests.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already requested this item!')),
      );
      return;
    }

    // ✅ No existing request, proceed
    await FirebaseFirestore.instance.collection("borrow_requests").add({
      "itemId": itemId,
      "ownerId": ownerId,
      "borrowerId": userId,
      "status": "Pending",
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Borrow request sent!')),
    );

    setState(() {
      requestedItems[itemId] = true; // Mark as requested
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Resources')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : nearbyItems.isEmpty
              ? Center(child: Text("No resources found near you"))
              : ListView.builder(
                  itemCount: nearbyItems.length,
                  itemBuilder: (context, index) {
                    var item = nearbyItems[index].data() as Map<String, dynamic>;
                    bool alreadyRequested = requestedItems.containsKey(nearbyItems[index].id);
                    bool isOwner = item["ownerId"] == userId;

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(item["name"]),
                        subtitle: Text(item["description"]),
                        trailing: isOwner
                            ? null // ✅ Hide request button for own resources
                            : ElevatedButton(
                                onPressed: alreadyRequested
                                    ? null // Disable button if already requested
                                    : () => _requestToBorrow(nearbyItems[index].id, item["ownerId"]),
                                child: Text(alreadyRequested ? 'Requested' : 'Request'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: alreadyRequested ? Colors.grey : Colors.blue,
                                ),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
