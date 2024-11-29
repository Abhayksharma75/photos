import 'package:photo_manager/photo_manager.dart';

class Album {
  final String title;
  final List<AssetEntity> assets;
  final String artist;
  final int year;

  Album({
    required this.title,
    required this.assets,
    required this.artist,
    required this.year,
  });
}
