// lib/screens/reports_list_page.dart
import 'dart:io';
import 'package:flutter/material.dart';

import '../models/trail_report.dart';
import 'package:trailbuddy/services/report_storage.dart';




class ReportsListPage extends StatefulWidget {
  const ReportsListPage({super.key});

  @override
  State<ReportsListPage> createState() => _ReportsListPageState();
}

class _ReportsListPageState extends State<ReportsListPage> {
  final _storage = ReportStorage();

  bool _loading = true;
  List<TrailReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _storage.readAll();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
      setState(() => _reports = items);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load reports')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _storage.deleteById(id); // make sure this exists (see below)
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete')),
      );
    }
  }

  void _showPhoto(String path) {
    if (path.isEmpty || !File(path).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo not found on disk')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _reports.isEmpty
            ? const Center(child: Text('No saved reports yet'))
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: _reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final r = _reports[i];
                    final ts = r.createdAt.toLocal().toString().split('.').first;
                    final coord =
                        '(${r.latitude.toStringAsFixed(5)}, ${r.longitude.toStringAsFixed(5)})';

                    return Card(
                      child: ListTile(
                        title: Text(r.condition),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ts),
                            Text(coord, style: const TextStyle(fontSize: 12)),
                            if (r.notes != null && r.notes!.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(r.notes!),
                              ),
                          ],
                        ),
                        leading: r.photoPath != null
                            ? IconButton(
                                tooltip: 'View photo',
                                onPressed: () => _showPhoto(r.photoPath!),
                                icon: const Icon(Icons.photo),
                              )
                            : const Icon(Icons.note),
                        trailing: IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(r.id),
                        ),
                      ),
                    );
                  },
                ),
              );

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Reports')),
      body: body,
    );
  }
}
