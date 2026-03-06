import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/creator/api/creator_api.dart';
import 'package:happer_app/creator/model/creator_model.dart';
import 'package:happer_app/creator/ui/selfie_details_screen.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikedImagesScreen extends StatefulWidget {
  @override
  _LikedImagesScreenState createState() => _LikedImagesScreenState();
}

class _LikedImagesScreenState extends State<LikedImagesScreen> {
  final ProfileApiService _profileApiService = ProfileApiService();
  List<dynamic> likedImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedImages();
  }

  Future<void> _fetchLikedImages() async {
    try {
      final List<dynamic> images = await _profileApiService.fetchLikedSelfies();
      setState(() {
        likedImages = images;
        isLoading = false;
      });
    } catch (e) {
  
      setState(() {
        isLoading = false;
      });
    }
  }

  // Add method to handle image tap and open details
  Future<void> _onImageTap(
    BuildContext context,
    Map<String, dynamic> selfieData,
  ) async {
    try {
      final String id = selfieData['_id'] ?? '';
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => SelfieDetailsScreen(selfieId: id),
        ),
      );
    } catch (e) {
   
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open image details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back),
        ),
        middle: const Text('Mes favoris'),
        border: Border(), // removes bottom border
      ),
      child: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: GridView.builder(
                    itemCount: likedImages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemBuilder: (context, index) {
                      final selfieData =
                          likedImages[index] as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () => _onImageTap(context, selfieData),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  selfieData['picture'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey[300]),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () async {
                                  final id = selfieData['_id'] ?? '';
                                  final isLiked = selfieData['isLikedByMe'] ?? true;
                                  final prefs = await SharedPreferences.getInstance();
                                  final token = prefs.getString('token') ?? '';
                                  final service = CreatorApiService(token: token);
                                  try {
                                    if (isLiked) {
                                      await service.dislikeSelfie(id);
                                    } else {
                                      await service.likeSelfie(id);
                                    }
                                    // Refresh the grid
                                    _fetchLikedImages();
                                  } catch (e) {
                              
                                  }
                                },
                                child: Icon(
                                  CupertinoIcons.heart_solid,
                                  color: (selfieData['isLikedByMe'] ?? true)
                                      ? Colors.redAccent
                                      : Colors.grey,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
