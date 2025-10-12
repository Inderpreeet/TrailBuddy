import 'package:flutter/material.dart';
import '../data/settings_repo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepo _repo = SettingsRepo();
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPhone() async {
    final phone = await _repo.getTrustedPhone();
    if (!mounted) return;
    setState(() {
      _controller.text = phone ?? '';
      _loading = false;
    });
  }

  Future<void> _savePhone() async {
    final phone = _controller.text.trim();
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a phone number')),
        );
      }
      return;
    }
    await _repo.setTrustedPhone(phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trusted contact saved')),
    );
  }

  Future<void> _clearPhone() async {
    await _repo.clearTrustedPhone();
    if (!mounted) return;
    setState(() => _controller.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trusted contact cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Note: NO `const` here because AppBar() isn't const.
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trusted Contact Number',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '+1 416 555 1234',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _savePhone,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _clearPhone,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Used when you tap Check-in or Send Help.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

