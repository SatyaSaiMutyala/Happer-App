import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happer_app/profile/api/code_credit_api.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import 'package:happer_app/profile/model/code_credit_model.dart';
import 'package:happer_app/profile/model/promo_code_model.dart';

class CodeCreditScreen extends StatefulWidget {
  const CodeCreditScreen({Key? key}) : super(key: key);

  @override
  _CodeCreditScreenState createState() => _CodeCreditScreenState();
}

class _CodeCreditScreenState extends State<CodeCreditScreen> {
  final TextEditingController _codeController = TextEditingController();
  late Future<CodeCredit> _codeCredit;
  late Future<List<PromoCode>> _promoCodes; // Add this line
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _isLoadingPromoCodes = false;
  String? _errorMessage;
  String _hintText = 'XXXX-XXXX-XXXX'; // Default hint text

  @override
  void initState() {
    super.initState();
    _loadCodeCredits();
    _loadPromoCodes(); // Add this line

    // Add listener to update UI when text changes
    _codeController.addListener(() {
      setState(() {
        // This empty setState will trigger a rebuild when text changes
      });
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCodeCredits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user profile data using ProfileApiService
      final profileApi = ProfileApiService();
      final userProfileFuture = profileApi.fetchCurrentUserProfile();

      // Use the existing CodeCreditApiService as fallback
      final creditApi = CodeCreditApiService();

      // Fetch promo code from dedicated endpoint for the hint text
      creditApi
          .fetchPromoCode()
          .then((fetchedPromoCode) {
            // If we got a promo code from the dedicated endpoint, use it as hint text
            if (fetchedPromoCode != null && fetchedPromoCode.isNotEmpty) {
              setState(() {
                _hintText = fetchedPromoCode;
               
              });
            }
          })
          .catchError((error) {
          
          });

      // Create a Future that resolves to CodeCredit
      _codeCredit = userProfileFuture
          .then<CodeCredit>((userData) {
            // Check if the user profile has credits
            if (userData.containsKey('credits')) {
              final credits =
                  userData['credits'] is int
                      ? userData['credits']
                      : int.tryParse(userData['credits'].toString()) ?? 0;
              final creditCode = userData['credit_code'] as String?;

              return CodeCredit(credits: credits, code: creditCode);
            } else {
              // If user profile doesn't have credits, fall back to the dedicated credits API
              return creditApi.getCodeCredits();
            }
          })
          .catchError((error) {
            // If user profile fetch fails, fall back to the dedicated credits API
            return creditApi.getCodeCredits();
          });

     
      _codeCredit
          .then((creditData) {
           

            // Clear the input field first to avoid appending
            _codeController.clear();

            // If there's an active promo code, show it in the input field
            if (creditData.code != null && creditData.code!.isNotEmpty) {
              // Set text controller value to the promo code
              _codeController.text = creditData.code!;
            }
          })
          .catchError((error) {
           
          });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load credits: $e';
      });
     
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPromoCodes() async {
    try {
      setState(() {
        // Set loading state for promo codes
        _isLoadingPromoCodes = true;
      });

      final api = CodeCreditApiService();
      _promoCodes = api.fetchAllPromoCodes();

      // Once loaded, update UI
      _promoCodes
          .then((_) {
            if (mounted) {
              setState(() {
                _isLoadingPromoCodes = false;
              });
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _isLoadingPromoCodes = false;
              });
            }
            debugPrint('Error in promo codes future: $error');
          });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPromoCodes = false;
        });
      }
      debugPrint('Error loading promo codes: $e');
    }
  } // Method to build the coin image using the asset image

  Widget _buildCoinImage() {
    return Container(
      width: 110,
      height: 110,
      child: Image.asset('assets/images/coin_icon.png', fit: BoxFit.contain),
    );
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a code')));
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final api = CodeCreditApiService();
      final success = await api.verifyCode(code);

      if (success) {
        // Don't clear the controller here as we'll reload credits which will set it appropriately
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Code verified successfully')));
        // Reload credits and promo codes after successful verification
        _loadCodeCredits();
        _loadPromoCodes();
      } else {
        setState(() {
          _errorMessage = 'Invalid code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error verifying code: $e';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
          'CODE CREDIT',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Background curve - positioned to match the screenshot
                  Positioned(
                    bottom: 0,
                    left: -20, // Extend slightly beyond screen edges
                    right: -20,
                    height:
                        MediaQuery.of(context).size.height *
                        0.4, // Higher curve to match the screenshot
                    child: CustomPaint(painter: CurvedLinePainter()),
                  ),
                  // Main content
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FutureBuilder<CodeCredit>(
                        future: _codeCredit,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Error loading credits'),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadCodeCredits,
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          final credits = snapshot.data?.credits ?? 0;
                          final promoCode = snapshot.data?.code;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 80),
                              // Credit count
                              Text(
                                credits.toString(),
                                style: TextStyle(
                                  fontSize: 96,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE5AB39),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              // Coin icon
                              Container(
                                alignment: Alignment.center,
                                child: _buildCoinImage(),
                              ),

                              // User's promo code if available
                              if (promoCode != null && promoCode.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'YOUR PROMO CODE',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey.shade100,
                                        ),
                                        child: Text(
                                          promoCode,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(
                                height:
                                    promoCode != null && promoCode.isNotEmpty
                                        ? 40
                                        : 100,
                              ),
                              // Error message if any
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              // Credit code title
                              Text(
                                'CREDIT CODE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              // Credit code input field
                              TextField(
                                controller: _codeController,
                                decoration: InputDecoration(
                                  hintText: _hintText,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 20,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9\-]'),
                                  ),
                                  LengthLimitingTextInputFormatter(14),
                                ],
                                textCapitalization:
                                    TextCapitalization.characters,
                              ),
                              SizedBox(height: 32),
                              // Verify button
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                      _isVerifying ||
                                              _codeController.text
                                                  .trim()
                                                  .isEmpty
                                          ? null
                                          : _verifyCode,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith<
                                          Color
                                        >((states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return Color(
                                              0xFFE6E6E6,
                                            ); // Original light gray when disabled
                                          }
                                          return _codeController.text
                                                  .trim()
                                                  .isNotEmpty
                                              ? Color(
                                                0xFF202020,
                                              ) // Black when text is entered
                                              : Color(
                                                0xFFE6E6E6,
                                              ); // Original light gray otherwise
                                        }),
                                    foregroundColor: MaterialStateProperty.resolveWith<
                                      Color
                                    >((states) {
                                      if (states.contains(
                                        MaterialState.disabled,
                                      )) {
                                        return Colors
                                            .black38; // Dimmed text when disabled
                                      }
                                      return _codeController.text
                                              .trim()
                                              .isNotEmpty
                                          ? Colors
                                              .white // White text when code is entered
                                          : Colors
                                              .black87; // Original dark text otherwise
                                    }),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    elevation: MaterialStateProperty.all(0),
                                  ),
                                  child:
                                      _isVerifying
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              // Adjust color based on button background
                                              color:
                                                  _codeController.text
                                                          .trim()
                                                          .isNotEmpty
                                                      ? Colors.white
                                                      : Colors.black87,
                                            ),
                                          )
                                          : Text(
                                            'VERIFY',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                ),
                              ),

                              // Section for showing all promo codes
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'YOUR PROMO CODES',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                      color:
                                          _isLoadingPromoCodes
                                              ? Colors.grey
                                              : Colors.black87,
                                    ),
                                    onPressed:
                                        _isLoadingPromoCodes
                                            ? null
                                            : _loadPromoCodes,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Promo codes list
                              FutureBuilder<List<PromoCode>>(
                                future: _promoCodes,
                                builder: (context, snapshot) {
                                  if (_isLoadingPromoCodes ||
                                      snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                    return Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black87,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Error loading promo codes: ${snapshot.error}',
                                        style: TextStyle(color: Colors.red),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'No promo codes available',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }

                                  final promoCodes = snapshot.data!;
                                  
                                  // Sort the promo codes: unused first, then used codes
                                  final sortedCodes = List<PromoCode>.from(promoCodes);
                                  sortedCodes.sort((a, b) {
                                    // Sort by used status first (unused codes first)
                                    if (a.used != b.used) {
                                      return a.used ? 1 : -1; // False (unused) comes before True (used)
                                    }
                                    // Then sort by creation date (newest first)
                                    return b.createdAt.compareTo(a.createdAt);
                                  });
                                  
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: sortedCodes.length,
                                    itemBuilder: (context, index) {
                                      final code = sortedCodes[index];
                                      return GestureDetector(
                                        behavior:
                                            HitTestBehavior
                                                .opaque, // Makes the entire container tappable
                                        // Apply promo code to text field and trigger verification
                                        onTap:
                                            code.used
                                                ? null
                                                : () {
                                                  // Update text field with the promo code

                                                  setState(() {
                                                    _codeController.text =
                                                        code.creditCode;

                                                    // Show feedback that the code was applied
                                                    // ScaffoldMessenger.of(context).showSnackBar(
                                                    //   SnackBar(
                                                    //     content: Text('Code applied! Click VERIFY to use it.'),
                                                    //     duration: Duration(seconds: 2),
                                                    //     action: SnackBarAction(
                                                    //       label: 'VERIFY NOW',
                                                    //       onPressed: () {
                                                    //         // Call verify immediately if user clicks this button
                                                    //         if (!_isVerifying && _codeController.text.trim().isNotEmpty) {
                                                    //           _verifyCode();
                                                    //         }
                                                    //       },
                                                    //     ),
                                                    //   ),
                                                    // );
                                                  });
                                                },
                                        child: MouseRegion(
                                          cursor:
                                              code.used
                                                  ? SystemMouseCursors.basic
                                                  : SystemMouseCursors.click,
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 12),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color:
                                                  code.used
                                                      ? Colors.grey.shade100
                                                      : Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        code.creditCode,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 0.8,
                                                          color:
                                                              code.used
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            code.used
                                                                ? Colors.grey
                                                                : Color(
                                                                  0xFFE5AB39,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '${code.nbCredits} Credits',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                // Text(
                                                //   'Created: ${_formatDate(code.createdAt)}',
                                                //   style: TextStyle(
                                                //     fontSize: 12,
                                                //     color: Colors.grey,
                                                //   ),
                                                // ),
                                                //SizedBox(height: 4),
                                                // Row(
                                                //   mainAxisAlignment:
                                                //       MainAxisAlignment
                                                //           .spaceBetween,
                                                //   children: [
                                                //     Text(
                                                //       code.used
                                                //           ? 'Status: Used'
                                                //           : 'Status: Available',
                                                //       style: TextStyle(
                                                //         fontSize: 12,
                                                //         fontWeight:
                                                //             FontWeight.w500,
                                                //         color:
                                                //             code.used
                                                //                 ? Colors.red
                                                //                 : Colors.green,
                                                //       ),
                                                //     ),
                                                //     // Show "Tap to apply" indicator for available codes
                                                if (!code.used)
                                                  Text(
                                                    'Tap to apply',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.blue,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                //   ],
                                                // ),
                                                //
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                              SizedBox(height: 40),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

/// Custom painter that draws a curved line exactly matching the screenshot
class CurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Very light gray with low opacity as seen in screenshot
    final paint =
        Paint()
          ..color = Colors.grey.shade200.withOpacity(0.5)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    final path = Path();

    // Start from slightly off-screen to ensure full coverage
    path.moveTo(0, size.height * 0.9);

    // Create a wide, shallow arc that matches the screenshot exactly
    path.quadraticBezierTo(
      size.width * 0.5, // Control point x (middle of screen width)
      size.height *
          0.6, // Control point y (higher than the arc bottom for shallow curve)
      size.width, // End point x (right edge)
      size.height * 0.9, // End point y (same height as start)
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
