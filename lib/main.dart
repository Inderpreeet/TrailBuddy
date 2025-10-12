import 'package:flutter/material.dart';

import 'package:trailbuddy/screens/map_page.dart';
import 'package:trailbuddy/screens/report_page.dart';
import 'package:trailbuddy/screens/profile_page.dart';
import 'package:trailbuddy/screens/settings_screen.dart'; // <-- add this

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrailBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      routes: {
        // Settings route used by the gear icon on the Map page
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Let each page manage its own Scaffold/AppBar.
  static const List<Widget> _pages = <Widget>[
    MapPage(),
    ReportPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⬇️ No AppBar here (prevents double headers)
      body: SafeArea(
        // Keep state of each tab alive while switching
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
