import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:vialearn_flutter/features/submit/presentation/submit_screen.dart';
import '../core/constants/app_theme.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/plan/presentation/plan_screen.dart'; // PlanPage
import '../features/grade/presentation/grade_screen.dart';
import '../features/submit/application/lms_controller.dart';
import '../features/submit/application/submit_service.dart';
import '../features/submit/presentation/viasubmit_notice.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0; // start on ViaChat

  final List<Widget> _pages = [
  const ViaHomePage(),
  const ChatScreen(),
  const PlanPage(),
  const ViaGradePage(),
  const ViaSubmitNotice(),

  // ✅ Fix: delay provider access using Builder
  // Builder(
  //   builder: (context) => MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: (_) => SubmitController()),
  //       ChangeNotifierProvider(create: (_) => LMSController()),
  //     ],
  //     child: const SubmitPage(),
  //   ),
  // ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.send_rounded),
            label: 'ViaSubmit',
          ),
        ],
      ),
    );
  }
}
