import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/plan/presentation/plan_screen.dart'; // PlanPage
import '../features/grade/presentation/grade_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0; // start on ViaChat

  final List<Widget> _pages = [
    const ViaHomePage(), // index 0
    const ChatScreen(),  // index 1
    const PlanPage(),     // index 2
    const ViaGradePage(),
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
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ViaHome',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'ViaChat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'ViaPlan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'ViaGrade',
          ),
        ],
      ),
    );
  }
}
