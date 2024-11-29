import 'package:flutter/material.dart';
import 'package:photos/providers/theme_provider.dart';
import 'package:photos/router.dart';
import 'package:provider/provider.dart';
import 'package:photos/providers/ORTImageViewModel.dart';
import 'package:photos/providers/ORTTextViewModel.dart';
import 'package:photos/providers/SearchViewModel.dart';
import 'package:photo_manager/photo_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PhotoManager.clearFileCache();

  final PermissionState permissionStatus = await PhotoManager.requestPermissionExtend();
  if (!permissionStatus.isAuth) {
    final PermissionState newPermissionStatus = await PhotoManager.requestPermissionExtend();
    if (!newPermissionStatus.isAuth) {
      print('Permissions not granted after request');
      return; // Exit the app or handle as needed
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        // ChangeNotifierProvider(create: (_) => ORTImageViewModel()),
        // ChangeNotifierProvider(create: (_) => ORTTextViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerDelegate: router.routerDelegate,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
          debugShowCheckedModeBanner: false,
          title: 'photos',
          theme: themeProvider.currentTheme
        );
      },
    );
  }
}
