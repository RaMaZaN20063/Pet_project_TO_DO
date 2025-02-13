import 'package:flutter/material.dart';
import 'package:todo_app/account_screen.dart';
import 'package:todo_app/home_screen.dart';
import 'package:todo_app/progress.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
  ProgressPage(),
    AccountScreen()  
  ];


  void _onItemTapped(int index) {
    setState(() {
    _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar:BottomNavigationBar(
  backgroundColor: Theme.of(context).brightness == Brightness.dark
      ? Color(0xFF1d2630) 
      : Colors.white, 
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home'
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.timer),
      label: 'Focus'
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Account'
    )
  ]
)

    );
  }
}