import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happer_app/features/dashboard/screens/game_product_details_screen.dart';
import 'package:happer_app/shared/models/happer_product.dart';
import 'package:happer_app/core/utils/storage_service.dart';
import 'package:happer_app/core/network/websocket_service.dart';
import 'package:slide_countdown/slide_countdown.dart';

class GameContestScreen extends StatefulWidget {
  @override
  _GameContestScreenState createState() => _GameContestScreenState();
}

class _GameContestScreenState extends State<GameContestScreen> with TickerProviderStateMixin {
  late WebSocketService _webSocketService;
  List<HapperProduct> _products = [];
  int _userCredits = 0;
  Map<String, DateTime> _timerEndDates = {};
  // ignore: unused_field
  bool _isLoadingCredits = true;
  // Track connection status
  bool _isLoading = true; // Track loading status

  // Map to store animation controllers for each product
  Map<String, AnimationController> _progressAnimationControllers = {};
  Map<String, Animation<double>> _progressAnimations = {};

  bool _isProcessingPayment = false; // Track payment processing state

  // Timer duration from HapperVariables (defaults to 30 seconds)
  int _contestTimerDuration = 30;

  // Flag to track if timers have been initialized for current session
  bool _timersInitialized = false;

  // iOS-compatible properties
  bool _pauseProduct = false; // Matches iOS pauseProduct
  String _currentUserId = ''; // For "J'ai la main" logic
  int _timeToRest = -1; // Matches iOS timeToRest
  Map<String, bool> _wishedProducts = {}; // Track wishlist state

  double progress = 0.0;
  Timer? timer;
  bool isRunning = false;

