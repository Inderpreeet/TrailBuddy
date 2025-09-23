@'
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrailBuddyApp());
}

class TrailBuddyApp extends StatelessWidget {
  const TrailBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrailBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  LatLng _center = const LatLng(37.7749, -122.4194);
  double _zoom = 13;
  bool _locating = false;
  LatLng? _myLocation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      _locating = true;
      _errorMessage = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locating = false;
          _errorMessage = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locating = false;
          _errorMessage = 'Location permission denied.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _myLocation = here;
        _center = here;
        _zoom = 15;
        _locating = false;
        _errorMessage = null;
      });
      // Only move the map if it's ready
      if (_mapController.ready) {
        _mapController.move(here, 15);
      }
    } catch (e) {
      setState(() {
        _locating = false;
        _errorMessage = 'Failed to get location.';
      });
    }
  }

  void _recenter() {
    final target = _myLocation ?? _center;
    if (_mapController.ready) {
      _mapController.move(target, _zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrailBuddy')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              interactionOptions: const InteractionOptions(
                flags: ~InteractiveFlag.rotate,
              ),
              onPositionChanged: (pos, hasGesture) {
                setState(() {
                  _center = pos.center ?? _center;
                  _zoom = pos.zoom ?? _zoom;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.trailbuddy',
              ),
              if (_myLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myLocation!,
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(Icons.my_location, size: 28, color: Colors.blue),
                    ),
                  ],
                ),
            ],
          ),
          if (_locating)
            const Positioned(
              left: 16,
              bottom: 100,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Getting location…'),
                    ],
                  ),
                ),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              left: 16,
              bottom: 60,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'locate',
            tooltip: 'My location',
            onPressed: _initLocation,
            child: const Icon(Icons.gps_fixed),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'recenter',
            tooltip: 'Recenter',
            onPressed: _recenter,
            child: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
    );
  }
}
'@ | Set-Content -Encoding UTF8 .\lib\main.dart


