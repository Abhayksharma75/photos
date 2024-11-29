import 'package:flutter/material.dart';
import 'package:photos/components/bottomnav.dart';
import 'package:photos/screens/home.dart';
import 'package:photos/screens/search.dart';
import 'package:photos/screens/Collections.dart';
import 'package:photos/components/appbar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Track the selected index
  final List<Widget> _screens = [
    const HomeScreen(),
    SearchScreen(searchTextController: TextEditingController()),
    const Collections(),
  ];
  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarWidget(),
      ),
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex, // Pass the selected index
        onItemTapped: _onItemTapped, // Pass the tap handler
      ),
    );
  }
}

        