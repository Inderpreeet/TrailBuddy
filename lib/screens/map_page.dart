import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// Safety feature imports (relative to /lib/screens/)
import '../services/safety_service.dart';
import '../services/location_service.dart';
import '../data/settings_repo.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // Default center (Vancouver) for first paint before we get a fix
  LatLng _center = const LatLng(49.2827, -123.1207);
  LatLng? _myLatLng;
  double _zoom = 13.0;
  bool _locating = false;
  StreamSubscription<ServiceStatus>? _serviceSub;

  late final SafetyService _safety;

  @override
  void initState() {
    super.initState();

    // wire safety service
    _safety = SafetyService(
      settings: SettingsRepo(),
      location: LocationService(),
    );

    // Listen to location service state changes (optional, placeholder)
    _serviceSub = Geolocator.getServiceStatusStream().listen((_) {});
    // Best-effort recenter on launch (no toast)
    _recenterToMyLocation(silent: true);
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    super.dispose();
  }

  Future<void> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
      }
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    // no throw here; Geolocator will throw on getCurrentPosition if still denied
  }

  Future<void> _recenterToMyLocation({bool silent = false}) async {
    if (_locating) return;
    setState(() => _locating = true);

    try {
      await _ensurePermission();

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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

  Future<void> _tryAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
      appBar: AppBar(
        title: const Text('TrailBuddy Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _zoom,
                onPositionChanged: (pos, _) {
                  _zoom = pos.zoom ?? _zoom;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.trailbuddy',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _tryAction(_safety.sendCheckIn),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Check-in'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _tryAction(_safety.sendHelp),
                    icon: const Icon(Icons.emergency_share),
                    label: const Text('Send Help'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recenterToMyLocation,
        icon: _locating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
        label: const Text('My Location'),
      ),
    );
  }
}


