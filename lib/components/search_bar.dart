import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onTextSearch;
  final VoidCallback reset;
  final TextEditingController textController;

  const SearchBarWidget({
    Key? key,
    required this.onTextSearch,
    required this.reset,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    return Container(
      height :45,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Use surface color for better contrast
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 3, 3, 3),
        child: Row(
          children: [
            Expanded( 
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Search images by text...',
          
                  hintStyle: TextStyle(color: Color(0xFF161616), fontWeight: FontWeight.w400, fontSize: 15), // Adjust hint text color
                  border: InputBorder.none,
                ),
                onChanged: onTextSearch,
              ),
            ),
            // Search button
            IconButton(
              icon: Icon(Icons.search, color: theme.iconTheme.color, size: 20,), // Use theme icon color
              onPressed: () {
                // Trigger the text search when the search button is pressed
                onTextSearch(textController.text);
                FocusScope.of(context).unfocus();
              },
              tooltip: 'Search',
            ),
            // Recycle button (clear)
            IconButton(
              icon: Icon(Icons.clear, color: theme.iconTheme.color, size: 20,), // Use theme icon color
              onPressed: () {
                reset();
                FocusScope.of(context).unfocus();
              },
              tooltip: 'Clear',
            ),
          ],
        ),
      ),
    );
  }
}
