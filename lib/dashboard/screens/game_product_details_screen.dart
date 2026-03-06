import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:happer_app/models/happer_product.dart';
import 'package:happer_app/models/happer_product_detail.dart';
import 'package:happer_app/webservices/product_api.dart';
import 'package:happer_app/webservices/user_service.dart';
import 'package:happer_app/webservices/websocket_service.dart';
import 'package:share_plus/share_plus.dart';

class GameProductDetailsScreen extends StatefulWidget {
  final HapperProduct product; // Now using HapperProduct model
  final DateTime? timerEndDate; // Add this parameter
  final double? currentProgress; // Add this parameter

  const GameProductDetailsScreen({
    Key? key, 
    required this.product,
    this.timerEndDate,
    this.currentProgress,
  }) : super(key: key);

  @override
  _GameProductDetailsScreenState createState() =>
      _GameProductDetailsScreenState();
}

class _GameProductDetailsScreenState extends State<GameProductDetailsScreen> {
  DateTime? _timerEndDate;
  String _timeRemaining = "00:00";
  int _currentIndex = 0;
  final List<String> _images = [];
  String _userCredits = "0".toUpperCase(); // Store user credits
  late WebSocketService _webSocketService;

  // Product detail data from WebSocket
  HapperProductDetail? _productDetail;
  List<UserDetail> _latestUsers = [];
  int _totalUsers = 0;

  // Progress tracking
  double _progress = 0.0;

  // Loading state for WebSocket data
  bool _isLoadingWebSocketData = false;

  // Timer duration (default 30 seconds, but will be set from product)
  int _timerDuration = 30; // Default 30 seconds

  // Flag to track which tab is active: true for buyers, false for product info
  bool _showBuyersList = true;

  @override
  void initState() {
    super.initState();

    // Initialize with HapperProductDetail from the start
    _productDetail = HapperProductDetail.fromHapperProduct(widget.product);

    // Get timer duration from the product using the getter method
    _timerDuration = 30; // Always use 30 seconds

    // Use passed timer data if available, otherwise create new timer
    if (widget.timerEndDate != null) {
      _timerEndDate = widget.timerEndDate;
      _progress = widget.currentProgress ?? 0.0;
      print("Using passed timer data - End: $_timerEndDate, Progress: $_progress");
    } else {
      // Fallback to creating new timer
      _timerEndDate = DateTime.now().add(Duration(seconds: _timerDuration));
      _progress = 0.0;
      print("No timer data passed, creating new timer");
    }

    // Initialize WebSocket connection
    _webSocketService = WebSocketService(
      'ws://happer-websocket-pdp.azurewebsites.net/socket.io/details/',
      
    );
    _connectWebSocket();

    // Initialize the images list from the product data
    if (_productDetail!.pictures.isNotEmpty) {
      _images.addAll(_productDetail!.pictures);
    } else {
      // Use a placeholder image if no images are available
      _images.add('https://via.placeholder.com/400');
    }

    _updateTimeRemaining();
    _startTimerUpdates();
    fetchUserCredits();
  }

