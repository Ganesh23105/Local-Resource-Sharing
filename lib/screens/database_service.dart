import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// **Get the user's current location (latitude & longitude)**
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// **Adds a new item to Firestore with location (latitude, longitude)**
  Future<void> addItem(String name, String description, String category, String ownerId) async {
    try {
      Position position = await getCurrentLocation();
      await _db.collection("items").add({
        "name": name,
        "description": description,
        "category": category,
        "ownerId": ownerId,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": FieldValue.serverTimestamp(),
      });
      print("Item added successfully with location!");
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  /// **Fetches all items from Firestore in real-time**
  Stream<QuerySnapshot> getItems() {
    return _db.collection("items").orderBy("timestamp", descending: true).snapshots();
  }

  /// **Fetches all items EXCEPT those uploaded by the logged-in user**
  Stream<List<DocumentSnapshot>> getOtherUsersItems(String userId) {
    return _db.collection("items").snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data["ownerId"] != userId; // ✅ Filter in Flutter, NOT Firestore
      }).toList();
    });
  }

  /// **Fetches only the logged-in user's items**
  Stream<List<DocumentSnapshot>> getMyResources(String userId) {
    return _db.collection("items").snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data["ownerId"] == userId; // ✅ Only fetch items uploaded by user
      }).toList();
    });
  }

  /// **Fetches borrow requests made by the logged-in user**
  Stream<List<DocumentSnapshot>> getBorrowRequests(String userId) {
    return _db.collection("borrow_requests").orderBy("timestamp", descending: true).snapshots().map(
      (snapshot) => snapshot.docs.where((doc) => doc["borrowerId"] == userId).toList(),
    );
  }

  /// **Cancels a borrow request**
  Future<void> cancelBorrowRequest(String requestId) async {
    try {
      await _db.collection("borrow_requests").doc(requestId).delete();
      print("Borrow request canceled successfully!");
    } catch (e) {
      print("Error canceling borrow request: $e");
    }
  }

  /// **Fetches borrow requests for items owned by the logged-in user**
  Stream<List<DocumentSnapshot>> getBorrowRequestsForOwner(String ownerId) {
    return _db.collection("borrow_requests").orderBy("timestamp", descending: true).snapshots().map(
      (snapshot) => snapshot.docs.where((doc) => doc["ownerId"] == ownerId).toList(),
    );
  }

  /// **Updates the status of a borrow request (Approve/Reject)**
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _db.collection("borrow_requests").doc(requestId).update({"status": newStatus});
      print("Request status updated to $newStatus!");
    } catch (e) {
      print("Error updating request status: $e");
    }
  }

  /// **Deletes a resource only if the logged-in user is the owner**
  Future<void> deleteResource(String itemId, String ownerId) async {
    try {
      DocumentSnapshot itemDoc = await _db.collection("items").doc(itemId).get();

      // 🔒 Check if logged-in user is the owner
      if (itemDoc.exists && itemDoc["ownerId"] == ownerId) {
        await _db.collection("items").doc(itemId).delete();

        // Delete all borrow requests related to this item
        QuerySnapshot requests = await _db.collection("borrow_requests").where("itemId", isEqualTo: itemId).get();
        for (var doc in requests.docs) {
          await doc.reference.delete();
        }

        print("✅ Resource and all associated requests deleted successfully!");
      } else {
        print("❌ You are not authorized to delete this resource!");
      }
    } catch (e) {
      print("Error deleting resource: $e");
    }
  }

  /// **Calculate distance between two coordinates (Haversine Formula)**
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of Earth in km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  /// **Fetch nearby resources within a radius (e.g., 10 km)**
  Future<List<DocumentSnapshot>> getNearbyItems(double userLat, double userLon, double radiusKm) async {
    QuerySnapshot snapshot = await _db.collection("items").get();
    List<DocumentSnapshot> nearbyItems = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double itemLat = data["latitude"];
      double itemLon = data["longitude"];

      double distance = calculateDistance(userLat, userLon, itemLat, itemLon);
      if (distance <= radiusKm) {
        nearbyItems.add(doc);
      }
    }

    return nearbyItems;
  }
}
