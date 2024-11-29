import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  // Fetch all assets (images) within selected directories and return media count

  static Future<int> getMediaCountFromDirectories(List<String> directories) async {
    int mediaCount = 0;

    // Fetch all asset paths first
    List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList(
      hasAll: false,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        imageOption: FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
      ),
    );

    // Count assets in each path that matches the directories
    for (var path in assetPaths) {
      if (directories.contains(path.name)) {
        // Get only image assets from the current path
        final List<AssetEntity> assets = await path.getAssetListRange(start: 0, end: await path.assetCountAsync);
        mediaCount += assets.where((asset) => asset.type == AssetType.image).length;
      }
    }

    // Update the media count in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mediaCount', mediaCount);

    return mediaCount;
  }

  // Select directories popup
  static Future<List<AssetPathEntity>> showDirectorySelectionPopup(BuildContext context) async {
    List<String> selectedDirectories = [];
    List<String> availableDirectories = ["Select All", "Camera", "WhatsApp Images", "Screenshot", "Download", "Documents"];

    // Fetch all asset paths first
    List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList(
      hasAll: false,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        imageOption: FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
      ),
    );

    // Show dialog for directory selection
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Directories'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableDirectories.map((dir) {
                  bool isSelected = selectedDirectories.contains(dir);

                  return CheckboxListTile(
                    title: Text(dir),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (dir == "Select All") {
                            selectedDirectories = [...availableDirectories];
                          } else {
                            selectedDirectories.add(dir);
                          }
                        } else {
                          if (dir == "Select All") {
                            selectedDirectories.clear();
                          } else {
                            selectedDirectories.remove(dir);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await saveSelectedDirectories(selectedDirectories);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    // Return selected directories
    List<AssetPathEntity> selectedPaths = [];
    for (var path in assetPaths) {
      if (selectedDirectories.contains(path.name)) {
        selectedPaths.add(path);
      }
    }
    return selectedPaths;
  }

  // Save selected directories in SharedPreferences
  static Future<void> saveSelectedDirectories(List<String> directories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedDirectories', directories);
  }

  // Fetch all assets in selected directories
  static Future<List<AssetEntity>> getAssetsFromSelectedDirectories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve selected directories from SharedPreferences; default to "Camera" if empty
    List<String> selectedDirectories = prefs.getStringList('selectedDirectories') ?? ["Camera"];

    // Fetch all asset paths
    List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList(
      hasAll: false,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
        videoOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
      ),
    );

    List<AssetEntity> allAssets = [];

    // Loop through each path and check if it matches any of the selected directories
    for (var path in assetPaths) {
      print(path.name);
      if (selectedDirectories.contains(path.name)) {
        // Fetch assets in the selected path
        final assets = await path.getAssetListRange(start: 0, end: 10000); // Adjust range if needed
        allAssets.addAll(assets);
      }
    }

    return allAssets;
  }

  /// Clears the cache directory
  static Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cachePath = cacheDir.path;

      final cacheFiles = Directory(cachePath).listSync();

      for (var file in cacheFiles) {
        if (file is File) {
          await file.delete();
        }
      }
      print('Cache cleared successfully.');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // New method to get selected directories
  static Future<List<AssetPathEntity>> getSelectedDirectories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve selected directories from SharedPreferences; default to "Camera" if empty
    List<String> selectedDirectories = prefs.getStringList('selectedDirectories') ?? ["Camera"];

    // Fetch all asset paths
    List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList(
      hasAll: false,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
        videoOption: const FilterOption(sizeConstraint: SizeConstraint(ignoreSize: true)),
      ),
    );

    // Return selected directories
    List<AssetPathEntity> selectedPaths = [];
    for (var path in assetPaths) {
      if (selectedDirectories.contains(path.name)) {
        selectedPaths.add(path);
      }
    }
    return selectedPaths;
  }
}