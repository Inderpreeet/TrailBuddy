// lib/services/report_storage.dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/trail_report.dart';

class ReportStorage {
  static const _fileName = 'trail_reports.json';

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    final f = File('${dir.path}/$_fileName');
    if (!await f.exists()) {
      await f.create(recursive: true);
      await f.writeAsString('[]');
    }
    return f;
  }

  Future<List<TrailReport>> readAll() async {
    final f = await _file();
    final text = await f.readAsString();
    if (text.trim().isEmpty) return <TrailReport>[];
    return TrailReport.decodeList(text);
  }

  Future<void> writeAll(List<TrailReport> reports) async {
    final f = await _file();
    await f.writeAsString(TrailReport.encodeList(reports));
  }

  Future<void> add(TrailReport report) async {
    final all = await readAll();
    all.add(report);
    await writeAll(all);
  }

  Future<void> deleteById(String id) async {
    final all = await readAll();
    all.removeWhere((r) => r.id == id);
    await writeAll(all);
  }

  Future<void> clearAll() async {
    final f = await _file();
    await f.writeAsString('[]');
  }
}

