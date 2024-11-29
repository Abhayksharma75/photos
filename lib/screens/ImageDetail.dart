import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photos/providers/ORTImageViewModel.dart';
import 'package:photos/providers/SearchViewModel.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/service/imageservice.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'dart:typed_data'; // Import the typed data library
import 'package:photos/adapter/ImageAdapter.dart';

class ImageDetail extends StatefulWidget {
  final List<Future<File?>> imageFiles;
  int initialIndex;
  final bool showOverlay;
  final AssetEntity asset;

  ImageDetail(
      {Key? key,
      required this.imageFiles,
      required this.initialIndex, 
      required this.asset,
      this.showOverlay = false})
      : super(key: key);

  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  late bool _showOverlay;
  bool search =
      false; //// Mark as late to indicate it will be initialized later

  @override
  void initState() {
    super.initState();
    _showOverlay = widget.showOverlay; // Initialize with the widget's value
  }

  void _toggleOverlay(BuildContext context) {
    setState(() {
      _showOverlay = !_showOverlay; // Toggle the local state variable
    });
  }

  void _deleteFile(int index) async {
    try {
      // Get the file from the imageFiles list
      final file = await widget.imageFiles[index];
      if (file != null) {
        // Request permission to access the photo library
        final result = await PhotoManager.requestPermissionExtend();
        if (result.isAuth) {
          final assetList =
              await PhotoManager.getAssetPathList(type: RequestType.image);
          if (index < assetList.length) {
            // Check if index is within bounds
            final asset = await AssetEntity.fromId(
                assetList[index].id); // Get the asset entity
              
            if (asset != null) {
              // Check if asset is not null
            
              final success = await PhotoManager.editor.deleteWithIds(
                  [asset.id]); // Use the delete method on the asset entity
              if (success == true) {
                // Ensure the condition checks for a boolean
                setState(() {
                  // Update the imageFiles list to remove the deleted file
                  widget.imageFiles.removeAt(index);
                });
              } else {
                print("Failed to delete the photo.");
              }
            } else {
              print(
                  "Failed to get asset entity for ID: ${assetList[index].id}"); // Log the asset ID
            }
          } else {
            print("Index out of bounds for assetList.");
          }
        } else {
          print("Permission denied to access photos.");
        }
      } else {
        print("File does not exist at the specified path.");
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

  Future<void> initializeSearchResults() async {
    // final searchViewModel = context.read<SearchViewModel>();
    // final ortImageViewModel = context.read<ORTImageViewModel>();
    // // Wait for the ORTImageViewModel to initialize if necessary
    // if (ortImageViewModel.idxList.isEmpty) {
    //   ImageService.showDirectorySelectionPopup(context);
    // }
    // if (searchViewModel.searchResults.isEmpty) {
    //   searchViewModel.searchResults =
    //       ortImageViewModel.idxList.reversed.toList();
    //   developer.log(
    //       'Initial search results: ${searchViewModel.searchResults.length}');
    // }
    // int index = ortImageViewModel.idxList.indexOf(int.parse(widget.asset.id)); // Convert to int
    // print(ortImageViewModel.idxList);
    // print(index);
    // print(widget.asset.id);
    

    // final imageEmbedding = Float32List.fromList(ortImageViewModel
    //     .embeddingsList[index]); // Convert to Float32List
    // searchViewModel.sortByCosineDistance(imageEmbedding,
    //     ortImageViewModel.embeddingsList, ortImageViewModel.idxList);
    // search = true;
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<File?>>(
        future: Future.wait(widget.imageFiles.map((file) => file)),
        builder: (_, snapshot) {
          final files = snapshot.data;
          if (files == null || files.isEmpty) return Container();

          return GestureDetector(
            onTap: () {
              _toggleOverlay(context);
              SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ));
            },
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                    itemCount: files.length,
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: FileImage(files[index]!),
                        heroAttributes:
                            PhotoViewHeroAttributes(tag: files[index]!.path),
                      );
                    },
                    scrollPhysics: const BouncingScrollPhysics(),
                    backgroundDecoration: BoxDecoration(color: Colors.black),
                    pageController:
                        PageController(initialPage: widget.initialIndex),
                    onPageChanged: (index) {
                      widget.initialIndex = index;
                    }),

                // Overlay with IconButtons
                if (_showOverlay) // Use the local state variable
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            initializeSearchResults();
                            // Show a modal bottom sheet with reduced height
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true, // Allows full height
                              builder: (BuildContext context) {
                                return Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.9, // Set height to 90% of the screen height
                                  width: MediaQuery.of(context)
                                      .size
                                      .width, // Full width
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            20)), // Rounded corners at the top
                                  ),
                                  child: Column(
                                    children: [
                                      // Title for the modal
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Search Results',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // Add your search results or other content here
                                      Expanded(
                                          child: search == true
                                              ? context
                                                      .read<SearchViewModel>()
                                                      .searchResults
                                                      .isEmpty
                                                  ? Center(
                                                      child: Text(
                                                          'No images found'))
                                                  : GridView.builder(
                                                      itemCount: context
                                                          .read<
                                                              SearchViewModel>()
                                                          .searchResults
                                                          .length,
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount:
                                                                  2),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final imageId = context
                                                            .read<
                                                                SearchViewModel>()
                                                            .searchResults[index];
                                                        search = false;
                                                        developer.log(
                                                            'Building ImageAdapter for imageId: $imageId');
                                                        // Collect all assets for the ImageAdapter
                                                        final allAssetsFuture =
                                                            Future.wait(context
                                                                .read<
                                                                    SearchViewModel>()
                                                                .searchResults
                                                                .map((id) =>
                                                                    AssetEntity
                                                                        .fromId(
                                                                            id.toString())));

                                                        return FutureBuilder<
                                                            List<AssetEntity>>(
                                                          future: allAssetsFuture.then(
                                                              (assets) => assets
                                                                  .whereType<
                                                                      AssetEntity>()
                                                                  .toList()),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Center(
                                                                  child:
                                                                      CircularProgressIndicator());
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return Center(
                                                                  child: Text(
                                                                      'Error loading images'));
                                                            } else if (snapshot
                                                                .hasData) {
                                                              return ImageAdapter(
                                                                  asset: snapshot
                                                                          .data![
                                                                      index],
                                                                  assets: snapshot
                                                                      .data!);
                                                            }
                                                            return Center(
                                                                child: Text(
                                                                    'No images found'));
                                                          },
                                                        );
                                                      },
                                                    )
                                              : Center(
                                                  child:
                                                      Text("No Results found;"),
                                                ) // Placeholder for search results
                                          ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            // Call delete logic for the current index
                            _deleteFile(
                                widget.initialIndex); // Pass the current index
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.info, color: Colors.white),
                          onPressed: () async {
                            // Get the current file based on the index
                            final file =
                                await widget.imageFiles[widget.initialIndex];
                            if (file != null) {
                              // Get file metadata
                              final fileStat =
                                  await file.stat(); // Get file statistics
                              final creationDate =
                                  fileStat.changed; // Get the creation date
                              final fileSize =
                                  fileStat.size; // Get the file size

                              // Format the creation date and ti\

                              String formattedDate =
                                  "${creationDate.toLocal()}".split(' ')[0];
                              String formattedTime =
                                  "${creationDate.hour % 12}:${creationDate.minute.toString().padLeft(2, '0')} ${creationDate.hour >= 12 ? 'PM' : 'AM'}";

                              // Convert file size to KB/MB/GB
                              String formattedSize;
                              if (fileSize >= 1073741824) {
                                formattedSize =
                                    "${(fileSize / 1073741824).toStringAsFixed(2)} GB";
                              } else if (fileSize >= 1048576) {
                                formattedSize =
                                    "${(fileSize / 1048576).toStringAsFixed(2)} MB";
                              } else if (fileSize >= 1024) {
                                formattedSize =
                                    "${(fileSize / 1024).toStringAsFixed(2)} KB";
                              } else {
                                formattedSize = "$fileSize bytes";
                              }

                              // Determine the source of the image
                              String source = file.path.contains('WhatsApp')
                                  ? 'WhatsApp Photo'
                                  : 'Camera Photo';

                              // Show metadata in a bottom sheet
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled:
                                    false, // Set to false to wrap content
                                backgroundColor: Colors.black87,
                                builder: (BuildContext context) {
                                  return Container(
                                    padding: EdgeInsets.all(16.0),
                                    width: double.infinity, // Full width
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Wrap content height
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Close icon
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            icon: Icon(Icons.close,
                                                color: Colors.white),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the bottom sheet
                                            },
                                          ),
                                        ),
                                        // Title
                                        Text("Image Details",
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        SizedBox(height: 20),
                                        // Metadata display
                                        Text("Date: $formattedDate",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        Text("Time: $formattedTime",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        Text("Size: $formattedSize",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        Text("Path: ${file.path}",
                                            style: TextStyle(
                                                color: Colors
                                                    .white)), // Show the file path
                                        Text("Source: $source",
                                            style: TextStyle(
                                                color: Colors
                                                    .white)), // Show the source
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              print(
                                  "File does not exist at the specified path.");
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                // New overlay for going back
                if (_showOverlay) // Use the local state variable
                  Positioned(
                    top: 40, // Position it at the top
                    left: 10,
                    child: IconButton(
                      icon:
                          Icon(Icons.keyboard_arrow_left, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Go back
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
