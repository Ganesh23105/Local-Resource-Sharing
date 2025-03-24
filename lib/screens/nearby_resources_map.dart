import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_resource_sharing/screens/database_service.dart';

class NearbyResourcesMap extends StatefulWidget {
  @override
  _NearbyResourcesMapState createState() => _NearbyResourcesMapState();
}

class _NearbyResourcesMapState extends State<NearbyResourcesMap> {
  final DatabaseService _databaseService = DatabaseService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool isLoading = true;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _fetchNearbyResources();
  }

  /// **Fetch nearby resources & add markers**
  void _fetchNearbyResources() async {
    try {
      Position position = await _databaseService.getCurrentLocation();
      List<DocumentSnapshot> items = await _databaseService.getNearbyItems(
        position.latitude, position.longitude, 10,
      );

      Set<Marker> markers = {};
      for (var item in items) {
        var data = item.data() as Map<String, dynamic>;

        markers.add(
          Marker(
            markerId: MarkerId(item.id),
            position: LatLng(data["latitude"], data["longitude"]),
            infoWindow: InfoWindow(
              title: data["name"],
              snippet: data["description"],
            ),
          ),
        );
      }

      setState(() {
        _markers = markers;
        _userLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Resources")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
            ),
    );
  }
}
