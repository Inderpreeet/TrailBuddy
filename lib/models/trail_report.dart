// lib/models/trail_report.dart
import 'dart:convert';

class TrailReport {
  final String id;
  final DateTime createdAt;
  final double latitude;
  final double longitude;
  final String condition; // e.g. "Muddy", "Fallen tree", etc.
  final String? notes;
  final String? photoPath; // absolute file path

  TrailReport({
    required this.id,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.condition,
    this.notes,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'condition': condition,
        'notes': notes,
        'photoPath': photoPath,
      };

  factory TrailReport.fromJson(Map<String, dynamic> json) => TrailReport(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        condition: json['condition'] as String,
        notes: json['notes'] as String?,
        photoPath: json['photoPath'] as String?,
      );

  static String encodeList(List<TrailReport> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<TrailReport> decodeList(String source) {
    final raw = jsonDecode(source) as List;
    return raw
        .map((e) => TrailReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
