import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/features/creator/screens/selfie_details_screen.dart';
import 'package:happer_app/features/profile/bindings/image_grid_binding.dart';
import 'package:happer_app/features/profile/controllers/image_grid_controller.dart';
import 'package:happer_app/features/profile/models/user_profile_stats_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/core/utils/deep_link_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageGridScreen extends StatefulWidget {
  final String userId;
  const ImageGridScreen({required this.userId, Key? key}) : super(key: key);

  @override
  State<ImageGridScreen> createState() => _ImageGridScreenState();
}

class _ImageGridScreenState extends State<ImageGridScreen> {
  late final ImageGridController _controller;
  final GlobalKey _shareKey = GlobalKey();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ImageGridBinding(widget.userId).dependencies();
    _controller = Get.find<ImageGridController>(tag: widget.userId);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _controller.loadMoreSelfies();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<ImageGridController>(tag: widget.userId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final isProfileLoading = _controller.isProfileLoading.value;
      final isSelfiesLoading = _controller.isSelfiesLoading.value;
      final isLoadingMore = _controller.isLoadingMore.value;
      final profile = _controller.profile.value;
      final selfies = _controller.selfies;
      final error = _controller.profileError.value;

      Widget selfiesSliver;
      if (isSelfiesLoading) {
        selfiesSliver = _SelfiesShimmerGrid();
      } else if (selfies.isEmpty) {
        selfiesSliver = SliverFillRemaining(
          child: Center(
            child: Text(
              l10n.noImagesFound,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        );
      } else {
        final itemCount = selfies.length + (isLoadingMore ? 2 : 0);
        selfiesSliver = SliverPadding(
          padding: const EdgeInsets.all(2),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                if (index >= selfies.length) return _ShimmerCell();
                final selfie = selfies[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelfieDetailsScreen(selfieId: selfie.id),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: CachedNetworkImage(
                      imageUrl: selfie.primaryImage,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _ShimmerCell(),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
              childCount: itemCount,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
              childAspectRatio: 0.66,
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: HapperAppBar(
          title: profile?.usersType == 1 ? 'BOUTIQUE CRÉATEUR' : 'PROFIL',
        ),
        body: RefreshIndicator(
          onRefresh: _controller.refresh,
          color: Colors.black,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: isProfileLoading
                    ? _ProfileHeaderShimmer()
                    : error != null
                        ? _ErrorView(
                            message: l10n.profileLoadFailed,
                            onRetry: _controller.refresh,
                          )
                        : profile != null
                            ? _ProfileHeader(
                                profile: profile,
                                shareKey: _shareKey,
                                userId: widget.userId,
                                isOwnProfile: widget.userId == StorageService.getUserId(),
                                onFollowTap: _controller.toggleFollow,
                                onInstagramTap: () =>
                                    _launchInstagram(context, profile),
                                onShareTap: () => _share(context, profile),
                              )
                            : const SizedBox.shrink(),
              ),
              const SliverToBoxAdapter(
                child: Divider(thickness: 1, height: 1),
              ),
              selfiesSliver,
            ],
          ),
        ),
      );
    });
  }

  Future<void> _launchInstagram(
      BuildContext context, UserProfileStatsModel profile) async {
    final link = profile.instagramLink;
    if (link == null || link.isEmpty) return;
    final appUrl = Uri.parse('instagram://user?username=$link');
    final webUrl = Uri.parse('https://instagram.com/$link');
    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Instagram')),
        );
      }
    }
  }

  void _share(BuildContext context, UserProfileStatsModel profile) {
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    shareProfile(
      username: profile.username,
      creatorName: profile.fullname,
      sharePositionOrigin:
          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }

}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserProfileStatsModel profile;
  final GlobalKey shareKey;
  final String userId;
  final bool isOwnProfile;
  final VoidCallback onFollowTap;
  final VoidCallback onInstagramTap;
  final VoidCallback onShareTap;

  const _ProfileHeader({
    required this.profile,
    required this.shareKey,
    required this.userId,
    required this.isOwnProfile,
    required this.onFollowTap,
    required this.onInstagramTap,
    required this.onShareTap,
  });

  String _formatCount(int count) {
    if (count >= 1000) {
      final k = count / 1000.0;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              ClipOval(
                child: profile.hasPicture
                    ? CachedNetworkImage(
                        imageUrl: profile.picture!,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _AvatarShimmer(),
                        errorWidget: (_, __, ___) => _AvatarPlaceholder(),
                      )
                    : _AvatarPlaceholder(),
              ),
              const SizedBox(width: 16),
              // Stats + buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.username,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                        if (profile.usersType == 1) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 18, color: Colors.black),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    _StatRow(
                      posts: profile.selfiesCount,
                      followers: profile.followersCount,
                      following: profile.followingCount,
                      formatCount: _formatCount,
                    ),
                    const SizedBox(height: 10),
                    _ActionButtons(
                      shareKey: shareKey,
                      isFollowing: profile.isFollowing,
                      isOwnProfile: isOwnProfile,
                      hasInstagram: profile.instagramLink?.isNotEmpty == true,
                      onFollowTap: onFollowTap,
                      onInstagramTap: onInstagramTap,
                      onShareTap: onShareTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              profile.bio!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final int posts;
  final int followers;
  final int following;
  final String Function(int) formatCount;

  const _StatRow({
    required this.posts,
    required this.followers,
    required this.following,
    required this.formatCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _StatItem(value: formatCount(posts), label: l10n.posts),
        const SizedBox(width: 16),
        _StatItem(value: formatCount(followers), label: l10n.followers),
        const SizedBox(width: 16),
        _StatItem(value: formatCount(following), label: l10n.following),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Lato', fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final GlobalKey shareKey;
  final bool isFollowing;
  final bool isOwnProfile;
  final bool hasInstagram;
  final VoidCallback onFollowTap;
  final VoidCallback onInstagramTap;
  final VoidCallback onShareTap;

  const _ActionButtons({
    required this.shareKey,
    required this.isFollowing,
    required this.isOwnProfile,
    required this.hasInstagram,
    required this.onFollowTap,
    required this.onInstagramTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Own profile: share button fills the full row width (like follow button did)
    if (isOwnProfile) {
      return Row(
        children: [
          if (hasInstagram) ...[
            _IconBtn(icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white, size: 18), onTap: onInstagramTap),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: SizedBox(
              height: 34,
              child: ElevatedButton.icon(
                onPressed: onShareTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.share, size: 16, color: Colors.black),
                label: const Text(
                  'Partager',
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Other user's profile: follow + instagram + share
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: onFollowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[300] : Colors.black,
                foregroundColor: isFollowing ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                isFollowing ? l10n.unfollow : l10n.follow,
                style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (hasInstagram) ...[
          _IconBtn(icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white, size: 18), onTap: onInstagramTap),
          const SizedBox(width: 8),
        ],
        _IconBtn(key: shareKey, icon: const Icon(Icons.share, color: Colors.white, size: 18), onTap: onShareTap),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  const _IconBtn({Key? key, required this.icon, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: icon,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, size: 48, color: Colors.grey),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retry,
                style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer Widgets ──────────────────────────────────────────────────────────

class _ProfileHeaderShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      3,
                      (_) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Container(
                            width: 40,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      height: 34,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(width: 90, height: 90, color: Colors.white),
    );
  }
}

class _SelfiesShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(2),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, __) => _ShimmerCell(),
          childCount: 8,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 0.66,
        ),
      ),
    );
  }
}

class _ShimmerCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(2))),
    );
  }
}
