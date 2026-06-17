import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/discover/models/discover_model.dart';
import 'package:happer_app/features/discover/screens/discover_detail_screen.dart';
import 'package:happer_app/features/selfies/bindings/selfie_binding.dart';
import 'package:happer_app/features/selfies/controllers/selfie_controller.dart';
import 'package:happer_app/features/selfies/data/models/selfie_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class MyImagesScreen extends StatefulWidget {
  const MyImagesScreen({Key? key}) : super(key: key);

  @override
  _MyImagesScreenState createState() => _MyImagesScreenState();
}

class _MyImagesScreenState extends State<MyImagesScreen> {
  late final SelfieController _controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SelfieController>()) {
      SelfieBinding().dependencies();
    }
    _controller = Get.find<SelfieController>();

    // Only hit the API on the first visit; subsequent visits use cached data.
    // Pull-to-refresh triggers a real refresh via fetchMySelfies(refresh: true).
    if (_controller.mySelfies.isEmpty) {
      _controller.fetchMySelfies();
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMoreMySelfies();
    }
  }

  Future<void> _onRefresh() => _controller.fetchMySelfies(refresh: true);

  DiscoverModel _toDiscoverModel(SelfieModel s) {
    return DiscoverModel.fromJson({
      '_id': s.id,
      'state': s.state ?? '',
      'created_at': s.createdAt ?? '',
      'likes': [],
      'users_type': s.user?.usersType ?? 0,
      'items_id': [],
      'picture': s.primaryImage,
      'nb_like': s.nbLike,
      'isLikedByMe': s.isLikedByMe,
      'user': s.user != null
          ? {
              '_id': s.user!.id,
              'username': s.user!.username,
              'first_name': s.user!.firstName,
              'last_name': s.user!.lastName,
              'picture': s.user!.picture,
            }
          : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).mesLooksTitle),
      body: Obx(() {
        final selfies = _controller.mySelfies;
        final isLoading = _controller.isMyLoading.value;
        final isLoadingMore = _controller.isMyLoadingMore.value;

        if (isLoading) {
          return _ShimmerGrid();
        }

        if (selfies.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.black,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_outlined,
                          size: 64, color: Colors.black),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).noImagesFound,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).noImagesFoundSubtitle,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: GridView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: selfies.length + (isLoadingMore ? 3 : 0),
              itemBuilder: (context, index) {
                // Show shimmer placeholders at the bottom while loading more
                if (index >= selfies.length) {
                  return _ShimmerCell();
                }

                final selfie = selfies[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiscoverDetailScreen(
                          selfieModel: _toDiscoverModel(selfie),
                          isFromMyImages: true,
                        ),
                      ),
                    ).then((isDeleted) {
                      if (isDeleted == true) {
                        _controller.fetchMySelfies(refresh: true);
                      }
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: selfie.primaryImage,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _ShimmerCell(),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 12,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
