import 'package:flutter/material.dart';
import 'package:photos/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:photos/themes/theme_data.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    return AppBar(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
      title: Text('Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Themes') {
              // Navigate to the theme selection screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThemeSelectionScreen()),
              );
            } else {
              print(value); // Handle other actions (Settings, Refresh)
            }
          },
          itemBuilder: (BuildContext context) {
            List<PopupMenuEntry<String>> menuItems = [];
            const choices = ['Themes', 'Settings', 'Refresh'];

            for (int i = 0; i < choices.length; i++) {
              menuItems.add(
                PopupMenuItem<String>(
                  value: choices[i],
                  child: Text(
                    choices[i],
                    style: TextStyle(color:theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                  ),
                ),
              );

              if (i < choices.length - 1) {
                menuItems.add(const PopupMenuDivider(height: 3));
              }
            }

            return menuItems;
          },
          icon: Icon(Icons.person, size: 25,),
        ),
      ],
    );
  }
}

class ThemeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Debugging: Print the current theme
    print('Current Theme: ${themeProvider.currentTheme}');

    return Scaffold(
      body: Stack(
        children: [
          // Blurred background
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Content of the theme selection
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Select a Theme', style: TextStyle(fontSize: 24, color: Colors.white)),
                // Dropdown for default themes
                DropdownButton<ThemeData>(
                  value: themeProvider.currentTheme, // Ensure this is a valid theme
                  onChanged: (ThemeData? newTheme) {
                    if (newTheme != null) {
                      themeProvider.setTheme(newTheme); // Update the theme
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: AppTheme.defaultTheme1,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.defaultTheme1.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text('Default Theme', style: TextStyle(color: AppTheme.defaultTheme1.primaryColor))),
                      ),
                    ),
                    DropdownMenuItem(
                      value: AppTheme.defaultTheme2,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.defaultTheme2.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text('Background Image', style: TextStyle(color: AppTheme.defaultTheme2.primaryColor))),
                      ),
                    ),
                    DropdownMenuItem(
                      value: AppTheme.defaultTheme3,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.defaultTheme3.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text('Default', style: TextStyle(color: AppTheme.defaultTheme3.primaryColor))),
                      ),
                    ),
                    DropdownMenuItem(
                      value: AppTheme.gradientTheme,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text('Gradient', style: TextStyle(color: AppTheme.defaultTheme3.primaryColor))),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(onPressed: () {
                  themeProvider.setTheme(AppTheme.resetTheme); // Reset theme action
                }, child: Text('Reset Theme')),
                // Custom options
                Text('Custom Options', style: TextStyle(fontSize: 20, color: Colors.white)),
                ElevatedButton(onPressed: () {}, child: Text('Solid Color')),
                ElevatedButton(onPressed: () {}, child: Text('Gradient')),
                ElevatedButton(onPressed: () {}, child: Text('Image')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
