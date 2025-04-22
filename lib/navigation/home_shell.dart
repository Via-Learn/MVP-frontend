// home_shell.dart
import 'package:flutter/material.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/plan/presentation/plan_screen.dart';
import '../features/submit/presentation/submit_screen.dart';
import '../features/home/via_home.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 1; // Default to Chat tab

  // ❌ Remove `const` here to avoid runtime issues
  final List<Widget> _pages = [
    const PlanPage(),
    const ChatScreen(),
    const SubmitPage(),
    const ViaHomePage(), // ✅ Make sure this is declared properly
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'ViaPlan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ViaChat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'ViaSubmit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ViaHome',
          ),
        ],
      ),
    );
  }
}
