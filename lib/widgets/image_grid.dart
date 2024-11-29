import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';

class ImageGrid extends StatelessWidget {
  final Map<DateTime, List<AssetEntity>> groupedAssets;
  final Function(AssetEntity) onLongPress; // Callback for long press
  final Set<AssetEntity> selectedImages;

  const ImageGrid({super.key, required this.groupedAssets,required this.onLongPress,
    required this.selectedImages,});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groupedAssets.length,
      itemBuilder: (context, index) {
        final date = groupedAssets.keys.elementAt(index);
        final assets = groupedAssets[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8,2, 8),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(date),
                    style:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  SizedBox(
                    height: 2,
                    child: Checkbox(value: false, onChanged: (value) {
                      
                    },),
                  )
                ],
              ),
            ),
            GridView.builder(
              padding: EdgeInsets.only(left: 2, right: 2),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: assets.length,
              itemBuilder: (context, assetIndex) {
                AssetEntity asset = assets[assetIndex];
                return FutureBuilder<Uint8List?>(
                  future: asset.thumbnailData.then((value) => value!),
                  builder: (context, snapshot) {
                    final bytes = snapshot.data;
                    if (bytes == null) return const CircularProgressIndicator();
                    return InkWell(
                      onLongPress: () {
                        onLongPress(asset);
                      },
                      onTap: () async {
                        if (selectedImages.isNotEmpty) {
                          onLongPress(asset);
                        }
                        // Collect all image files for the gallery
                        else{
                        if (asset.type == AssetType.video) {
                          // Navigate to VideoView using GoRouter
                          GoRouter.of(context).push(
                            '/videoView', // Use the GoRouter path for video view
                            extra: asset.file, // Pass the video file
                          );
                        } else {
                          // Collect all image files for the gallery
                          List<Future<File?>> imageFiles = assets
                              .where((a) => a.type == AssetType.image)
                              .map((a) => a.file)
                              .toList();

                          // Get the index of the tapped asset
                          int selectedIndex = assetIndex; // Use the current assetIndex

                          GoRouter.of(context).push(
                            '/imageDetail', // Use the GoRouter path
                            extra: {
                              'imageFiles': imageFiles,
                              'initialIndex': selectedIndex,
                              'asset': asset,
                            },
                          );
                        }
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                            ),
                          ),
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
                          if (selectedImages.contains(asset))
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
