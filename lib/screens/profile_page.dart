import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is where you'll build your actual profile UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('This is your actual Profile UI!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

