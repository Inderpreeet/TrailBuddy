import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  String? _photoPath;
  bool _saving = false;
  Position? _pos;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null && result.files.single.path != null) {
      setState(() => _photoPath = result.files.single.path!);
    }
  }

  Future<void> _getLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services disabled')));
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location permission permanently denied')));
        return;
      }
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _pos = p);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get location')));
    }
  }

  Future<File> _reportsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/reports.json');
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final file = await _reportsFile();
      List<dynamic> items = [];
      if (await file.exists()) {
        final text = await file.readAsString();
        if (text.trim().isNotEmpty) items = jsonDecode(text) as List<dynamic>;
      }
      final id = const Uuid().v4();
      items.add({
        'id': id,
        'description': _descCtrl.text.trim(),
        'photoPath': _photoPath,
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': _pos?.latitude,
        'longitude': _pos?.longitude,
      });
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(items));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report saved locally')));
        _descCtrl.clear();
        setState(() {
          _photoPath = null;
          _pos = null;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save report')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locText = _pos == null
        ? 'No location captured'
        : 'Lat: ${_pos!.latitude.toStringAsFixed(5)}, Lng: ${_pos!.longitude.toStringAsFixed(5)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Report Trail Condition')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Fallen tree blocking path near marker 12',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
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
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Save Report'),
            ),
          ],
        ),
      ),
    );
  }
}
