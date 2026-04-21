// Required imports
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/features/creator/api/creator_api.dart';
import 'package:happer_app/features/creator/models/creator_model.dart';
import 'package:happer_app/features/creator/screens/selfie_details_screen.dart';
import 'package:happer_app/features/profile/screens/image_grid_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Shimmer loading widget
class CreatorShimmer extends StatelessWidget {
  final int itemCount;
  const CreatorShimmer({this.itemCount = 5, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                ),
                title: Container(height: 10, width: 100, color: Colors.white),
                subtitle: Container(height: 10, width: 50, color: Colors.white),
                //trailing: Icon(Icons.verified, color: Colors.white),
              ),
              Container(
                height: 400,
                width: double.infinity,
                color: Colors.white,
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

class CreatorTabScreen extends StatefulWidget {
  const CreatorTabScreen({Key? key}) : super(key: key);

  @override
  CreatorTabScreenState createState() => CreatorTabScreenState();
}

class CreatorTabScreenState extends State<CreatorTabScreen> {
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _requestInProgress = false;
  final ScrollController _scrollController = ScrollController();
  final List<CreatorModel> _data = [];
  List<CreatorModel> _filteredData = [];
  String _searchQuery = '';
  bool _hasShownGuestSnackBar = false;
  bool _showScrollToTopButton = false;
  int _activePointers = 0;
  ScrollPhysics _listPhysics = const BouncingScrollPhysics();
  bool _refreshEnabled = true;

  /// Public method to force refresh the feed (e.g., after uploading a new selfie)
  Future<void> forceRefresh() async {
    _currentPage = 0;
    _hasMoreData = true;
    _requestInProgress = false;
    await _fetchInfluencerSelfies(firstLoad: true);
  }

  void searchCreators(String query) async {
    setState(() {
      _searchQuery = query.toLowerCase();
      _isLoading = true;
      _filteredData.clear();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;
      final apiService = CreatorApiService(token: token);
      final searchResults = await apiService.fetchInfluencerSelfiesWithSearch(
        page: 0,
        searchTerm: query,
      );

      setState(() {
        _filteredData =
            searchResults.map((e) => CreatorModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch search results')));
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // ✅ Fetch data on initialization
    if (_data.isEmpty) {
      _fetchInfluencerSelfies();
    } else {
      // Restore scroll position if data already exists
      _restoreScrollPosition();
    }
  }

  void _restoreScrollPosition() {
    SharedPreferences.getInstance().then((prefs) {
      final savedOffset = prefs.getDouble('creator_tab_scroll_offset') ?? 0.0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients && savedOffset > 0) {
          _scrollController.jumpTo(savedOffset);
        } else if (savedOffset > 0) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _scrollController.hasClients) {
              _scrollController.jumpTo(savedOffset);
            }
          });
        }
      });
    });
  }

  void _saveScrollPosition() {
    final scrollOffset = _scrollController.offset;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble('creator_tab_scroll_offset', scrollOffset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onImageTap(BuildContext context, String selfieId) async {
    print('Yeah man im touching ......!');
    // if (AppManager.isLoginAsGuest) {
    //   showAppSnackBar('Please Login In First', isSuccess: false);
    //   return;
    // }
    _saveScrollPosition(); // Save scroll position before navigating
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfieDetailsScreen(selfieId: selfieId),
      ),
    );
  }

  void _onLikeButtonPressed(CreatorModel selfie, int index) {
    final wasLiked = selfie.isLikedByMe ?? false;
    final newLikeState = !wasLiked;

    setState(() {
      selfie.isLikedByMe = newLikeState;
      selfie.nbLike = (selfie.nbLike ?? 0) + (newLikeState ? 1 : -1);
      if (selfie.nbLike! < 0) selfie.nbLike = 0;
    });

    _handleLikeAction(selfie, newLikeState);
  }

