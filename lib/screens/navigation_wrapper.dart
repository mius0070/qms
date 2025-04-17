import 'package:flutter/material.dart';
import 'package:qms/screens/home_screen.dart';
import 'package:qms/screens/display_screen.dart';
import 'package:qms/screens/admin_panel.dart';
import 'package:qms/screens/menu_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;

  static List<Widget> _screens = [
    MenuScreen(),
    const DisplayScreen(),
    const AdminPanel(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _selectedIndex == 3
              ? const HomeScreen() // When the MenuScreen is selected, show it separately
              : _screens[_selectedIndex], // Show the selected screen for navigation,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.display_settings),
            label: 'Display',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF077C68),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
