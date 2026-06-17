import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:happer_app/core/utils/deep_link_utils.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/constants/app_colors.dart';
import 'package:happer_app/core/constants/app_dimensions.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/discover/models/discover_model.dart';
import 'package:happer_app/features/profile/screens/image_grid_screen.dart';
import 'package:happer_app/features/selfies/bindings/selfie_binding.dart';
import 'package:happer_app/features/selfies/controllers/selfie_controller.dart';
import 'package:happer_app/features/selfies/data/models/selfie_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

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
  late final SelfieController _controller;
  bool _showHeart = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SelfieController>()) {
      SelfieBinding().dependencies();
    }
    _controller = Get.find<SelfieController>();
    _controller.fetchDetail(widget.selfieModel.id);

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
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _onDoubleTap(bool isLiked) {
    if (AppManager.isLoginAsGuest) return;
    setState(() => _showHeart = true);
    _heartAnimationController.forward(from: 0.0);
    if (!isLiked) {
      _controller.toggleLike(widget.selfieModel.id);
    }
  }

  Future<void> _deleteImage(AppLocalizations l) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteImageTitle),
        content: Text(l.deleteImageConfirm),
        actions: [
          TextButton(
            child: Text(l.cancel, style: const TextStyle(color: AppColors.textPrimary)),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary),
            child: Text(l.delete, style: const TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final success = await _controller.deleteSelfie(widget.selfieModel.id);
    if (!mounted) return;
    if (success) {
      showAppSnackBar('Image deleted successfully', isSuccess: true);
      Navigator.pop(context, true);
    }
  }

  String _formatTime(String dateString, AppLocalizations l) {
    try {
      final diff = DateTime.now().difference(DateTime.parse(dateString));
      if (diff.inMinutes < 1) return l.justNow;
      if (diff.inMinutes < 60) return l.minutesAgo(diff.inMinutes);
      if (diff.inHours < 24) return l.hoursAgo(diff.inHours);
      if (diff.inDays < 7) return l.daysAgo(diff.inDays);
      if (diff.inDays < 30) {
        final w = (diff.inDays / 7).floor();
        return w == 1 ? l.weekAgo(w) : l.weeksAgo(w);
      }
      if (diff.inDays < 365) return l.monthsAgo((diff.inDays / 30).floor());
      final y = (diff.inDays / 365).floor();
      return y == 1 ? l.yearAgo(y) : l.yearsAgo(y);
    } catch (_) {
      return '';
    }
  }

  Widget _buildAvatar(SelfieUser? user) {
    final picture = user?.picture;
    if (picture != null && picture.isNotEmpty) {
      return CircleAvatar(
        radius: AppDimensions.p20,
        backgroundImage: NetworkImage(picture),
        backgroundColor: Colors.grey.shade200,
      );
    }
    if (user != null) {
      return CircleAvatar(
        radius: AppDimensions.p20,
        backgroundColor: AppColors.textPrimary,
        child: Text(
          _initials(user),
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppDimensions.fontS,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    // Still loading or user data unavailable — show person placeholder
    return CircleAvatar(
      radius: AppDimensions.p20,
      backgroundColor: Colors.grey.shade300,
      child: Icon(Icons.person, color: Colors.grey.shade600, size: AppDimensions.p20),
    );
  }

  String _initials(SelfieUser? user) {
    if (user == null) return '?';
    final first = user.firstName?.isNotEmpty == true ? user.firstName![0] : '';
    final last = user.lastName?.isNotEmpty == true ? user.lastName![0] : '';
    if (first.isEmpty && last.isEmpty) {
      return (user.username?.isNotEmpty == true) ? user.username![0].toUpperCase() : '?';
    }
    return '$first$last'.toUpperCase();
  }

  void _navigateToProfile(String userId) {
    if (userId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ImageGridScreen(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(
        title: 'INSPIRATION',
        actions: [
          if (widget.isFromMyImages)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteImage(l),
            ),
        ],
      ),
      body: Obx(() {
        final isLoading = _controller.isDetailLoading.value;
        final selfie = _controller.detailSelfie.value;

        if (isLoading && selfie == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.textPrimary),
          );
        }

        // Fall back to initial data from DiscoverModel while loading
        final imageUrl = selfie?.primaryImage ?? widget.selfieModel.picture;
        final createdAt = selfie?.createdAt ?? widget.selfieModel.createdAt;
        final nbLike = selfie?.nbLike ?? widget.selfieModel.nbLike;
        final isLiked = selfie?.isLikedByMe ?? widget.selfieModel.isLikedByMe;
        // Only approved selfies can be liked (submitted ones return 404 on like endpoint)
        final canLike = selfie?.state == 'approved';
        final selfieUser = selfie?.user;
        final fallbackUser = widget.selfieModel.user;
        final userId = selfieUser?.id ?? fallbackUser?.id ?? '';
        final fallbackName = '${fallbackUser?.firstName ?? ''} ${fallbackUser?.lastName ?? ''}'.trim();
        final userName = selfieUser?.displayName.isNotEmpty == true
            ? selfieUser!.displayName
            : (selfieUser?.username ?? fallbackName);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: canLike ? () => _onDoubleTap(isLiked) : null,
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: PinchZoom(
                        maxScale: 4.0,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),

                    // User avatar + name
                    Positioned(
                      top: AppDimensions.p12,
                      left: AppDimensions.p12,
                      child: GestureDetector(
                        onTap: () => _navigateToProfile(userId),
                        child: Row(
                          children: [
                            _buildAvatar(selfieUser),
                            const SizedBox(width: AppDimensions.p8),
                            if (userName.isNotEmpty)
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppDimensions.fontL,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Share button
                    Positioned(
                      top: AppDimensions.p12,
                      right: AppDimensions.p12,
                      child: CircleAvatar(
                        radius: AppDimensions.p20,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white, size: 20),
                          onPressed: () => shareOutfit(
                            username: selfieUser?.username ??
                                fallbackUser?.username ?? '',
                            selfieId: widget.selfieModel.id,
                            creatorName: userName,
                          ),
                        ),
                      ),
                    ),

                    // Double-tap heart animation
                    if (_showHeart)
                      Positioned.fill(
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _heartAnimationController,
                            builder: (_, __) => Opacity(
                              opacity: _heartOpacityAnimation.value,
                              child: Transform.scale(
                                scale: _heartScaleAnimation.value,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 100,
                                  shadows: [Shadow(blurRadius: 20, color: Colors.black38)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppDimensions.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(createdAt, l),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppDimensions.fontM,
                          ),
                        ),
                        if (!AppManager.isLoginAsGuest && canLike)
                          Row(
                            children: [
                              Text(
                                '$nbLike',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppDimensions.fontM,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.p4),
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : AppColors.textSecondary,
                                  size: AppDimensions.p20,
                                ),
                                onPressed: () => _controller.toggleLike(widget.selfieModel.id),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
