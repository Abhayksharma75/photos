import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Allows full height
              builder: (BuildContext context) {
                return Container(
                  height: MediaQuery.of(context).size.height, // Full height
                  width: MediaQuery.of(context).size.width, // Full width
                  color: Colors.white, // Background color
                  child: Center(child: Text('Full Height and Width Modal')),
                );
              },
            );
          },
          child: Text('Show Modal'),
        ),
      ),
    );
  }
}
