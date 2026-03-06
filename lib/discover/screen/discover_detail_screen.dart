import 'package:flutter/material.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/creator/api/creator_api.dart';
import 'package:happer_app/discover/api/discover_api.dart';
import 'package:happer_app/discover/model/discover_model.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import 'package:happer_app/profile/ui/image_grid_screen.dart';
import 'package:happer_app/webservices/profile_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class DiscoverDetailScreen extends StatefulWidget {
  final DiscoverModel selfieModel;
  final bool isFromMyImages;

  const DiscoverDetailScreen({
    Key? key,
    required this.selfieModel,
    required this.isFromMyImages,
  }) : super(key: key);

  @override
  _DiscoverDetailScreenState createState() => _DiscoverDetailScreenState();
}

class _DiscoverDetailScreenState extends State<DiscoverDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isLiked = false;
  bool _isLoadingDetails = true;
  Map<String, dynamic>? _detailedSelfieData;
  int _likeCount = 0;
  bool _showHeart = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.selfieModel.isLikedByMe;
    _likeCount = widget.selfieModel.nbLike;

    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heartAnimationController);

    _heartOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_heartAnimationController);

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });

    _fetchSelfieDetails();
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (AppManager.isLoginAsGuest) return;

    setState(() => _showHeart = true);
    _heartAnimationController.forward(from: 0.0);

    if (!_isLiked) {
      _toggleLike();
    }
  }

  Future<void> _fetchSelfieDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        setState(() => _isLoadingDetails = false);
        return;
      }

      final discoverApiService = DiscoverApiService(token: token);
      final detailedData = await discoverApiService.fetchDiscoverSelfieDetails(
        widget.selfieModel.id,
      );

      setState(() {
        _detailedSelfieData = detailedData;
        _isLoadingDetails = false;
      });
    } catch (e) {
      setState(() => _isLoadingDetails = false);
    }
  }

  Future<void> _toggleLike() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error. Please log in again.')),
        );
        return;
      }

      final creatorApiService = CreatorApiService(token: token);

      if (_isLiked) {
        await creatorApiService.dislikeSelfie(widget.selfieModel.id);
      } else {
        await creatorApiService.likeSelfie(widget.selfieModel.id);
      }

      setState(() {
        _isLiked = !_isLiked;
        _likeCount =
            _isLiked ? _likeCount + 1 : (_likeCount > 0 ? _likeCount - 1 : 0);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLiked ? 'Added to favorites' : 'Removed from favorites',
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite status')),
      );
    }
  }

  // String _formatTimeDifference(String dateString) {
  //   try {
  //     final createdTime = DateTime.parse(dateString);
  //     final currentTime = DateTime.now();
  //     final difference = currentTime.difference(createdTime);

  //     if (difference.inMinutes < 1) return 'À l’instant';
  //     if (difference.inMinutes < 60) return '${difference.inMinutes} min il y a';
  //     if (difference.inHours < 24) return '${difference.inHours} hours il y a';
  //     if (difference.inDays < 7) return '${difference.inDays} jour il y a';
  //     if (difference.inDays < 30)
  //       return '${(difference.inDays / 7).floor()} semaine il y a';
  //     if (difference.inDays < 365)
  //       return '${(difference.inDays / 30).floor()} months il y a';
  //     return '${(difference.inDays / 365).floor()} years il y a';
  //   } catch (e) {
  //     return 'Unknown date';
  //   }
  // }


  String _formatTimeDifference(String dateString) {
  try {
    final createdTime = DateTime.parse(dateString);
    final difference = DateTime.now().difference(createdTime);

    if (difference.inMinutes < 1) {
      return "À l'instant";
    }

    if (difference.inMinutes < 60) {
      return "Il y a ${difference.inMinutes} min";
    }

    if (difference.inHours < 24) {
      return difference.inHours == 1
          ? "Il y a 1 heure"
          : "Il y a ${difference.inHours} heures";
    }

    if (difference.inDays < 7) {
      return difference.inDays == 1
          ? "Il y a 1 jour"
          : "Il y a ${difference.inDays} jours";
    }

    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1
          ? "Il y a 1 semaine"
          : "Il y a $weeks semaines";
    }

    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "Il y a $months mois";
    }

    final years = (difference.inDays / 365).floor();
    return years == 1
        ? "Il y a 1 an"
        : "Il y a $years ans";
  } catch (e) {
    return "Date inconnue";
  }
}


  void _shareContent() {
    final selfie = widget.selfieModel;
    final userName =
        selfie.user != null
            ? '${selfie.user!.firstName} ${selfie.user!.lastName}'.trim()
            : 'Unknown';
    final String shareText =
        'Check out this style by $userName on Happer! ${selfie.picture}';
    Share.share(shareText, subject: 'Shop the style on Happer');
  }

  Future<void> _deleteImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Image'),
            content: Text('Are you sure you want to delete this image?'),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.black)),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final profileApi = ProfileApiService();
      await profileApi.deleteImageAPI(widget.selfieModel.id);
      await _fetchMySelfies();

      // Pass a flag to indicate deletion and refresh the MyImagesScreen
      Navigator.pop(context, true); // Pass true to indicate deletion
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selfie = widget.selfieModel;
    final userName =
        selfie.user != null
            ? '${selfie.user!.firstName}'.trim()
            : 'Unknown';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          // 'Inspiration',
          'INSPIRATION',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.isFromMyImages)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteImage,
            ),
        ],
      ),
      body:
          _isLoadingDetails
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onDoubleTap: _onDoubleTap,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: PinchZoom(
                              maxScale: 4.0,
                              child: Image.network(
                                selfie.picture,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (selfie.user != null &&
                                      selfie.user!.id.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ImageGridScreen(
                                              userId: selfie.user!.id,
                                            ),
                                      ),
                                    );
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      selfie.user?.picture.isNotEmpty == true
                                          ? NetworkImage(selfie.user!.picture)
                                          : null,
                                  backgroundColor: Colors.grey.shade200,
                                  child:
                                      selfie.user?.picture.isEmpty == true
                                          ? Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (selfie.user != null &&
                                      selfie.user!.id.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageGridScreen(
                                          userId: selfie.user!.id,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 3.0,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black.withOpacity(0.5),
                            child: IconButton(
                              icon: Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _shareContent,
                            ),
                          ),
                        ),
                        if (_showHeart)
                          Positioned.fill(
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _heartAnimationController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _heartOpacityAnimation.value,
                                    child: Transform.scale(
                                      scale: _heartScaleAnimation.value,
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 100,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 20,
                                            color: Colors.black38,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTimeDifference(selfie.createdAt),
                                style: TextStyle(color: Colors.grey),
                              ),
                              if (!AppManager.isLoginAsGuest)
                                Row(
                                  children: [
                                    Text(
                                      '$_likeCount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    IconButton(
                                      icon: Icon(
                                        _isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _isLiked ? Colors.red : null,
                                        size: 20,
                                      ),
                                      onPressed:
                                          _isLoading ? null : _toggleLike,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Future<void> _fetchMySelfies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to refresh your images')),
        );
        return;
      }

      final creatorApiService = CreatorApiService(token: token);
      final selfies = await creatorApiService.fetchMySelfies();

      // Log the fetched selfies for debugging
      print('Fetched selfies: $selfies');

      setState(() {
        // Update the UI or state with the refreshed selfies
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to refresh images')));
    }
  }
}
