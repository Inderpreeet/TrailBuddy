// lib/screens/report_page.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../models/trail_report.dart';
import '../services/report_storage.dart';

import 'reports_list_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  final _storage = ReportStorage();

  // form state
  String? _condition; // required
  String? _photoPath;
  Position? _pos;
  bool _saving = false;

  final _conditions = const <String>[
    'Good',
    'Muddy',
    'Icy/Slippery',
    'Fallen tree',
    'Flooded',
    'Closure',
    'Wildlife',
    'Other',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _photoPath = result.files.single.path!);
    }
  }

  Future<void> _getLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied')),
        );
        return;
      }
      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _pos = p);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get location')),
      );
    }
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    // Require a location for a useful report
    if (_pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture your location first')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final report = TrailReport(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        latitude: _pos!.latitude,
        longitude: _pos!.longitude,
        condition: _condition!,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        photoPath: _photoPath,
      );

      await _storage.add(report);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report saved locally')),
      );

      // reset form
      setState(() {
        _condition = null;
        _photoPath = null;
        _pos = null;
      });
      _notesCtrl.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save report')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locText = _pos == null
        ? 'No location captured'
        : 'Lat: ${_pos!.latitude.toStringAsFixed(5)}, '
          'Lng: ${_pos!.longitude.toStringAsFixed(5)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Trail Condition'),
        actions: [
          IconButton(
            tooltip: 'Saved Reports',
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsListPage()),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _condition,
              items: _conditions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Please select a condition'
                  : null,
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g., Fallen tree near marker 12',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo),
                  label: const Text('Attach Photo'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _photoPath == null ? 'No photo selected' : _photoPath!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _getLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Capture Location'),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(locText)),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _saveReport,
              icon: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save Report'),
            ),
          ],
        ),
      ),
    );
  }
}

