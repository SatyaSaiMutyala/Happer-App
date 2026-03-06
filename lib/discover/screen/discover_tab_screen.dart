import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:happer_app/app_manager.dart';
import 'package:happer_app/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:happer_app/discover/api/discover_api.dart';
import 'package:happer_app/discover/model/discover_model.dart';
import 'package:happer_app/discover/screen/discover_detail_screen.dart';

class DiscoverTabScreen extends StatefulWidget {
  const DiscoverTabScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverTabScreen> createState() => _DiscoverTabScreenState();
}

class _DiscoverTabScreenState extends State<DiscoverTabScreen> {
  List<DiscoverModel> _data = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreData = true;
  bool _isPaginating = false;
  bool hasShownGuestLimitMessage = false;
  bool _showScrollToTopButton = false;
  bool _hasShownGuestSnackBar = false;


  @override
  void initState() {
    super.initState();
    _setupScrollController();

    // ✅ Only fetch if list is empty to avoid reloading after coming back
    if (_data.isEmpty) {
      _fetchDiscoverSelfies();
    }

    if (_data.isNotEmpty) {
      // Restore scroll position if data already exists
      SharedPreferences.getInstance().then((prefs) {
        final savedOffset = prefs.getDouble('decouver_tab_scroll_offset') ?? 0.0;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(savedOffset);
          } else {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && _scrollController.hasClients) {
                _scrollController.jumpTo(savedOffset);
              }
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retry fetching data if still empty (handles timing issues with token availability)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _data.isEmpty && !_isLoading) {
        _fetchDiscoverSelfies();
      }
    });
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      final scrollOffset = _scrollController.position.pixels;
      final scrollContentSizeHeight = _scrollController.position.maxScrollExtent;

      // Show/hide scroll to top button
      if (scrollOffset > 300 && !_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = true);
      } else if (scrollOffset <= 300 && _showScrollToTopButton) {
        setState(() => _showScrollToTopButton = false);
      }

      // Handle pagination when scrolled near bottom
      if (scrollOffset >= scrollContentSizeHeight - 600 &&
          !_isPaginating &&
          _hasMoreData &&
          !_isLoading) {
        if (AppManager.isLoginAsGuest && _data.length >= 10) {
          if (!_hasShownGuestSnackBar) {
            showAppSnackBar('Please log in to see more content',
                isSuccess: false);
            _hasShownGuestSnackBar = true;
          }
          return;
        }
        _loadMoreData();
      }
    });
  }


  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadMoreData() async {
    if (_isPaginating || !_hasMoreData) return; // Prevent redundant calls

    if (AppManager.isLoginAsGuest && _data.length >= 10) {
      if(!hasShownGuestLimitMessage){
      showAppSnackBar('Please log in to see more content', isSuccess: false); 
      hasShownGuestLimitMessage = true;
      }
      return;
    }

    setState(() {
      _isPaginating = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isPaginating = false;
      });
      return;
    }

    try {
      final nextPage = _currentPage + 1;
      final discoverData = await DiscoverApiService(
        token: token,
      ).fetchDiscoverSelfies(categoryId: '', page: nextPage, country: '');

      if (discoverData.isEmpty) {
        setState(() {
          _hasMoreData = false; // Stop further pagination
        });
      } else {
        setState(() {
          _data.addAll(discoverData);
          _currentPage = nextPage;
        });
      }
    } catch (e) {
      // Optional: Log or report error
      print('Error loading more data: $e');
    } finally {
      setState(() {
        _isPaginating = false; // Reset flag
      });
    }
  }

  Future<void> _fetchDiscoverSelfies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _hasMoreData = true;
      _isPaginating = false;
      _hasShownGuestSnackBar = false;
      hasShownGuestLimitMessage = false;
      _data.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication error. Please log in again.';
      });
      return;
    }

    try {
      final discoverData = await DiscoverApiService(
        token: token,
      ).fetchDiscoverSelfies(categoryId: '', page: 0, country: '');

      setState(() {
        _data = discoverData;
        _isLoading = false;
        _hasMoreData = discoverData.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: $e';
      });
    }
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 2.5,
        vertical: 2.5,
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
      ),
      child: AspectRatio(
        aspectRatio: 0.7,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDiscoverSelfies,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _fetchDiscoverSelfies,
          child: _isLoading
              ? MasonryGridView.count(
                  physics: const AlwaysScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: 8,
                  itemBuilder: (context, index) => _buildShimmerCard(),
                )
              : MasonryGridView.count(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  itemCount: _data.length + (_hasMoreData ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _data.length) {
                      return _buildShimmerCard();
                    }
        
                    final selfie = _data[index];
        
                    return GestureDetector(
                      onTap: () {
                        if(AppManager.isLoginAsGuest){
                          showAppSnackBar('Please Login First', isSuccess: false);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiscoverDetailScreen(
                              selfieModel: selfie,
                              isFromMyImages: false,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 2.5,
                          vertical: 2.5,
                        ),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: AspectRatio(
                          aspectRatio: 0.7,
                          child: CachedNetworkImage(
                            imageUrl: selfie.picture,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                height: 150,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
      ],
    );
  }
}