  Future<void> _handleLikeAction(CreatorModel selfie, bool isLiked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final apiService = CreatorApiService(token: token);
      final selfieId = selfie.sId ?? '';
      if (isLiked) {
        await apiService.likeSelfie(selfieId);
      } else {
        await apiService.dislikeSelfie(selfieId);
      }
    } catch (_) {
      setState(() {
        selfie.isLikedByMe = !isLiked;
        selfie.nbLike = (selfie.nbLike ?? 0) + (isLiked ? -1 : 1);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToUpdateLike),
          ),
        );
      }
    }
  }

  void _onScroll() {
    final scrollOffset = _scrollController.position.pixels;
    final scrollViewHeight = _scrollController.position.viewportDimension;
    final scrollContentSizeHeight = _scrollController.position.maxScrollExtent;

    if (scrollOffset > 300 && !_showScrollToTopButton) {
      setState(() => _showScrollToTopButton = true);
    } else if (scrollOffset <= 300 && _showScrollToTopButton) {
      setState(() => _showScrollToTopButton = false);
    }

    if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight &&
        !_requestInProgress &&
        _hasMoreData) {
      if (AppManager.isLoginAsGuest && _data.length >= 10) {
        if (!_hasShownGuestSnackBar) {
          showAppSnackBar('Please log in to see more content',
              isSuccess: false);
          _hasShownGuestSnackBar = true; // Mark as shown
        }
        return;
      }
      _requestInProgress = true;
      _currentPage++;
      _fetchInfluencerSelfies();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> _fetchInfluencerSelfies({bool firstLoad = false}) async {
    if (_isLoading || (!_hasMoreData && !firstLoad)) return;

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        _isLoading = false;
        _requestInProgress = false;
      });
      return;
    }

    try {
      final apiService = CreatorApiService(token: token);
      final pageToLoad = firstLoad ? 0 : _currentPage;
      final discoverData = await apiService.fetchInfluencerSelfies(
        page: pageToLoad,
      );

      final newSelfies = discoverData
          .map((e) {
            final selfie = CreatorModel.fromJson(e);
            selfie.isLikedByMe = selfie.isLikedByMe ?? false;
            return selfie;
          })
          .where(
            (selfie) => selfie.picture != null && selfie.picture!.isNotEmpty,
          )
          .toList();

      setState(() {
        if (firstLoad) {
          _data.clear();
          _currentPage = 0;
          _hasMoreData = true;
        }
        if (newSelfies.isEmpty) {
          _hasMoreData = false;
        } else {
          _data.addAll(newSelfies);
          if (!firstLoad) _currentPage = pageToLoad;
        }
        _isLoading = false;
        _requestInProgress = false;
        _filterData();
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _requestInProgress = false;
        _hasMoreData = false;
      });
    }
  }

  String _getTimeDifference(String createdAt) {
    final createdTime = DateTime.parse(createdAt);
    final difference = DateTime.now().difference(createdTime);

    if (difference.inMinutes < 1) {
      return "À l'instant";
    }
    if (difference.inMinutes < 60) {
      return "Il y a ${difference.inMinutes} min";
    }
    if (difference.inHours < 24) {
      return "Il y a ${difference.inHours} heures";
    }
    if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    }
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? "Il y a $weeks semaine" : "Il y a $weeks semaines";
    }
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "Il y a $months mois";
    }
    final years = (difference.inDays / 365).floor();
    return years == 1 ? "Il y a $years an" : "Il y a $years ans";
  }

  void _filterData() {
    final localizations = AppLocalizations.of(context);
    if (_searchQuery.isEmpty) {
      _filteredData = List.from(_data);
    } else {
      _filteredData = _data.where((selfie) {
        final creatorName = selfie.user?.firstName?.toLowerCase() ??
            localizations.unknown.toLowerCase();
        return creatorName.contains(_searchQuery);
      }).toList();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retry fetching data if still empty (handles timing issues with token availability)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _data.isEmpty && !_isLoading) {
        _fetchInfluencerSelfies(firstLoad: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final selfies = _searchQuery.isEmpty
        ? _data
        : (_filteredData.isEmpty ? _data : _filteredData);
    final bool noSearchResults =
        _searchQuery.isNotEmpty && _filteredData.isEmpty;

    if (_data.isEmpty && _isLoading) {
      return const CreatorShimmer();
    }

    if (_data.isEmpty) {
      return Center(child: Text(localizations.noDataFound));
    }

    return Stack(children: [
      Column(
        children: [
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      noSearchResults
                          ? localizations.noCreatorFound(_searchQuery)
                          : localizations.searchResults(_searchQuery),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _filterData();
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _currentPage = 0;
                _hasMoreData = true;
                _requestInProgress = false;
                await _fetchInfluencerSelfies(firstLoad: true);
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: selfies.length + 1,
                itemBuilder: (context, index) {
                  if (index == selfies.length) {
                    if (_isLoading && _searchQuery.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CreatorShimmer(itemCount: 1),
                      );
                    }
                    if (!_hasMoreData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Column(
                            children: const [
                              Text(
                                'Vous êtes à jour.',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'De nouveaux looks arrivent bientôt.',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF8D8D8D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final selfie = selfies[index];
                  final imageUrl = selfie.picture ?? '';
                  final id = selfie.sId ?? '';
                  final user = selfie.user;
                  final userName = user?.userName ?? user?.firstName;
                  final name = user?.firstName ?? localizations.unknown;
                  final profilePic = user?.picture ?? '';
                  print('User type for ${user?.firstName}: ${user?.usersType}');

                  return GestureDetector(
                    onTap: () => _onImageTap(context, id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (AppManager.isLoginAsGuest) {
                                        showAppSnackBar('Please login first',
                                            isSuccess: false);
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageGridScreen(
                                            userId: user?.sId ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: profilePic.isNotEmpty
                                              ? NetworkImage(profilePic)
                                              : null,
                                          radius: 20,
                                          child: profilePic.isEmpty
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          userName ?? '',
                                          style: const TextStyle(
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            height: 1.0,
                                            letterSpacing: 0.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  if (user?.usersType == 1)
                                    const Icon(
                                      Icons.verified,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                ],
                              ),
                              Text(
                                _getTimeDifference(
                                  selfie.createdAt ??
                                      DateTime.now().toIso8601String(),
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                  color: Color(0xFF8D8D8D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _onImageTap(context, id),
                          child: Stack(
                            children: [
                              Builder(
                                builder: (context) {
                                  final TransformationController controller =
                                      TransformationController();

                                  return InteractiveViewer(
                                    transformationController: controller,
                                    panEnabled: true,
                                    scaleEnabled: true,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    clipBehavior: Clip.none,
                                    onInteractionEnd: (details) {
                                      // Animate smoothly back to original position after zoom ends
                                      controller.value = Matrix4.identity();
                                    },
                                    child: Image.network(
                                      imageUrl,
                                      height: 400,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image),
                                    ),
                                  );
                                },
                              ),
                              // Brand logos at bottom-left
                              if (selfie.itemsId != null &&
                                  selfie.itemsId!.any((item) =>
                                      item.exactMatch == true &&
                                      item.item?.brandId?.picture != null))
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: () {
                                    final seenBrandIds = <String>{};
                                    final uniqueBrands = <String>[];
                                    for (final item in selfie.itemsId!) {
                                      if (item.exactMatch == true &&
                                          item.item?.brandId?.picture != null &&
                                          item.item?.brandId?.sId != null &&
                                          seenBrandIds.add(item.item!.brandId!.sId!)) {
                                        uniqueBrands.add(item.item!.brandId!.picture!);
                                      }
                                    }
                                    final logoSize = 48.0;
                                    final overlap = 16.0;
                                    final totalWidth = uniqueBrands.length * logoSize - (uniqueBrands.length - 1) * overlap;
                                    return SizedBox(
                                      width: totalWidth,
                                      height: logoSize,
                                      child: Stack(
                                        children: List.generate(uniqueBrands.length, (i) {
                                          return Positioned(
                                            left: i * (logoSize - overlap),
                                            child: Container(
                                              height: logoSize,
                                              width: logoSize,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                border: Border.all(color: Colors.white, width: 2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 6,
                                                    offset: Offset(1, 2),
                                                  )
                                                ],
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: ClipOval(
                                                child: CachedNetworkImage(
                                                  imageUrl: uniqueBrands[i],
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) => Container(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  errorWidget: (context, url, error) =>
                                                      Icon(
                                                    Icons.image,
                                                    size: 22,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                  }(),
                                ),
                              if (!AppManager.isLoginAsGuest)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _onLikeButtonPressed(selfie, index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0x33000000),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.favorite,
                                        color: selfie.isLikedByMe == true
                                            ? Colors.red
                                            : Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Divider(thickness: 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      if (_showScrollToTopButton)
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.black.withOpacity(0.6),
            mini: true,
            onPressed: _scrollToTop,
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
    ]);
  }
}