  Future<void> _connectWebSocket() async {
    if (mounted) {
      setState(() {
        _isLoadingWebSocketData = true;
      });
    }

    try {
      debugPrint("Connecting to WebSocket for product: ${_productDetail!.id}");
      _webSocketService.connect();

      // Send the product ID immediately after connection is established
      // BEFORE setting up the stream listener
      debugPrint("Sending product ID to WebSocket: ${_productDetail!.id}");
      _webSocketService.sendMessage(_productDetail!.id);
      _webSocketService.stream.listen(
        (data) {
          try {
            final decodedData = jsonDecode(data);

            // Check for error messages
            if (decodedData is Map<String, dynamic> &&
                decodedData.containsKey('error')) {
              debugPrint("WebSocket Error: ${decodedData['error']}");

              // If we get an error with the MongoDB ObjectId format, try alternative methods
              if (decodedData['error'].toString().contains('ObjectId')) {
                // If ID is not 24 characters, try padding to make 24 characters
                if (_productDetail!.id.length < 24 &&
                    _isHexOnly(_productDetail!.id)) {
                  // Pad with zeros if needed to make 24 characters
                  final paddedId = _productDetail!.id.padRight(24, '0');
                  _webSocketService.sendMessage(paddedId);
                }
                // If that doesn't work and we're sure it's a valid 24-char hex ID,
                // try sending just the ID again
                else if (_productDetail!.id.length == 24 &&
                    _isHexOnly(_productDetail!.id)) {
                  _webSocketService.sendMessage(_productDetail!.id);
                }
              }
            }

            // Handle the WebSocket response data here
            if (decodedData is Map<String, dynamic>) {
              // Parse response into HapperProductDetail object
              try {
                final newProductDetail = HapperProductDetail.fromJson(
                  decodedData,
                );

                // Extract the user list
                List<UserDetail> latestUsers = [];
                if (decodedData['latest_users'] != null) {
                  final usersList = decodedData['latest_users'];
                  debugPrint(
                    "WebSocket received ${usersList.length} latest users",
                  );

                  latestUsers = List<UserDetail>.from(
                    usersList.map((x) => UserDetail.fromJson(x)),
                  );

                  // Debug log names of users
                  for (var user in latestUsers) {
                    debugPrint(
                      "User in latest_users: ${user.username} (position: ${user.position})",
                    );
                  }
                } else {
                  debugPrint(
                    "WebSocket response contains no latest_users field",
                  );
                }

                // Get total users count
                int totalUsers = decodedData['total_users'] ?? 0;
                debugPrint("WebSocket total users count: $totalUsers");

                // Update the UI with the new data
                if (mounted) {
                  setState(() {
                    _productDetail = newProductDetail;
                    _latestUsers = latestUsers;
                    _totalUsers = totalUsers;
                    _isLoadingWebSocketData = false;

                    // We're no longer using server-provided timer values
                    // Always use 30 seconds and let our local timer handle it

                    // Update images if there are new ones
                    if (_productDetail!.pictures.isNotEmpty) {
                      _images.clear();
                      _images.addAll(_productDetail!.pictures);
                    }
                  });
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoadingWebSocketData = false;
                  });
                }
                debugPrint(
                  "Error parsing WebSocket data to HapperProductDetail: $e",
                );
              }
            } else if (decodedData is List) {
              // If it's a list, try to parse the first item if it exists
              if (decodedData.isNotEmpty &&
                  decodedData[0] is Map<String, dynamic>) {
                try {
                  final newProductDetail = HapperProductDetail.fromJson(
                    decodedData[0],
                  );

                  // Extract users from the first item if applicable
                  List<UserDetail> latestUsers = [];
                  if (decodedData[0]['latest_users'] != null) {
                    latestUsers = List<UserDetail>.from(
                      decodedData[0]['latest_users'].map(
                        (x) => UserDetail.fromJson(x),
                      ),
                    );
                  }

                  // Get total users count from the first item
                  int totalUsers = decodedData[0]['total_users'] ?? 0;

                  if (mounted) {
                    setState(() {
                      _productDetail = newProductDetail;
                      _latestUsers = latestUsers;
                      _totalUsers = totalUsers;
                      _isLoadingWebSocketData = false;

                      // Update images if there are new ones
                      if (_productDetail!.pictures.isNotEmpty) {
                        _images.clear();
                        _images.addAll(_productDetail!.pictures);
                      }
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _isLoadingWebSocketData = false;
                    });
                  }
                  debugPrint(
                    "Error parsing list data to HapperProductDetail: $e",
                  );
                }
              }
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isLoadingWebSocketData = false;
              });
            }
            debugPrint("Error decoding WebSocket data: $e");
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isLoadingWebSocketData = false;
            });
          }
          debugPrint("WebSocket error: $error");

          // Show a snackbar with the error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Problem connecting to the server. Using local data.",
                ),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isLoadingWebSocketData = false;
            });
          }
          debugPrint("WebSocket connection closed");
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWebSocketData = false;
        });
      }
      debugPrint("Error connecting to WebSocket: $e");

      // Show a snackbar with the error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Could not connect to the server. Using cached data.",
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Set mounted to false to prevent further timer updates
    // Disconnect WebSocket when the screen is disposed
    _webSocketService.disconnect();

    // Clear timer data to prevent further updates
    _timerEndDate = null;

    // Cancel any pending Future.delayed calls
    // Note: This can't be done directly with Future.delayed, but setting
    // _timerEndDate to null will prevent them from updating state

    super.dispose();
  }

  // Helper method to check if a string contains only hexadecimal characters
  bool _isHexOnly(String value) {
    final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegExp.hasMatch(value);
  }

  void _updateTimeRemaining() {
    if (_timerEndDate == null) {
      // Timer hasn't been started yet - this shouldn't happen now as we start it in initState
      setState(() {
        _timeRemaining = "00:00";
        _progress = 0.0;
      });
      return;
    }

    final now = DateTime.now();
    final difference = _timerEndDate!.difference(now);

    if (difference.inMilliseconds <= 0) {
      // Timer has reached 00:00, automatically restart it
      _resetTimer();
      return;
    }

    // Calculate progress based on time remaining
    // For smoother animation, use millisecond precision
    final totalDurationMs = _timerDuration * 1000.0;
    final remainingMs = difference.inMilliseconds.toDouble();
    final elapsedMs = totalDurationMs - remainingMs;
    final progress = elapsedMs / totalDurationMs;

    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    setState(() {
      _timeRemaining =
          "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      _progress = progress.clamp(0.0, 1.0);
    });
  }

  void _startTimerUpdates() {
    // Create a timer that updates more frequently for smoother animation (every 50ms)
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _updateTimeRemaining();
        _startTimerUpdates(); // Schedule next update
      }
    });
  }

  // Fetch user credits from the server via API
  void fetchUserCredits() async {
    try {
      // Use the UserService to fetch credits from the API
      final userService = UserService();
      final credits = await userService.fetchUserCredits();

      // Update the state with the fetched credits
      if (mounted) {
        setState(() {
          _userCredits = credits.toString().toUpperCase();
        });
      }

      debugPrint('User credits updated: $_userCredits');
    } catch (e) {
      debugPrint('Error fetching user credits: $e');
      // In case of an error, set a default value
      if (mounted) {
        setState(() {
          _userCredits = "0".toUpperCase();
        });
      }
    }
  }

  void _resetTimer() {
    debugPrint("Resetting timer for product: ${_productDetail!.id}");

    // Immediately update the UI to show 00:00 before starting a new timer
    setState(() {
      _timeRemaining = "00:00";
      _progress = 1.0; // Set progress to 100% to show completed state
    });

    // Add a small delay before restarting to visually show the timer reached 00:00
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          // Reset timer to exactly 30 seconds
          _timerEndDate = DateTime.now().add(Duration(seconds: 30));
          _progress = 0.0;

          // Update the time string to show the full time
          final minutes = 0; // Always 0 for 30 seconds
          final seconds = 30; // Always 30 seconds
          _timeRemaining =
              "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

          debugPrint("Timer reset - new end time: $_timerEndDate");
        });
      }
    });
  }

  // Add this method to handle different product states
  String _getButtonText() {
    switch (widget.product.state) {
      case 0: // AVAILABLE
        return 'HAPPER';
      case 1: // SOON
        return 'STARTING SOON';
      case 3: // EXPIRED
        return 'EXPIRED';
      default:
        return 'HAPPER';
    }
  }

  bool _isButtonEnabled() {
    switch (widget.product.state) {
      case 0: // AVAILABLE - Button enabled
        return true;
      case 1: // SOON - Button disabled
      case 2: // WIN - Button disabled
      case 3: // EXPIRED - Button disabled
        return false;
      default:
        return true;
    }
  }

  Color _getButtonColor() {
    switch (widget.product.state) {
      case 0: // AVAILABLE
        return Colors.black;
      case 1: // SOON
        return Colors.grey;
      case 2: // WIN
        return Colors.green;
      case 3: // EXPIRED
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  bool _shouldShowTimer() {
    // Only show timer for AVAILABLE state
    return widget.product.state == 0;
  }

  String _getTimerText() {
    switch (widget.product.state) {
      case 0: // AVAILABLE
        return _timeRemaining;
      case 1: // SOON
        return "SOON";
     
      case 3: // EXPIRED
        return "EXPIRED";
      default:
        return _timeRemaining;
    }
  }

  @override
  Widget build(BuildContext context) {
    // We're already initializing _productDetail in initState, so we can use it directly
    final promotionalPrice = _productDetail!.price * 0.5; // 50% off

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
          "HAPPER PRODUCTS",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
        actions: [
          // Show user credits
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _userCredits,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.0, // equivalent to line-height: 100%
                    letterSpacing: 0,
                    color: Color(0xFFE8A30A), // #E8A30A color
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  width: 25,
                  height: 25,
                  child: Image.asset(
                    'assets/images/coin_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product title with share button
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      _productDetail!.title.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        height: 1.0, // equivalent to line-height: 100%
                        letterSpacing: 0,
                        color: Color(0xFF252525), // #252525 color
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle share functionality
                      _shareProduct();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF202020),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      fixedSize: Size(94, 38),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      "PARTAGER",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.0, // equivalent to line-height: 100%
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Brand name if available
            if (_productDetail!.brand.name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _productDetail!.brand.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            // Image carousel
            Center(
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(maxHeight: 185, maxWidth: 150),
                child: Column(
                  children: [
                    // Image carousel
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child:
                            _images.isNotEmpty
                                ? PageView.builder(
                                  itemCount: _images.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Image.network(
                                      _images[index],
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        debugPrint(
                                          'Error loading image: $error',
                                        );
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image,
                                                  size: 80,
                                                  color: Colors.grey[400],
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  'Image unavailable',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                                : Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 100,
                                    ),
                                  ),
                                ),
                      ),
                    ),

                    // Dot indicators for image carousel
                    if (_images.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_images.length, (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              width: _currentIndex == index ? 10 : 8,
                              height: _currentIndex == index ? 10 : 8,
                              decoration: BoxDecoration(
                                color:
                                    _currentIndex == index
                                        ? Colors.black
                                        : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Timer, prices and CTA button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timer display with progress button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/clock.png',
                            width: 17,
                            height: 17,
                            color: _shouldShowTimer() ? Color(0xFFFD5C6E) : Colors.grey, // #FD5C6E color
                          ),
                          SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getTimerText(),
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 19,
                                  height:
                                      1.0, // equivalent to line-height: 100%
                                  letterSpacing: 0,
                                  color: _shouldShowTimer() ? Color(0xFFFD5C6E) : Colors.grey, // #FD5C6E color
                                ),
                              ),
                              Text(
                                _shouldShowTimer() ? "seconds" : "",
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0, // line-height: 100%
                                  letterSpacing: 0,
                                  color: _shouldShowTimer() ? Color(0xFFFD5C6E) : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Progress Button
                      GestureDetector(
                        onTap: _isButtonEnabled() ? () async {
                          if (widget.product.state != 0) {
                            // Show appropriate message for non-available states
                            String message;
                            switch (widget.product.state) {
                              case 1:
                                message = 'Contest starting soon!';
                                break;
                              case 2:
                                message = 'Contest has ended';
                                break;
                              case 3:
                                message = 'Contest expired';
                                break;
                              default:
                                message = 'Contest not available';
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          // Original HAPPER button functionality for AVAILABLE state
                          try {
                            debugPrint(
                              'Attempting to happ product: ${_productDetail!.id}',
                            );
                            final result = await ProductApi.happProduct(
                              _productDetail!.id,
                            );
                            debugPrint('Happ button click response: $result');

                            if (mounted) {
                              if (result['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                fetchUserCredits();

                                Future.delayed(Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    _connectWebSocket();
                                    setState(() {});
                                  }
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ?? 'An error occurred',
                                    ),
                                    backgroundColor:
                                        result['statusCode'] == 500
                                            ? Colors.orange
                                            : Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            debugPrint('Error in happ button tap: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        } : null, // Disable onTap when button is not enabled
                        child: SizedBox(
                          width: 120,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getButtonColor(),
                              borderRadius: BorderRadius.circular(8),
                              // Add opacity for disabled state
                            ),
                            child: Opacity(
                              opacity: _isButtonEnabled() ? 1.0 : 0.6,
                              child: Stack(
                                children: [
                                  // Only show progress for AVAILABLE state
                                  if (widget.product.state == 0)
                                    Positioned.fill(
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: _progress,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  Color(0xFFF92055), // #F92055
                                                  Color(0xFFF8735A), // #F8735A
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Centered text
                                  Center(
                                    child: Text(
                                      _getButtonText(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: widget.product.state == 1 ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Prices
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Prix réel   ",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.0, // equivalent to line-height: 100%
                          letterSpacing: 0,
                          color: Color(0xFF696969), // #696969 color
                        ),
                      ),
                      Text(
                        "${_productDetail!.price.toStringAsFixed(2)} €",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 13,
                          height: 1.0, // equivalent to line-height: 100%
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(thickness: 1, color: Color(0xFFF0EFF4)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Prix PROMO   ",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.0, // equivalent to line-height: 100%
                          letterSpacing: 0,
                          color: Color(0xFF252525), // #252525 color
                        ),
                      ),
                      Text(
                        "${promotionalPrice.toStringAsFixed(2)} €",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          height: 1.0, // equivalent to line-height: 100%
                          letterSpacing: 0,
                          color: Color(0xFF252525), // #252525 color
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Call to action button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Open the buy URL if available
                        if (_productDetail!.buyUrl != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening product page...')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Product added to cart!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF202020),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        "JE LE VEUX",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Tab buttons
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF252525),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showBuyersList = true;
                              });
                            },
                            child: Container(
                              height: 42,
                              //margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    _showBuyersList
                                        ? Colors.white
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(23),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Dernières Happeuses",
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color:
                                      _showBuyersList
                                          ? Colors.black
                                          : Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showBuyersList = false;
                              });
                            },
                            child: Container(
                              height: 42,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    !_showBuyersList
                                        ? Colors.white
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(23),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Informations produit",
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color:
                                      !_showBuyersList
                                          ? Colors.black
                                          : Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Show either buyers list or product info based on selected tab
                  _showBuyersList
                      ? _buildLastBuyersList()
                      : _buildProductInfoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _forceRefreshUserData() {
    debugPrint("Forcing refresh of user data");
    if (mounted) {
      // Reconnect to the WebSocket to get updated users list
      _connectWebSocket();
    }
  }

  Widget _buildLastBuyersList() {
    // Show loading indicator while waiting for WebSocket data
    if (_isLoadingWebSocketData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8A30A)),
            ),
            SizedBox(height: 16),
            Text(
              "Loading latest users...",
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // If we have latest users from WebSocket data, use that instead
    if (_latestUsers.isNotEmpty) {
      debugPrint("Displaying ${_latestUsers.length} users from WebSocket data");
      return Column(
        children: [
          ..._latestUsers.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        user.position != null
                            ? "${user.position}"
                            : "${index + 1}",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        user.username,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (user.position == 1 || index == 0)
                      Icon(
                        Icons.emoji_events,
                        color: Color(0xFFE8A30A),
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
          // Add a "pull to refresh" hint
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: GestureDetector(
              onTap: _forceRefreshUserData,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    "Tap to refresh user list",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Get users from the product's usersList as fallback
    final List<Map<String, String>> buyers = [];

    // Process the user list with numerical indices
    if (_productDetail != null && _productDetail!.usersList.isNotEmpty) {
      debugPrint(
        "Fallback: Using ${_productDetail!.usersList.length} users from product details",
      );

      for (int i = 0; i < _productDetail!.usersList.length && i < 10; i++) {
        final user = _productDetail!.usersList[i];
        String userName = "Unknown";

        // Extract user name from format like "userId/username"
        if (user.contains('/')) {
          userName = user.split('/')[1];
        } else {
          userName = user;
        }

        // Use position numbers like in the design (1ère, 2ème, etc.)
        buyers.add({'position': (i + 1).toString(), 'name': userName});
      }
    } else {
      debugPrint("No users found in product details usersList");
    }

    // If we have no users, show a message
    if (buyers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "Pas encore d'utilisateurs.",
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            // Add a button to try refreshing
            GestureDetector(
              onTap: _forceRefreshUserData,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Refresh",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    debugPrint("Showing ${buyers.length} users in Dernières Happeuses list");

    return Column(
      children: [
        ...buyers.map((buyer) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      buyer['position']!,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      buyer['name']!,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (buyer['position'] == '1')
                    Icon(
                      Icons.emoji_events,
                      color: Color(0xFFE8A30A),
                      size: 18,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
        // Add a "refresh" option
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: GestureDetector(
            onTap: _forceRefreshUserData,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  "Tap to refresh user list",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Share product with share_plus package
  void _shareProduct() {
    // Use product detail from WebSocket if available
    final productDetail =
        _productDetail ?? HapperProductDetail.fromHapperProduct(widget.product);

    try {
      // Notify user that sharing is being prepared
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Préparation du partage...')));

      // Create share text with product details
      final String shareText = """
${productDetail.title}
${productDetail.brand.name}
Prix: ${productDetail.price.toStringAsFixed(2)} €
Prix Promo: ${(productDetail.price * 0.5).toStringAsFixed(2)} €
    
Découvrez ce produit sur Happer!
""";

      // If there's a buy URL, include it in the share
      final String shareUrl = productDetail.buyUrl ?? "https://happer.fr";

      // Show the share sheet
      if (_images.isNotEmpty) {
        // Share with just the text for now (implementing image sharing would require downloading the image first)
        Share.share(
          '$shareText\n\n$shareUrl',
          subject: 'Regardez ce produit sur Happer!',
        );
      } else {
        // Simple text sharing
        Share.share(
          '$shareText\n\n$shareUrl',
          subject: 'Regardez ce produit sur Happer!',
        );
      }

      // Log the share action
      debugPrint("Product shared: ${productDetail.id}");
    } catch (error) {
      debugPrint("Error sharing product: $error");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors du partage')));
    }
  }

  // Build info tab content
  Widget _buildProductInfoTab() {
    // Show loading indicator while waiting for WebSocket data
    if (_isLoadingWebSocketData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8A30A)),
            ),
            SizedBox(height: 16),
            Text(
              "Loading product information...",
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Use product detail from WebSocket if available
    final productDetail =
        _productDetail ?? HapperProductDetail.fromHapperProduct(widget.product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(productDetail.getDescription(), style: TextStyle(fontSize: 14)),
        SizedBox(height: 16),

        Text(
          "Country",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          productDetail.country ?? "Unknown",
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 16),

        // Show product status if available from WebSocket
        if (_productDetail?.productStatus != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _productDetail!.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _productDetail!.productStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          _productDetail!.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),

        // Show total users count if available from WebSocket
        if (_totalUsers > 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Users",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text("$_totalUsers", style: TextStyle(fontSize: 14)),
              SizedBox(height: 16),
            ],
          ),

        // if (productDetail.buyUrl != null)
        //   Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         "Buy URL",
        //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        //       ),
        //       SizedBox(height: 8),
        //       Text(
        //         productDetail.buyUrl.toString(),
        //         style: TextStyle(
        //           fontSize: 14,
        //           color: Colors.blue,
        //           decoration: TextDecoration.underline,
        //         ),
        //       ),
        //     ],
        //   ),
      ],
    );
  }
}
