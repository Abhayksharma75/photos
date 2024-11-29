import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/models/Album.dart'; // Import the Album model
import 'package:photos/widgets/image_grid.dart'; // Import the ImageGrid widget
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class Collections extends StatefulWidget {
  const Collections({super.key});

  @override
  State<Collections> createState() => _CollectionsState();
}

class _CollectionsState extends State<Collections> {
  List<Album> albums = []; // List to hold albums

  @override
  void initState() {
    super.initState();
    _fetchAlbums(); // Fetch albums when the widget is initialized
  }

  Future<void> _fetchAlbums() async {
    // Fetch albums from the photo manager
    final List<AssetPathEntity> assetPaths =
        await PhotoManager.getAssetPathList(type: RequestType.image);
    for (var path in assetPaths) {
      final List<AssetEntity> assets = await path.getAssetListRange(
          start: 0, end: 100); // Limit to first 100 assets
      albums.add(Album(
          title: path.name,
          assets: assets,
          artist: 'Unknown Artist',
          year: DateTime.now().year)); // Now this works
    }
    setState(() {}); // Update the UI
  }

  @override
  Widget build(BuildContext context) {
    return albums.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              final firstAsset = album.assets.isNotEmpty
                  ? album.assets.first
                  : null; // Get the first asset for the cover

              return GestureDetector(
                onTap: () {
                  context.push('/albumDetail',
                      extra: album); // Use push to maintain the stack
                },
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.0),
                    image: firstAsset != null
                        ? DecorationImage(
                            image: AssetEntityImageProvider(
                                firstAsset), // Use the first asset as the cover
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black
                                  .withOpacity(0.5), // Apply a dark overlay
                              BlendMode.darken,
                            ),
                          )
                        : null,
                  ),
                  height: 200, // Set a fixed height for the container
                  child: Center(
                    child: Text(
                      album.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}

// Updated AlbumDetailScreen to use ImageGrid
class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({Key? key, required this.album}) : super(key: key);

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  Set<AssetEntity> _selectedImages = {};
  bool selectionMode = false;
  void _toggleImageSelection(AssetEntity asset) {
    setState(() {
      if (_selectedImages.contains(asset)) {
        _selectedImages.remove(asset);
      } else {
        _selectedImages.add(asset);
      }

      selectionMode = _selectedImages.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group assets by date for the ImageGrid
    Map<DateTime, List<AssetEntity>> groupedAssets = {};
    for (var asset in widget.album.assets) {
      final date = DateTime(asset.createDateTime.year,
          asset.createDateTime.month, asset.createDateTime.day);
      if (!groupedAssets.containsKey(date)) {
        groupedAssets[date] = [];
      }
      groupedAssets[date]!.add(asset);
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 25,
        bottom: PreferredSize(preferredSize: Size.fromHeight(8), child: Divider(indent: 14,endIndent: 14,)),
          leading: IconButton(
              onPressed: () {}, icon: Icon(Icons.keyboard_arrow_left)),
          title: Text(widget.album.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
      body: ImageGrid(
        groupedAssets: groupedAssets,
        onLongPress: _toggleImageSelection, // Pass the function
        selectedImages: _selectedImages,
      ), // Use the ImageGrid widget
    );
  }
}
