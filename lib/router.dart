import 'package:go_router/go_router.dart';
import 'package:photos/screens/IndexingScreen.dart';
import 'package:photos/screens/splash.dart';
import 'package:photos/models/Album.dart';
import 'package:photos/screens/Collections.dart';
import 'package:photos/screens/ImageDetail.dart';
import 'package:photos/screens/VideoView.dart';
import 'package:photos/screens/main_screen.dart'; // Import MainScreen
import 'dart:io'; // Add this import
import 'package:photo_manager/photo_manager.dart';


final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/indexing',
      builder: (context, state) => const IndexingScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => MainScreen(), // Wrap HomeScreen in MainScreen
    ),
    GoRoute(
      path: '/imageDetail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?; // Cast to Map<String, dynamic>
        final imageFiles = (extra != null && extra['imageFiles'] != null) 
            ? (extra['imageFiles'] as List<dynamic>).map((file) => file as Future<File?>).toList().cast<Future<File?>>()
            : <Future<File?>>[]; // Provide a default value
        final initialIndex = (extra != null && extra['initialIndex'] != null) ? extra['initialIndex'] as int : 0; // Provide a default value
        final asset = (extra != null && extra['asset'] != null) ? extra['asset'] as AssetEntity : null; // Handle potential null

        return ImageDetail(
          imageFiles: imageFiles,
          initialIndex: initialIndex,
          asset: asset!, // Use null assertion operator
        );
      },
    ),
    GoRoute(
      path: '/videoView',
      builder: (context, state) {
        final videoFile = state.extra as Future<File?>;
        return VideoView(videoFile: videoFile);
      },
    ),
    GoRoute(
      path: '/albumDetail',
      builder: (context, state) {
        final album = state.extra as Album; // Ensure this is not null
        return AlbumDetailScreen(album: album); // Pass the album to AlbumDetailScreen
      },
    ),
  ],
);
