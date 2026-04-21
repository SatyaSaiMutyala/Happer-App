import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/features/creator/api/creator_api.dart';
import 'package:happer_app/features/creator/models/creator_model.dart';
import 'package:happer_app/features/creator/screens/selfie_details_screen.dart';
import 'package:happer_app/features/profile/api/profile_api.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happer_app/l10n/app_localizations.dart';

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

  Future<void> _onImageTap(BuildContext context, Map<String, dynamic> selfieData) async {
    try {
      final String id = selfieData['_id'] ?? '';
      Navigator.push(context, CupertinoPageRoute(builder: (_) => SelfieDetailsScreen(selfieId: id)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open image details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).mesFavorisTitle),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : likedImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.black),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun favori pour le moment',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Les looks que vous aimez apparaîtront ici',
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: GridView.builder(
                    itemCount: likedImages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemBuilder: (context, index) {
                      final selfieData = likedImages[index] as Map<String, dynamic>;
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
                                    _fetchLikedImages();
                                  } catch (_) {
                                    // ignore like/dislike failure silently
                                  }
                                },
                                child: Icon(
                                  CupertinoIcons.heart_solid,
                                  color: (selfieData['isLikedByMe'] ?? true) ? Colors.redAccent : Colors.grey,
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
    );
  }
}