  void startProgress([String? productId]) {
    // Cancel existing timer if any
    timer?.cancel();

    // Use the contest timer duration from HapperVariables
    final totalDuration = _contestTimerDuration.toDouble();
    const tick = Duration(milliseconds: 100);

    // Get the remaining duration based on productId, or use default
    double remainingDuration = totalDuration;
    if (productId != null) {
      final endDate = _timerEndDates[productId];
      final now = DateTime.now();

      if (endDate != null && endDate.isAfter(now)) {
        // Calculate remaining duration from the timer end date
        remainingDuration = endDate.difference(now).inMilliseconds / 1000;
      } else {
        // If no valid end date, set a new one using contest timer duration
        _timerEndDates[productId] = now.add(
          Duration(seconds: _contestTimerDuration),
        );
      }
    }

    // Calculate initial progress based on remaining duration
    double initialProgress = 1.0 - (remainingDuration / totalDuration);
    initialProgress = initialProgress.clamp(
      0.0,
      1.0,
    ); // Ensure it's between 0 and 1

    // Calculate step size
    double step = 1 / (remainingDuration * 1000 / tick.inMilliseconds);

    setState(() {
      progress = initialProgress;
      isRunning = true;
    });

    timer = Timer.periodic(tick, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        progress += step;
        if (progress >= 1.0) {
          progress = 1.0;
          isRunning = false;
          timer.cancel();
          onComplete();
        }
      });
    });
  }

  void onComplete() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Countdown Complete!')));
  }

  Color getColor() {
    // Always return black as the main button color
    return Colors.black;
  }

  Color getProgressColor() {
    // Now we're using a linear gradient: linear-gradient(270deg, #F8735A 0.99%, #F92055 100%)
    return Color(0xFFF92055); // Default to #F92055 (starting color of gradient)
  }

  LinearGradient getProgressGradient() {
    return LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFFF8735A), // #F8735A (0.99%)
        Color(0xFFF92055), // #F92055 (100%)
      ],
    );
  }

  Color getProgressColorForProduct(String productId) {
    // Now we're using a linear gradient for each product
    return Color(0xFFF92055); // Default to #F92055 (starting color of gradient)
  }

  @override
  void initState() {
    super.initState();
    
    _webSocketService = WebSocketService(
      'ws://happer-websocket-plp.azurewebsites.net',
    );
    // Load iOS-compatible settings
    _loadCurrentUser();
    _loadPauseState();
    _loadTimeToRest();

    _fetchCredits();
    _loadContestTimerDuration(); // Load timer duration from SharedPreferences
    _startTimerUpdates();

    setState(() {
      _isLoading = true;
    });

    print("Attempting to connect to WebSocket...");
    _connectWebSocket();
  }

  // Load current user ID for "J'ai la main" logic (matches iOS)
  Future<void> _loadCurrentUser() async {
    _currentUserId = StorageService.getUserId() ?? '';
  }

  // Load pause product state (matches iOS pauseProduct)
  Future<void> _loadPauseState() async {
    _pauseProduct = false;
  }

  // Load time_to_rest (matches iOS timeToRest)
  Future<void> _loadTimeToRest() async {
    setState(() {
      _timeToRest = 30;
    });
  }

  // Load contest timer duration — use default
  Future<void> _loadContestTimerDuration() async {
    // Use default _contestTimerDuration = 30
  }

  // Refresh the contest timer duration (can be called when HapperVariables are updated)
  Future<void> _refreshContestTimerDuration() async {
    final oldDuration = _contestTimerDuration;
    await _loadContestTimerDuration();

    // If the duration changed, reset all timers with new duration
    if (oldDuration != _contestTimerDuration) {
      print(
        "Timer duration updated from $oldDuration to $_contestTimerDuration seconds, resetting all timers",
      );
      _resetAllTimers();
    }
  }

  // Refresh user credits and contest timer duration
  Future<void> _refreshData() async {
    setState(() {
      _isLoadingCredits = true;
    });

    if (mounted) {
      setState(() {
        _userCredits = 0;
        _isLoadingCredits = false;
      });
    }
    await _refreshContestTimerDuration();
  }

    void _connectWebSocket() async {
    try {
      _webSocketService.connect();
      print("WebSocket connection established, sending country data immediately");
      _webSocketService.sendMessage("india");

      _webSocketService.stream.listen(
        (data) {
          try {
            final decodedData = jsonDecode(data);
            print("Received WebSocket data: $decodedData");
 List productsList = [];
      if (decodedData is List) {
        productsList = decodedData;
      } else if (decodedData is Map<String, dynamic> && decodedData['products'] is List) {
        productsList = decodedData['products'];
      }
      for (var product in productsList) {
        final id = product['id'];
        final timerstamp = product['timerstamp'];
        print("Product ID: $id, timerstamp: $timerstamp, timer: $timer");
      }
            if (mounted) {
              // Handle direct List of products (your backend)
              if (decodedData is List) {
                final productsList = decodedData
                    .map<HapperProduct>((product) => HapperProduct.fromJson(product as Map<String, dynamic>))
                    .toList();
                
                // Setup animation controllers for each product with timerstamp
                for (var product in productsList) {
                  if (product.timerstamp != null) {
                    // Update progress animations based on new timerstamp values
                    _updateProgressFromTimerstamp(product);
                  }
                }

                setState(() {
                  _products = productsList;
                  _isLoading = false;
                });
              }
              // Optionally, handle Map with 'products' key (legacy)
              else if (decodedData is Map<String, dynamic> &&
                  decodedData['products'] is List) {
                final productsList = (decodedData['products'] as List)
                    .map<HapperProduct>((product) => HapperProduct.fromJson(product as Map<String, dynamic>))
                    .toList();
                
                // Setup animation controllers for each product with timerstamp
                for (var product in productsList) {
                  if (product.timerstamp != null) {
                    // Update progress animations based on new timerstamp values
                    _updateProgressFromTimerstamp(product);
                  }
                }

                setState(() {
                  _products = productsList;
                  _isLoading = false;
                });
              }
            }
          } catch (e) {
            print("Error decoding WebSocket data: $e");
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
        onError: (error) {
          print("WebSocket error: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("WebSocket connection failed")),
          );
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            // Try to reconnect after a delay
            Future.delayed(Duration(seconds: 3), () {
              if (mounted) {
                print("Attempting to reconnect to WebSocket after error...");
                _connectWebSocket();
              }
            });
          }
        },
        onDone: () {
          print("WebSocket connection closed");
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            // Try to reconnect immediately when connection closes
            print("Attempting to reconnect to WebSocket after close...");
            Future.delayed(Duration(seconds: 1), () {
              if (mounted) {
                _connectWebSocket();
              }
            });
          }
      },
    
      );
    } catch (e) {
      print("Error connecting to WebSocket: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error connecting to WebSocket")),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Try to reconnect after a delay
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            print("Attempting to reconnect to WebSocket after exception...");
            _connectWebSocket();
          }
        });
      }
    }
  } void _updateTimerEndDates() {
    
    // Only set timers for products that don't already have valid timers
    final now = DateTime.now();
    bool anyNewTimersSet = false;

    for (var product in _products) {
  final productId = product.id;
  if (productId.isNotEmpty) {
    final existingEndDate = _timerEndDates[productId];
    if (existingEndDate == null || existingEndDate.isBefore(now)) {
      _timerEndDates[productId] = now.add(
        Duration(seconds: _timeToRest > 0 ? _timeToRest : _contestTimerDuration),
      );
      anyNewTimersSet = true;
      print(
        "Timer set for product $productId: ${_timeToRest > 0 ? _timeToRest : _contestTimerDuration} seconds",
      );
    }
  }
}
    // Mark timers as initialized after first run
    if (!_timersInitialized && anyNewTimersSet) {
      _timersInitialized = true;
      print("Timers initialized for all products");
    }
  }

  // Method to force reset all timers (only used when explicitly needed)
  void _resetAllTimers() {
    final now = DateTime.now();
  for (var product in _products) {
  final productId = product.id;
  if (productId.isNotEmpty) {
    _timerEndDates[productId] = now.add(
      Duration(seconds: _timeToRest > 0 ? _timeToRest : _contestTimerDuration),
    );
    _progressValues[productId] = 0.0;
    print(
      "Timer forcefully reset for product $productId: ${_timeToRest > 0 ? _timeToRest : _contestTimerDuration} seconds",
    );
  }
}
    _timersInitialized = true; // Mark as initialized after reset
  }

  void _startTimerUpdates() {
    // Update UI more frequently (200ms) for smoother timer updates
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          // Update progress for all products to match timer
          _products.forEach((product) {
            final productId = product.id;
            if (productId.isNotEmpty) {
              // Calculate the progress based on the time remaining
              _updateProgressFromTimer(productId);
            }
          });
        });
        _startTimerUpdates(); // Schedule next update
      }
    });
  }

  // This method synchronizes progress with the timer
  void _updateProgressFromTimer(String productId) {
    final endDate = _timerEndDates[productId];
    final now = DateTime.now();

    if (endDate == null ||
        endDate.isBefore(now) ||
        endDate.difference(now).inMilliseconds <= 0) {
      // Timer expired, show 00:00 briefly before resetting
      _progressValues[productId] = 1.0; // Show full progress (100%)

      // Reset timer after a short delay to allow seeing 00:00
      Future.delayed(Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            // Reset timer with contest timer duration from HapperVariables
            _timerEndDates[productId] = DateTime.now().add(
              Duration(seconds: _contestTimerDuration),
            );
            _progressValues[productId] = 0.0; // Reset progress

            print(
              "Timer reset for product $productId with duration $_contestTimerDuration seconds",
            );
          });
        }
      });
    } else {
      // Calculate progress based on time remaining using contest timer duration
      final totalDuration = _contestTimerDuration.toDouble();
      final remainingMs = endDate.difference(now).inMilliseconds.toDouble();
      final elapsedMs = (totalDuration * 1000) - remainingMs;
      final progress = elapsedMs / (totalDuration * 1000);

      // Update the progress value for this product
      _progressValues[productId] = progress.clamp(0.0, 1.0);
    }
  }

  Future<void> _fetchCredits() async {
    if (mounted) {
      setState(() {
        _userCredits = 0;
        _isLoadingCredits = false;
      });
    }
  }

  // Store progress values for each product
  Map<String, double> _progressValues = {};

  void startProgressForProduct(String productId) {
    // Initialize the progress from the timer (one-time initialization)
    _updateProgressFromTimer(productId);

    // We don't need a separate timer for progress as it will be updated by _startTimerUpdates
    // Just make sure the initial progress is set correctly

    // Check if the product already has a valid timer
    final endDate = _timerEndDates[productId];
    final now = DateTime.now();

    if (endDate == null) {
      // If no timer exists, this product should have been initialized by _updateTimerEndDates
      print("Warning: No timer found for product $productId, initializing...");
      _timerEndDates[productId] = now.add(
        Duration(seconds: _contestTimerDuration),
      );
      _progressValues[productId] = 0.0;
    } else if (endDate.isBefore(now)) {
      // Timer expired, but don't reset it here - let _updateProgressFromTimer handle it
      print("Timer expired for product $productId");
    }
  }

  // Initialize animation controller for a product
  void _initProgressAnimation(String productId, double initialProgress) {
    // Clean up existing animation controller if it exists
    _progressAnimationControllers[productId]?.dispose();
    
    // Create a new animation controller with initial value from timerstamp
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Animation duration for smooth transitions
      value: initialProgress, // Start from the current timerstamp progress
    );
    
    // Add listener to rebuild UI when animation progresses
    controller.addListener(() {
      if (mounted) {
        setState(() {
          // Just triggering a rebuild
        });
      }
    });
    
    _progressAnimationControllers[productId] = controller;
  }
  
  // Update progress animation based on timerstamp changes
  void _updateProgressFromTimerstamp(HapperProduct product) {
    if (product.timerstamp != null) {
      final productId = product.id;
      final targetProgress = product.progressPercent;
      
      // If we already have a controller, animate to new value
      if (_progressAnimationControllers.containsKey(productId)) {
        final controller = _progressAnimationControllers[productId]!;
        
        // Only animate if the value actually changed
        if (controller.value != targetProgress) {
          // Special handling for reset from 100% to 0% (or near 100% to near 0%)
          // This happens when timer completes and restarts
          if (controller.value > 0.9 && targetProgress < 0.1) {
            print("Detected timer reset for product $productId: ${controller.value} -> $targetProgress");
            
            // Use a quick fade out effect
            controller.animateTo(
              1.0,  // Ensure we reach 100% first
              duration: Duration(milliseconds: 100),
              curve: Curves.easeOut,
            ).then((_) {
              // Then reset to 0 and start the new animation
              controller.value = 0;
              controller.animateTo(
                targetProgress,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
              );
            });
          } else {
            // Normal animation for incremental changes
            controller.animateTo(
              targetProgress,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      } else {
        // Initialize new controller if it doesn't exist
        _initProgressAnimation(productId, targetProgress);
      }
    }
  }

  // Update progress animation based on timerstamp changes

  @override
  void dispose() {
    timer?.cancel();
    
    // Properly dispose WebSocket service
    _webSocketService.dispose();

    // Dispose all animation controllers
    for (var controller in _progressAnimationControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // Returns the remaining duration for the countdown, using timerstamp if available
  Duration _getRemainingDuration(HapperProduct product) {
    if (product.timerstamp != null) {
      return product.progressDuration;
    }
    // fallback to old logic if timerstamp not available
    final endDate = _timerEndDates[product.id];
    final now = DateTime.now();
    final maxSeconds = _timeToRest > 0 ? _timeToRest : _contestTimerDuration;
    if (endDate == null) {
      return Duration(seconds: maxSeconds);
    }
    if (endDate.isBefore(now)) {
      return Duration.zero;
    }
    final difference = endDate.difference(now);
    if (difference.inMilliseconds <= 0) {
      return Duration.zero;
    }
    return difference;
  }

  // Get the progress percentage for a product
  double _getProgressPercent(HapperProduct product) {
    if (product.timerstamp != null) {
      // Get the controller for this product
      final controller = _progressAnimationControllers[product.id];
      
      // If we have a controller, return its animated value
      if (controller != null) {
        return controller.value;
      }
      
      // If no controller yet, return the raw progress value
      return product.progressPercent;
    }
    
    // Fallback to local progress tracking if no timerstamp
    return _progressValues[product.id] ?? 0.0;
  }

  // Check if user has current bid - "J'ai la main" logic (matches iOS)
  bool _checkUserHasCurrentBid(HapperProduct product) {
    if (product.usersList.isNotEmpty && _currentUserId.isNotEmpty) {
      // In iOS: if (String(product.allHappeuseInt.first!) == currentUser.id)
      String firstUserId = product.usersList.first;
      return firstUserId == _currentUserId;
    }
    return false;
  }

  Future<void> _handleWishlistAction(
    HapperProduct product,
    bool addToWishlist,
  ) async {
    setState(() {
      _wishedProducts[product.id] = addToWishlist;
    });
  } // Show tooltip (matches iOS displayToolTip functionality)
  void _showTooltip(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }

  // Helper method to check if user should see credit warning (matches iOS logic)
  void _checkAndShowCreditWarnings() {
    // iOS logic: if user has few credits left, show promotional messages
    if (_userCredits == 2) {
      // Show premium offer dialog
      _showCreditWarningDialog(
        title: "One Credit Left",
        message: "Get Happer Plus for unlimited access",
        actionText: "See Offers",
        onAction: () {
          // Navigate to premium screen (placeholder)
          _showTooltip("Info", "Premium offers coming soon!");
        },
      );
    } else if (_userCredits == 4) {
      // Show ads for credits
      _showCreditWarningDialog(
        title: "Three Credits Left",
        message: "Watch ads to earn more credits",
        actionText: "Go to Ads",
        onAction: () {
          // Navigate to ads screen (placeholder)
          _showTooltip("Info", "Credit ads coming soon!");
        },
      );
    }
  }

  // Helper method to show credit warning dialogs (matches iOS alerts)
  void _showCreditWarningDialog({
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Match the grey background from screenshot
      appBar: HapperAppBar(
        title: 'PRIZE',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userCredits.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFFE8A30A),
                  ),
                ),
                SizedBox(
                  width: 25,
                  height: 25,
                  child: Image.asset('assets/images/coin_icon.png', fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingView()
              : _products.isEmpty
              ? _buildEmptyView()
              : RefreshIndicator(
                onRefresh: () async {
                  // Refresh all data including user credits and timer duration
                  await _refreshData();
                  _resetAllTimers(); // Force reset all timers on manual refresh
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return _buildProductCard(product);
                  },
                ),
              ),
    );
  }

  // Loading indicator view
  Widget _buildLoadingView() => const _GameLoadingView();

  Widget _buildEmptyView() => _GameEmptyView(onRefresh: () {
        setState(() => _isLoading = true);
        _webSocketService.connect();
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _isLoading) setState(() => _isLoading = false);
        });
      });

  // Redesigned to match the screenshot exactly
  Widget _buildProductCard(HapperProduct product) {
    final productId = product.id;
    
    // Check if pictures array exists and is not empty
    final bool hasPicture = product.pictures.isNotEmpty;
    final imageUrl =
        hasPicture ? product.pictures[0] : 'https://via.placeholder.com/120';

    final brandName = product.getBrandName();
    final userName = product.getFirstUserName();
    final price = product.price;
    // Get formatted date (if available) - show start date if contest hasn't started, else show happ date
    String formattedDate = "";
    DateTime? dateToShow;
    String dateLabel = "";

    // Determine which date to show based on current time and contest state
    final now = DateTime.now();
    if (product.startDate != null) {
      if (now.isBefore(product.startDate!)) {
        // Contest hasn't started yet, show start date
        dateToShow = product.startDate;
        dateLabel = "Start Date";
      } else if (product.happDate != null) {
        // Contest has started, show happ date
        dateToShow = product.happDate;
        dateLabel = "Happ Date";
      } else {
        // Fallback to start date if no happ date available
        dateToShow = product.startDate;
        dateLabel = "Start Date";
      }
    } else if (product.happDate != null) {
      // No start date but has happ date
      dateToShow = product.happDate;
      dateLabel = "Happ Date";
    }

    if (dateToShow != null) {
      final day = dateToShow.day.toString().padLeft(2, '0');
      final month = dateToShow.month.toString().padLeft(2, '0');
      final hour = dateToShow.hour.toString().padLeft(2, '0');
      final minute = dateToShow.minute.toString().padLeft(2, '0');
      formattedDate = "$day-$month\n$hour:$minute";
    }

    // For WIN state (state 2), use a completely different horizontal layout
    if (product.state == 2) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _buildWinStateUI(product, productId, userName),
          ),
        ),
      );
    }

    // Create a widget based on whether the product has pictures or not (for non-WIN states)
    Widget imageWidget;
    if (hasPicture) {
      imageWidget = Padding(
        padding: const EdgeInsets.only(top:16.0,right: 16.0),
        child: Image.network(
          imageUrl,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              width: 110,
              height: 110,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF92055)),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print("Error loading image from $imageUrl: $error");
            return _buildPlaceholderImage(error.toString());
          },
        ),
      );
    } else {
      imageWidget = _buildPlaceholderImage("No image available");
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Main card container
          Container(
            decoration: BoxDecoration(
              color: product.state == 1 ? Color(0xFFE6E6E6) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Brand name and image
                    Container(
                      width: 140,
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment:
                            product.state == 1
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8, top: 0),
                            child: Text(
                              brandName.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 0.5,
                                color: Color(0xFF252525),
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  final productId = product.id;
                                  final timerEndDate =
                                      _timerEndDates[productId];
                                  final currentProgress =
                                      _progressValues[productId] ?? 0.0;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => GameProductDetailsScreen(
                                            product: product,
                                            timerEndDate:
                                                timerEndDate, // Pass the timer end date
                                            currentProgress:
                                                currentProgress, // Pass current progress
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      product.state == 1 ? 0 : 4,
                                    ),
                                  //   boxShadow: [
                                  //   //   BoxShadow(
                                  //   //    // color: Colors.black.withOpacity(0.05),
                                  //   //     spreadRadius: 0,
                                  //   //     blurRadius: 3,
                                  //   //     offset: Offset(0, 1),
                                  //   //   ),
                                  //   // ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      product.state == 1 ? 0 : 4,
                                    ),
                                    child: imageWidget,
                                  ),
                                ),
                              ),
                              // Date box positioned on the image (only for state 0 products)
                              if (product.state == 0 &&
                                  formattedDate.isNotEmpty)
                                Positioned(
                                  top: 0,
                                  right:
                                      5, // Moved more to the right from center
                                  child: GestureDetector(
                                    onTap: () => _showTooltip(
        "Reserve period not reached",
        "Minimum date and time before you can win the item",
      ),
                                    child: Container(
                                      width: 50,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                           right: 0,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "?",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              formattedDate,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Lato',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 9,
                                                height: 1.1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right side - Product details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          right: 15.0,
                          bottom: 15.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product name/title
                            Text(
                             product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 12),

                            // Price info
                            Row(
                              children: [
                                Text(
                                  "Real price ",
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                    color: Color(0xFF696969),
                                  ),
                                ),
                                Text(
                                  "${price}€",
                                  style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),

                            // Conditionally render UI based on product state
                            _buildProductStateUI(
                              product,
                              productId,
                              userName,
                              formattedDate,
                              dateLabel,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Main state machine for product UI based on contest state
  Widget _buildProductStateUI(
    HapperProduct product,
    String productId,
    String userName,
    String formattedDate,
    String dateLabel,
  ) {
    switch (product.state) {
      case 0: // AVAILABLE - Active bidding
        return _buildAvailableStateUI(product, productId, userName);
      case 1: // SOON - Pre-bidding state
        return _buildSoonStateUI(product, formattedDate, dateLabel);
      case 2: // WIN - Bidding ended with winner
        return _buildWinStateUI(product, productId, userName);
      case 3: // EXPIRED - Contest ended without bids
        return _buildExpiredStateUI(product, productId);
      default:
        print('Warning: Unknown product state: ${product.state}');
        return _buildAvailableStateUI(
          product,
          productId,
          userName,
        ); // Default fallback
    }
  }

  // UI for SOON state (state 1) - iOS soonLayout implementation
  Widget _buildSoonStateUI(
    HapperProduct product,
    String formattedDate,
    String dateLabel,
  ) {
    final productId = product.id;
    bool isWished =
        _wishedProducts[productId] ?? false; // iOS: selectedProduct.isWished

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date display (matches iOS timeRestant logic)
        if (formattedDate.isNotEmpty)
          Center(
            child: GestureDetector(
              onTap:
                  () => _showTooltip(
                    dateLabel,
                    "Contest ${dateLabel.toLowerCase()}: ${formattedDate.replaceAll('\n', ' ')}",
                  ), // Dynamic tooltip
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Center(
                  child: Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.2,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),

        SizedBox(height: 18),

        // Wishlist button (matches iOS wishView)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
                () => _handleWishlistAction(
                  product,
                  !isWished,
                ), // iOS wishListTapInside
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // iOS: UIColor.black
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  6,
                ), // iOS: layer.cornerRadius = 6
              ),
              padding: EdgeInsets.zero,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isWished) ...[
                  // iOS: wishOk.isHidden = false
                  Icon(Icons.check_circle, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                ],
                Text(
                  isWished ? 'ADDED TO WISHLIST' : 'WISHLIST',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700, // iOS: Lato-Bold
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // UI for AVAILABLE state (state 0) with timer and HAPPER button - iOS-compatible
  Widget _buildAvailableStateUI(
    HapperProduct product,
    String productId,
    String userName,
  ) {
    bool userHasCurrentBid = _checkUserHasCurrentBid(product);
    
    // If this product has a timerstamp, make sure we have an animation controller
    if (product.timerstamp != null && !_progressAnimationControllers.containsKey(productId)) {
      _updateProgressFromTimerstamp(product);
    }
    
    // Use timerstamp-based progress if available
    double progress = _getProgressPercent(product);
    final timerKey = ValueKey('timer-$productId-${product.timerstamp ?? 0}');
    final isComplete = product.timerstamp != null && product.timerstamp! >= 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info row (matches screenshot)
        if (product.usersList.isNotEmpty)
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/hold.svg',
                width: 12,
                height: 12,
                color: userHasCurrentBid ? Color(0xFFF92055) : Color(0xFF696969),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  userName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: userHasCurrentBid ? Color(0xFFF92055) : Color(0xFF696969),
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),

        SizedBox(height: product.usersList.isNotEmpty ? 12 : 0),

        // Timer section (matches screenshot layout)
        Row(
          children: [
            Image.asset(
              'assets/images/clock.png',
              width: 16,
              height: 16,
              color: Color(0xFFF92055),
            ),
            SizedBox(width: 8),
            // Timer countdown (always driven by timerstamp)
            SlideCountdown(
              key: timerKey,
              slideDirection: SlideDirection.down,
              showZeroValue: true,
              duration: isComplete ? Duration.zero : _getRemainingDuration(product),
              decoration: BoxDecoration(color: Colors.transparent),
              separatorType: SeparatorType.symbol,
              separatorStyle: TextStyle(
                color: Color(0xFFF92055),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              separator: ":",
              shouldShowDays: (duration) => false,
              shouldShowHours: (duration) => false,
              shouldShowMinutes: (duration) => true,
              shouldShowSeconds: (duration) => true,
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFFF92055),
                height: 1.0,
              ),
            ),
            SizedBox(width: 6),
            Text(
              "secondes",
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xFFF92055),
              ),
            ),
          ],
        ),

        SizedBox(height: 15),          // HAPPER button with gradient (matches screenshot)
        Container(
          key: ValueKey('button-$productId-${product.timerstamp ?? 0}'), // Force rebuild on timerstamp change
          width: double.infinity,
          height: 42,
          child: AnimatedBuilder(
            animation: _progressAnimationControllers[productId] ?? const AlwaysStoppedAnimation(0.0),
            builder: (context, _) {
              // Get the current progress value from the animation controller or fallback
              final animatedProgress = _progressAnimationControllers[productId]?.value ?? progress.clamp(0.0, 1.0);
              
              return ElevatedButton(
                onPressed: _pauseProduct || isComplete
                    ? null
                    : () async {
                        // Prevent multiple taps while processing
                        if (_isProcessingPayment) return;

                        // Check if user already has the current bid (iOS logic)
                        if (userHasCurrentBid) {
                          _showTooltip("Information", "Vous avez déjà la main");
                          return;
                        }

                        // Check if user has sufficient credits
                        if (_userCredits <= 0) {
                          _showTooltip(
                            "Erreur",
                            "Vous n'avez pas assez de crédits pour Happer!",
                          );
                          return;
                        }

                        // Set processing state to prevent multiple calls
                        setState(() {
                          _isProcessingPayment = true;
                        });

                        try {
                          // Happ product — feature coming soon
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité bientôt disponible'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } finally {
                  // Reset processing state
                  if (mounted) {
                    setState(() {
                      _isProcessingPayment = false;
                    });
                  }
                }
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: _pauseProduct || isComplete
                        ? null
                        : LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFF8735A),
                              Color(0xFFF92055),
                              Colors.black,
                            ],
                            stops: [
                              0.0,
                              animatedProgress,
                              animatedProgress + 0.001,
                            ],
                          ),
                    color: _pauseProduct || isComplete ? Colors.grey.shade400 : null,
                  ),
                  child: Center(
                    child: Text(
                      _checkUserHasCurrentBid(product) ? "J'ai la main" : "HAPPER",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 1.0,
                        color: _pauseProduct || isComplete
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
            ),
          ),
        
      ],
    );
  }

  // UI for WIN state (state 2) - iOS ProductCollectionWinViewCell implementation (fixed layout)
  Widget _buildWinStateUI(
    HapperProduct product,
    String productId,
    String userName,
  ) {
    // For WIN state, we need to override the entire card layout to match the screenshot
    // This creates a horizontal layout: image left, details right
    final bool hasPicture = product.pictures.isNotEmpty;
    final imageUrl =
        hasPicture ? product.pictures[0] : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () {
        final productId = product.id;
        final timerEndDate = _timerEndDates[productId];
        final currentProgress = _progressValues[productId] ?? 0.0;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => GameProductDetailsScreen(
                  product: product,
                  timerEndDate: timerEndDate, // Pass the timer end date
                  currentProgress: currentProgress, // Pass current progress
                ),
          ),
        );
      },
      child: Container(
        height: 150, // Fixed height to match the image
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Product image (150x150)
            Container(
              width: 150,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    hasPicture
                        ? Image.network(
                          imageUrl,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            );
                          },
                        )
                        : Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
              ),
            ),
            SizedBox(width: 16),

            // Right side - Product details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product title/description
                    Text(
                      product.getDescription(),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6),

                    // Winner info with gift icon
                    Row(
                      children: [
                        Icon(Icons.card_giftcard, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          '${product.getFirstUserName()}',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Pricing section
                    Row(
                      children: [
                        Text(
                          'Real Price ',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            color: Colors.grey[600],
                            decorationColor: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${product.price.toInt()}€',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // Discount price in green
                    Row(
                      children: [
                        Text(
                          'Discount Price ', // Using 20% discount as example
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${(product.price * 0.8).toInt()}€', // Using 20% discount as example
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI for EXPIRED state (state 3) - Contest ended without bids
  Widget _buildExpiredStateUI(HapperProduct product, String productId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expired message
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            children: [
              Icon(
                Icons.access_time_filled,
                color: Colors.grey.shade600,
                size: 20,
              ),
              SizedBox(height: 4),
              Text(
                'Contest Expired',
                
              ),
              SizedBox(height: 2),
              Text(
                'No participants in this contest',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 15),

        // Expired disabled button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: Center(
              child: Text(
                'EXPIRED',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to create a placeholder image - Redesigned
  Widget _buildPlaceholderImage([String? message]) =>
      _GamePlaceholderImage(message: message);

  // WIN state helper methods - iOS ProductCollectionWinViewCell implementation
}

// ─── Game Contest Widget Components ─────────────────────────────────────────

class _GameLoadingView extends StatelessWidget {
  const _GameLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          const SizedBox(height: 20),
          Text(
            'Connecting to server...',
            style: TextStyle(fontFamily: 'Lato', fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting the latest products',
            style: TextStyle(fontFamily: 'Lato', fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _GameEmptyView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _GameEmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(fontFamily: 'Lato', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new items',
            style: TextStyle(fontFamily: 'Lato', fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('REFRESH'),
          ),
        ],
      ),
    );
  }
}

class _GamePlaceholderImage extends StatelessWidget {
  final String? message;
  const _GamePlaceholderImage({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                message ?? 'No Image',
                style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'Lato'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
