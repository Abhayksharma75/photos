import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/service/imageservice.dart';
import 'package:photos/widgets/image_grid.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  Map<DateTime, List<AssetEntity>> groupedAssets = {};
  bool _loading = true;
  Set<AssetEntity> _selectedImages = {};
  bool selectionMode = false;
  bool showBottomNavBar = true;
  TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImages();
  }


  Future<void> _loadImages() async {
  final images = await ImageService.getAssetsFromSelectedDirectories();
  final grouped = _groupImagesByDate(images);
  
  setState(() {
    groupedAssets = grouped;
    _loading = false; 
  });
}

Map<DateTime, List<AssetEntity>> _groupImagesByDate(List<AssetEntity> assets) {
  Map<DateTime, List<AssetEntity>> grouped = {};

  for (var asset in assets) {
    final creationDate = DateTime.fromMillisecondsSinceEpoch(asset.createDateTime.millisecondsSinceEpoch); 
    final date = DateTime(creationDate.year, creationDate.month, creationDate.day);
    if (!grouped.containsKey(date)) {
      grouped[date] = [];
    }
    grouped[date]!.add(asset);
  }
  return Map.fromEntries(grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
}


  Future<void> _refreshGallery() async {
    setState(() {
      _loading = true;
    });
    await ImageService.clearCache(); 
    await _loadImages(); 
  }

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

  void _handleSearch() {
    // TODO: Implement search functionality
  }

  void _handleDelete() {
    // TODO: Implement delete functionality
  }

  void _handleShare() {
    // TODO: Implement share functionality
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedImages.clear();
      selectionMode = false;
      showBottomNavBar = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return  RefreshIndicator(
        onRefresh: _refreshGallery,
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : groupedAssets.isEmpty
                ? Center(child: Text('No images found.'))
                : ImageGrid(groupedAssets: groupedAssets,
                onLongPress: _toggleImageSelection, // Pass the function
                    selectedImages: _selectedImages, ),
      );
    
  }
}
