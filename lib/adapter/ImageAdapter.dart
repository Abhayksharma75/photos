import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class ImageAdapter extends StatelessWidget {
  final AssetEntity asset;
  final List<AssetEntity> assets; // Holds the list of assets

  ImageAdapter({required this.asset, required this.assets}) {
    print('ImageAdapter created with asset id: ${asset.id}'); // Debug print
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData.then((value) => value!),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return const CircularProgressIndicator();
        return InkWell(
          onTap: () async {
            // Collect all image files for the gallery
            List<Future<File?>> imageFiles = assets
                .where((a) => a.type == AssetType.image)
                .map((a) => a.file)
                .toList();

            // Get the index of the tapped asset
            int selectedIndex = assets.indexOf(asset); // Find the index of the tapped asset

            context.go('/imageDetail', extra: {
              'imageFiles': imageFiles,
              'initialIndex': selectedIndex,
              'asset': asset,
            });
          },
          child: Stack(
            children: [
              // Wrap the image in a Positioned.fill to fill the space
              Positioned.fill(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                ),
              ),
              // Display a Play icon if the asset is a video
              if (asset.type == AssetType.video)
                Center(
                  child: Container(
                    color: Colors.blue,
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
