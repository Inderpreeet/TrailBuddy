import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(49.2827, -123.1207); // Vancouver
  LatLng? _myLatLng;
  double _zoom = 13.0;
  bool _locating = false;
  StreamSubscription<ServiceStatus>? _serviceSub;

  @override
  void initState() {
    super.initState();
    _serviceSub = Geolocator.getServiceStatusStream().listen((_) {});
    _recenterToMyLocation(silent: true);
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    super.dispose();
  }

  Future<void> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
  }

  Future<void> _recenterToMyLocation({bool silent = false}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      await _ensurePermission();
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _myLatLng = here;
        _center = here;
      });
      _mapController.move(here, _zoom);
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Centered on your location')),
        );
      }
    } catch (_) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (_myLatLng != null)
        Marker(
          point: _myLatLng!,
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, size: 32, color: Colors.blue),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('TrailBuddy Map')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _center,
          initialZoom: _zoom,
          onPositionChanged: (pos, _) => _zoom = pos.zoom ?? _zoom,
        ),
        children: [ // REMOVE 'const' HERE to use dynamic markers
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.trailbuddy',
          ),
          MarkerLayer(markers: markers), // Use the 'markers' list with your location
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recenterToMyLocation,
        icon: _locating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.my_location),
        label: const Text('My Location'),
      ),
    );
  }
}
