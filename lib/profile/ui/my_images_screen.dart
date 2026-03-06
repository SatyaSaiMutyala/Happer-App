import 'package:flutter/material.dart';
import 'package:happer_app/creator/api/creator_api.dart';
import 'package:happer_app/discover/screen/discover_detail_screen.dart';
import 'package:happer_app/discover/model/discover_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyImagesScreen extends StatefulWidget {
  const MyImagesScreen({Key? key}) : super(key: key);

  @override
  _MyImagesScreenState createState() => _MyImagesScreenState();
}

class _MyImagesScreenState extends State<MyImagesScreen> {
  bool _isLoading = true;
  List<dynamic> _selfies = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMySelfies();
  }

  Future<void> _fetchMySelfies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please log in to view your images';
        });
        return;
      }

      final creatorApiService = CreatorApiService(token: token);
      final selfies = await creatorApiService.fetchMySelfies();
      
      setState(() {
        _selfies = selfies;
        _isLoading = false;
      });
    } catch (e) {
  
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load images';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'MES LOOKS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _selfies.isEmpty
                  ? const Center(child: Text('No images found'))
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: _selfies.length,
                        itemBuilder: (context, index) {
                          final selfie = _selfies[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to detail screen when image is tapped
                              try {
                                // Create a DiscoverModel from the selfie data
                                final discoverModel = DiscoverModel.fromJson(selfie);
                               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DiscoverDetailScreen(
      selfieModel: discoverModel,
      isFromMyImages: true,
    ),
  ),
).then((isDeleted) {
  if (isDeleted == true) {
    _fetchMySelfies(); // Refresh data if an image was deleted
  }
});
                              } catch (e) {
                            
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open image details')),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                selfie['picture'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image, color: Colors.white),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}