import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photos/themes/theme_data.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme;

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    if (_currentTheme == AppTheme.lightTheme) {
      _currentTheme = AppTheme.darkTheme;
    } else {
      _currentTheme = AppTheme.lightTheme;
    }
    notifyListeners();
  }

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
