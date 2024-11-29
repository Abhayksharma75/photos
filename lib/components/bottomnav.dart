import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex; // Add selectedIndex
  final ValueChanged<int> onItemTapped; // Add callback for item taps

  const BottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: BottomNavigationBar(
        currentIndex: selectedIndex, // Use the selected index
        onTap: onItemTapped, // Use the callback
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo, size: 27),
            label: 'Photos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 27),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections, size: 27),
            label: 'Collections',
          ),
        ],
        selectedItemColor: Colors.black, // Set the color for the selected item
        unselectedItemColor: Colors.grey, // Set the color for unselected items
      ),
    );
  }
}
