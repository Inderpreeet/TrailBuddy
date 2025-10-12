import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Get the current position with best available accuracy.
  /// Throws an Exception with a clear message if unavailable/denied.
  Future<Position> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception('Location permission denied. Allow access in Settings.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  /// Nicely formatted coordinates + a Google Maps link.
  String coordsMessage(double lat, double lon) {
    final latStr = lat.toStringAsFixed(5);
    final lonStr = lon.toStringAsFixed(5);
    final mapUrl = 'https://maps.google.com/?q=$lat,$lon';
    return 'Lat: $latStr, Lon: $lonStr\n$mapUrl';
  }
}
