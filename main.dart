import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Add this
import 'package:url_launcher/url_launcher.dart'; // For calling numbers

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace these values with your actual Web Config from the Firebase Console
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "  ", // Your API Key
      appId: " ", // Your Web App ID
      messagingSenderId: "328940932162",// Your messagingSenderId
      projectId: "ai-disaster-guard",
    ),
  );
  runApp(const DisasterApp());
}

class DisasterApp extends StatelessWidget {
  const DisasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to call emergency number
  void _callEmergency() async {
    final Uri url = Uri.parse('tel:112'); // Emergency Number
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Disaster Guard AI")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('status')
                  .doc('current')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("Checking status...");
                var data = snapshot.data!.data() as Map<String, dynamic>?;
                // Matches your screenshot field: 'alert_message'
                String msg = data?['alert_message'] ?? "System Active";
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              ),
              icon: const Icon(Icons.map),
              label: const Text("OPEN EMERGENCY MAP"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(250, 60),
              ),
            ),
            const SizedBox(height: 20),
            // EMERGENCY CALL BUTTON
            ElevatedButton.icon(
              onPressed: _callEmergency,
              icon: const Icon(Icons.phone),
              label: const Text("CALL EMERGENCY (112)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(250, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Gets user's GPS position
  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safehouses & My Location")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('safehouses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          // Create marker list
          List<Marker> allMarkers = [];

          // Add Safehouses from Firebase (Green)
          allMarkers.addAll(
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Marker(
                point: LatLng(data['lat'], data['lng']),
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              );
            }),
          );

          // Add User Location (Blue)
          if (_userLocation != null) {
            allMarkers.add(
              Marker(
                point: _userLocation!,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            );
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation ?? const LatLng(13.0827, 80.2707),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(markers: allMarkers),
            ],
          );
        },
      ),
    );
  }
}
