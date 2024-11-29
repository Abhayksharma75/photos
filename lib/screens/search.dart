import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/components/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:photos/providers/ORTImageViewModel.dart';
import 'package:photos/providers/ORTTextViewModel.dart'; 
import 'package:photos/providers/SearchViewModel.dart';
import 'package:photos/adapter/ImageAdapter.dart';
import 'dart:typed_data';
import 'dart:developer' as developer;

class SearchScreen extends StatefulWidget {
  final TextEditingController searchTextController;

  const SearchScreen({Key? key, required this.searchTextController}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool search = false;

  @override
  void initState() {
    super.initState();
    widget.searchTextController.clear(); 
  }


  @override
  void dispose() {
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 0, 15, 3),
      child: Column(
          children: [
            SearchBarWidget(
              onTextSearch: (searchText) async {
                if (searchText.isNotEmpty) {
                  // List<double> textEmbeddingList = await context.read<ORTTextViewModel>().getTextEmbedding(searchText);
                  // Float32List textEmbedding = Float32List.fromList(textEmbeddingList);
                  // context.read<SearchViewModel>().sortByCosineDistance(
                  //   textEmbedding, context.read<ORTImageViewModel>().embeddingsList, context.read<ORTImageViewModel>().idxList
                  // );
                  search = true;
                  setState(() {});
                } else {
                  search = false; // Show the message when search text is cleared
                  setState(() {});
                }
              },
              reset: () {
                print("textEmbeddingList");
                widget.searchTextController.clear();
                context.read<SearchViewModel>().searchResults.clear();
                search = false; // Reset search to false to show the message
                setState(() {});
              },
              textController: widget.searchTextController,
            ),
            Expanded(
              child: search == true?
              
              context.read<SearchViewModel>().searchResults.isEmpty
                  ? Center(child: Text('No images found'))
                  : GridView.builder(
                      itemCount: context.read<SearchViewModel>().searchResults.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        final imageId = context.read<SearchViewModel>().searchResults[index];
                        search = false;
                        developer.log('Building ImageAdapter for imageId: $imageId');
                        // Collect all assets for the ImageAdapter
                        final allAssetsFuture = Future.wait(
                            context.read<SearchViewModel>().searchResults
                                .map((id) => AssetEntity.fromId(id.toString()))
                        );
      
                        return FutureBuilder<List<AssetEntity>>(
                          future: allAssetsFuture.then((assets) => assets.whereType<AssetEntity>().toList()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error loading images'));
                            } else if (snapshot.hasData) {
                              return ImageAdapter(asset: snapshot.data![index], assets: snapshot.data!);
                            }
                            return Center(child: Text('No images found'));
                          },
                        );
                      },
                    ):
                    Center(
                      child: Text("Search for photos by entering text \n         in the search bar above.", style: TextStyle(fontSize: 15),),
                    )
      
            ),
          ],
        ),
    );
    
  }
}
