import 'dart:ffi' ;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/providers/SearchViewModel.dart';
import 'package:photos/service/imageservice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class IndexingScreen extends StatefulWidget {
  const IndexingScreen({Key? key}) : super(key: key);

  @override
  State<IndexingScreen> createState() => _IndexingScreenState();
}

class _IndexingScreenState extends State<IndexingScreen> {
  double progress = 0.0;
  late List<int> IdxList;
  late List<List<double>> embeddingsList;
  String statusText = 'Creating your album...';
  static const platform = MethodChannel('ort_image_channel');
  int currentPage = 0; // Track the current page of the carousel

  @override
  void initState() {
    super.initState();
    _startIndexing();
    _listenToProgressUpdates();
  }

  Future<void> _startIndexing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNewUser = prefs.getBool('isNewUser') ?? true;
    List<AssetPathEntity> selectedDirectories;

    if (isNewUser) {
      prefs.setBool('isNewUser', false);
      selectedDirectories =
          await ImageService.showDirectorySelectionPopup(context);
    } else {
      selectedDirectories = await ImageService.getSelectedDirectories();
    }

    List<String> directoryNames =
        selectedDirectories.map((e) => e.name).toList();

    setState(() {
      statusText = 'Creating your album...';
    });

    try {
      await platform
          .invokeMethod('generateIndex', {'directories': directoryNames});
    } on PlatformException catch (e) {
      print("Failed to generate index: '${e.message}'.");
    }
  }

  void _listenToProgressUpdates() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "progressUpdate") {
        double newProgress = call.arguments as double;

        setState(() {
          progress = newProgress;
        });

        if (progress >= 1.0) {
          final searchViewModel = context.read<SearchViewModel>();
          IdxList = (await platform.invokeMethod<List<dynamic>>('getIdxList'))
                  ?.map((e) => e as int)
                  .toList() ??
              [];
          embeddingsList = (await platform
                      .invokeMethod<List<dynamic>>('getEmbeddingsList'))
                  ?.map((e) =>
                      (e as List<dynamic>).map((val) => val as double).toList())
                  .toList() ??
              [];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('IdxList', jsonEncode(IdxList));
          await prefs.setString('embeddingsList', jsonEncode(embeddingsList));
          searchViewModel.searchResults = IdxList.reversed.toList();
          _navigateToNextScreen();
        }
      }
    });
  }

  void _navigateToNextScreen() {
    context.go('/main');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView(
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index; // Update the current page index
                      });
                    },
                    children: [
                      ClipRRect(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), child: ColoredBox(color: Color(0xFFD9D9D9))),
                      ClipRRect(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), child: ColoredBox(color: Color(0xFFD9D9D9))),
                     
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: SizedBox(
                      height: 25,
                      width: 75,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your button logic here
                        },
                        child: Text("Skip", style: TextStyle(fontSize: 12, color: Colors.white),),
                        style:ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFB16262)), side: WidgetStatePropertyAll(BorderSide(width: 0.0)), shape: WidgetStatePropertyAll<OutlinedBorder?>(RoundedRectangleBorder(borderRadius:BorderRadius.circular(15) ))) 
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(isActive: currentPage == 0),
                SizedBox(width: 8),
                _buildIndicator(isActive: currentPage == 1),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build a circle indicator
  Widget _buildIndicator({required bool isActive}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Color(0xFFB16262) : Colors.grey,
        border: Border.all(
          color: Color(0xFFB16262),
          width: 1,
        ),
      ),
    );
  }
}
