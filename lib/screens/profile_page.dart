// lib/screens/profile_page.dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _avatarPath;
  bool _loading = true;
  bool _saving = false;

  // ---- Storage helpers ------------------------------------------------------

  Future<File> _profileFile() async {
    final dir = await getApplicationSupportDirectory();
    final f = File('${dir.path}/profile.json');
    if (!(await f.exists())) {
      await f.create(recursive: true);
      await f.writeAsString(jsonEncode({
        'name': '',
        'email': '',
        'avatarPath': null,
      }));
    }
    return f;
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final f = await _profileFile();
      final raw = await f.readAsString();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _nameCtrl.text = (map['name'] ?? '') as String;
      _emailCtrl.text = (map['email'] ?? '') as String;
      _avatarPath = map['avatarPath'] as String?;
    } catch (_) {
      // start with empty values if anything fails
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final f = await _profileFile();
      await f.writeAsString(jsonEncode({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'avatarPath': _avatarPath,
      }));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save profile')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---- UI helpers -----------------------------------------------------------

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path != null && path.isNotEmpty) {
      setState(() => _avatarPath = path);
    }
  }

  void _clearAvatar() {
    setState(() => _avatarPath = null);
  }

  // ---- Lifecycle ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ---- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // FIX: Do NOT make this const, because AppBar is not const.
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final avatar = _avatarPath != null && File(_avatarPath!).existsSync()
        ? CircleAvatar(
            radius: 44,
            backgroundImage: FileImage(File(_avatarPath!)),
          )
        : const CircleAvatar(
            radius: 44,
            child: Icon(Icons.person, size: 44),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  avatar,
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickAvatar,
                        icon: const Icon(Icons.photo),
                        label: const Text('Choose Photo'),
                      ),
                      if (_avatarPath != null)
                        TextButton.icon(
                          onPressed: _clearAvatar,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return null;
                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
                return ok ? null : 'Enter a valid email';
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _saveProfile,
              icon: _saving
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Save'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About TrailBuddy'),
              subtitle: Text(
                'TrailBuddy helps hikers view maps, center on their location, and '
                'report trail conditions. Data is stored locally on this device.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}



