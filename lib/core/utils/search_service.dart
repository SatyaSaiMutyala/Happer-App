import 'package:flutter/material.dart';

/// A service class to handle search functionality across the app
class SearchService {
  /// Shows a search overlay that can be used from any screen
  static void showSearchOverlay(BuildContext context, {Function(String)? onSearch}) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Semi-transparent background
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              
              // Search popup at the top
              Positioned(
                top: 40.0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            // hintText: "Filter by creator...",
                            hintText: 'Filtrer par créateur...',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          onSubmitted: (query) {
                            // Close the search overlay
                            Navigator.pop(context);
                            
                            // Call the onSearch callback if provided
                            if (onSearch != null) {
                              onSearch(query);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}