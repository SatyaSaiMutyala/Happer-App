// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:happer_app/creator/ui/selfie_details_screen.dart';
// import 'package:happer_app/profile/api/profile_api.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ImageGridScreen extends StatefulWidget {
//   final String userId;

//   ImageGridScreen({required this.userId});

//   @override
//   State<ImageGridScreen> createState() => _ImageGridScreenState();
// }

// class _ImageGridScreenState extends State<ImageGridScreen> {
//   Map<String, dynamic>? userProfile;
//   List<dynamic> userSelfies = [];
//   bool isLoading = true;
//   bool isRefreshing = false;
//   int followersCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     final profileApi = ProfileApiService();
//     profileApi.fetchCurrentUserProfile().then((data) {
//       print('Current user profile fetched successfully');
//     }).catchError((error) {
//       print('Error fetching current user profile: $error');
//     });
//     fetchFollowersCount();
//     fetchUserProfile();
//     fetchUserSelfies();
//   }

//   Future<void> fetchUserSelfies() async {
//     try {
//       final profileApi = ProfileApiService();
//       final selfies = await profileApi.fetchUserProfileSelfies(widget.userId);

//       setState(() {
//         userSelfies = selfies;
//       });
//     } catch (e) {}
//   }

//   Future<void> fetchUserProfile() async {
//     try {
//       final profileApi = ProfileApiService();
//       final data = await profileApi.fetchUserProfile(widget.userId);

//       if (data.containsKey('selfies')) {
//       } else {
//         // Look for other keys that might contain images
//         data.keys.forEach((key) {
//           if (data[key] is List) {}
//         });
//       }

//       setState(() {
//         userProfile = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchFollowersCount() async {
//     try {
//       final profileApi = ProfileApiService();
//       final count = await profileApi.followersByUserId(widget.userId);
//       setState(() {
//         followersCount = count;
//       });
//     } catch (e) {}
//   }

//   Future<void> refreshData() async {
//     setState(() {
//       isRefreshing = true;
//     });

//     try {
//       // Refresh all data
//       await Future.wait([
//         fetchUserSelfies(),
//         fetchUserProfile(),
//         fetchFollowersCount(),
//       ]);
//     } catch (e) {
//     } finally {
//       setState(() {
//         isRefreshing = false;
//       });
//     }
//   }

//   void _shareContent() {
//     final userName = userProfile != null
//         ? '${userProfile!['first_name'] ?? ''} ${userProfile!['last_name'] ?? ''}'
//             .trim()
//         : 'this creator';

//     final userId = widget.userId;
//     final deepLink =
//         'https://newapi.happer.fr/api/selfies/profile?userId=$userId';

//     final shareText =
//         'Check out $userName’s Happer profile!\n\nView it here 👇\n$deepLink';

//     Share.share(shareText, subject: 'View $userName on Happer');
//   }

//   Future<void> _onImageTap(BuildContext context, String selfieId) async {
//     print('Yeah man im touching ......!');
//     // if (AppManager.isLoginAsGuest) {
//     //   showAppSnackBar('Please Login In First', isSuccess: false);
//     //   return;
//     // }
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SelfieDetailsScreen(selfieId: selfieId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: Text(
//           'SHOP THE PICS',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 10),
//             child: CircleAvatar(
//               radius: 20,
//               backgroundColor: Colors.black.withOpacity(0.5),
//               child: IconButton(
//                 icon: Icon(
//                   Icons.share,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 onPressed: _shareContent,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : userProfile == null
//               ? Center(child: Text('Failed to load user profile'))
//               : Column(children: [
//                   SizedBox(height: 20),
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: NetworkImage(
//                       userProfile!['picture'] ?? '',
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         userProfile!['username'] ?? 'Unknown',
//                         style: TextStyle(
//                           fontFamily: 'Lato',
//                           fontWeight: FontWeight.w800,
//                           fontSize: 16,
//                           height: 1.0,
//                           letterSpacing: 0.0,
//                         ),
//                       ),
//                       SizedBox(width: 5),
//                       if (userProfile?['userType'] == 1)
//                         Icon(
//                           Icons.verified,
//                           color: Colors.black,
//                           size: 18,
//                         ),
//                       if (userProfile?['instagram_link'] != null &&
//                           userProfile!['instagram_link'].isNotEmpty)
//                         IconButton(
//                             icon: Image.asset(
//                               'assets/images/insta_icon.png', // make sure this asset exists
//                               height: 20,
//                               width: 20,
//                             ),
//                             onPressed: () async {
//                               final username = userProfile!['instagram_link'];
//                               final appUrl = Uri.parse(
//                                   'instagram://user?username=$username');
//                               final webUrl =
//                                   Uri.parse('https://instagram.com/$username');

//                               try {
//                                 if (await canLaunchUrl(appUrl)) {
//                                   // Open in Instagram app if installed
//                                   await launchUrl(appUrl,
//                                       mode: LaunchMode.externalApplication);
//                                 } else if (await canLaunchUrl(webUrl)) {
//                                   // Fallback to browser
//                                   await launchUrl(webUrl,
//                                       mode: LaunchMode.externalApplication);
//                                 } else {
//                                   throw 'Cannot launch';
//                                 }
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                       content: Text(
//                                           'Could not launch Instagram profile')),
//                                 );
//                               }
//                             }),
//                     ],
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     followersCount == 0
//                         ? ''
//                         : followersCount == 1
//                             ? '$followersCount FOLLOWER'
//                             : '$followersCount FOLLOWERS',
//                     style: TextStyle(
//                       fontFamily: 'Lato',
//                       fontWeight: FontWeight.w900,
//                       fontSize: 12,
//                       height: 1.0,
//                       letterSpacing: 0.0,
//                       color: Color(0xFFFF465A),
//                       textBaseline: TextBaseline.alphabetic,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (userProfile != null) {
//                         final profileApi = ProfileApiService();
//                         final prefs = await SharedPreferences.getInstance();

//                         final followerId = prefs.getString('myUserId');
//                         if (followerId == null) {
//                           return;
//                         }
//                         try {
//                           if (userProfile!['isFollowedByMe'] == true) {
//                             await profileApi.unfollowUser(widget.userId);
//                             setState(() {
//                               userProfile!['isFollowedByMe'] = false;
//                             });
//                             await fetchFollowersCount();
//                           } else {
//                             await profileApi.followUser(
//                               widget.userId,
//                               followerId,
//                             );
//                             setState(() {
//                               userProfile!['isFollowedByMe'] = true;
//                             });
//                             await fetchFollowersCount();
//                           }
//                         } catch (e) {}
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       fixedSize: Size(107, 35),
//                     ),
//                     child: Text(
//                       userProfile != null &&
//                               userProfile!['isFollowedByMe'] == true
//                           ? 'Unfollow'
//                           : 'Follow',
//                       style: TextStyle(
//                         fontFamily: 'Lato',
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                         height: 1.0,
//                         letterSpacing: 0.0,
//                         color: Color(0xFFFFFFFF),
//                         textBaseline: TextBaseline.alphabetic,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Divider(thickness: 1),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: RefreshIndicator(
//                         onRefresh: refreshData,
//                         child: userSelfies.isNotEmpty
//                             ? GridView.builder(
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   crossAxisSpacing: 8.0,
//                                   mainAxisSpacing: 8.0,
//                                 ),
//                                 itemCount: userSelfies.length,
//                                 itemBuilder: (context, index) {
//                                   final selfie = userSelfies[index];
//                                   String imageUrl = '';
//                                   if (selfie is Map) {
//                                     imageUrl = selfie['image'] ??
//                                         selfie['url'] ??
//                                         selfie['picture'] ??
//                                         selfie['src'] ??
//                                         selfie['imageUrl'] ??
//                                         '';
//                                     if (imageUrl.isEmpty) {
//                                       selfie.forEach((key, value) {
//                                         if (value is String &&
//                                             (value.endsWith('.jpg') ||
//                                                 value.endsWith('.jpeg') ||
//                                                 value.endsWith('.png') ||
//                                                 value.contains('http'))) {
//                                           imageUrl = value;
//                                         }
//                                       });
//                                     }
//                                   } else if (selfie is String) {
//                                     imageUrl = selfie;
//                                   }

//                                   String selfieId = '';
//                                   if (selfie is Map) {
//                                     selfieId = selfie['_id'] ??
//                                         selfie['id'] ??
//                                         selfie['sId'] ??
//                                         selfie['selfieId'] ??
//                                         selfie['userId'] ??
//                                         '';
//                                   }

//                                   return GestureDetector(
//                                     onTap: () => _onImageTap(context, selfieId),
//                                     child: Card(
//                                       clipBehavior: Clip.antiAlias,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: AspectRatio(
//                                         aspectRatio: 1,
//                                         child: CachedNetworkImage(
//                                           imageUrl: imageUrl,
//                                           fit: BoxFit.cover,
//                                           placeholder: (context, url) =>
//                                               Shimmer.fromColors(
//                                             baseColor: Colors.grey.shade300,
//                                             highlightColor:
//                                                 Colors.grey.shade100,
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                 color: Colors.grey.shade300,
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                               ),
//                                             ),
//                                           ),
//                                           errorWidget: (context, url, error) =>
//                                               Container(
//                                             height: 150,
//                                             color: Colors.grey[300],
//                                             child: const Center(
//                                               child: Icon(Icons.broken_image,
//                                                   size: 50),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               )
//                             : Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//                                 highlightColor: Colors.grey.shade100,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade300,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ]),
//     );
//   }

//   void _navigateToShopTheStyleScreen(dynamic selfie) {
//     String selfieId = '';
//     String categoryId = '';

//     if (selfie is Map) {
//       selfieId = selfie['_id'] ?? '';
//       // Try to get categoryId from selfie or nested fields
//       categoryId = selfie['category_id'] ?? selfie['categoryId'] ?? '';
//       // If categoryId is nested in a product/item, try to extract it
//       if (categoryId.isEmpty && selfie['product'] is Map) {
//         categoryId = selfie['product']['category_id'] ?? '';
//       } else if (categoryId.isEmpty && selfie['item'] is Map) {
//         categoryId = selfie['item']['category_id'] ?? '';
//       }
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SelfieDetailsScreen(
//           selfieId: selfieId,
//         ),
//       ),
//     );
//   } // TODO: Replace with actual navigation to product/shopping screen
// }

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:happer_app/creator/ui/selfie_details_screen.dart';
import 'package:happer_app/profile/api/profile_api.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Assuming ProfileApiService and SelfieDetailsScreen are defined elsewhere.
// I will not include them here to keep the focus on the ImageGridScreen UI.

class ImageGridScreen extends StatefulWidget {
  final String userId;

  ImageGridScreen({required this.userId});

  @override
  State<ImageGridScreen> createState() => _ImageGridScreenState();
}

class _ImageGridScreenState extends State<ImageGridScreen> {
  Map<String, dynamic>? userProfile;
  List<dynamic> userSelfies = [];
  bool isLoading = true; // Use this to track initial profile load
  bool isSelfiesLoading = true; // NEW: Track selfies loading separately
  bool isRefreshing = false;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    // Profile API calls
    final profileApi = ProfileApiService();
    profileApi.fetchCurrentUserProfile().then((data) {
      print('Current user profile fetched successfully');
    }).catchError((error) {
      print('Error fetching current user profile: $error');
    });
    fetchFollowersCount();
    fetchUserProfile();
    // Start fetching selfies immediately, separate from profile header loading
    fetchUserSelfies();
  }

  Future<void> fetchUserSelfies() async {
    setState(() {
      isSelfiesLoading = true; // Set loading to true before fetch
    });
    try {
      final profileApi = ProfileApiService();
      final selfies = await profileApi.fetchUserProfileSelfies(widget.userId);

      setState(() {
        userSelfies = selfies;
      });
    } catch (e) {
      // Handle error if necessary
    } finally {
      setState(() {
        isSelfiesLoading = false; // Set loading to false after fetch/error
      });
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final profileApi = ProfileApiService();
      final data = await profileApi.fetchUserProfile(widget.userId);

      // ... existing profile data processing ...

      setState(() {
        userProfile = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFollowersCount() async {
    try {
      final profileApi = ProfileApiService();
      final count = await profileApi.followersByUserId(widget.userId);
      setState(() {
        followersCount = count;
      });
    } catch (e) {}
  }

  Future<void> refreshData() async {
    setState(() {
      isRefreshing = true;
      isSelfiesLoading = true; // Ensure selfies loading is true on refresh
    });

    try {
      // Refresh all data
      await Future.wait([
        fetchUserSelfies(),
        fetchUserProfile(),
        fetchFollowersCount(),
      ]);
    } catch (e) {
    } finally {
      setState(() {
        isRefreshing = false;
        isSelfiesLoading = false;
      });
    }
  }

  void _shareContent() {
    final userName = userProfile != null
        ? '${userProfile!['first_name'] ?? ''} ${userProfile!['last_name'] ?? ''}'
            .trim()
        : 'this creator';

    final userId = widget.userId;
    final encodedId = base64Url.encode(utf8.encode(userId));
    final deepLink =
        'https://newapi.happer.fr/store/profile/$encodedId';

    final shareText =
        "J’ai découvert la boutique de mode de $userName sur Happer et j’adore son style ✨\nJe te partage son profil ! $deepLink";

    try {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final origin = box.localToGlobal(Offset.zero) & box.size;
        Share.share(shareText,
            subject: 'View $userName on Happer', sharePositionOrigin: origin);
      } else {
        Share.share(shareText, subject: 'View $userName on Happer');
      }
    } catch (e) {
      Share.share(shareText, subject: 'View $userName on Happer');
    }
  }

  Future<void> _onImageTap(BuildContext context, String selfieId) async {
    print('Yeah man im touching ......!');
    // if (AppManager.isLoginAsGuest) {
    //   showAppSnackBar('Please Login In First', isSuccess: false);
    //   return;
    // }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfieDetailsScreen(selfieId: selfieId),
      ),
    );
  }

  // NEW WIDGET: Shimmer loading state for the image grid
  Widget _buildShimmerGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.0,
        mainAxisSpacing: 3.0,
        childAspectRatio: 0.66,
      ),
      itemCount: 8, // Display a few placeholder boxes
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Function to format the followers count as seen in the image (e.g., 2.6K)
    String formatFollowers(int count) {
      if (count >= 1000) {
        double kCount = count / 1000.0;
        // Format to one decimal place if not a whole number
        String formatted =
            kCount.toStringAsFixed(kCount.truncateToDouble() == kCount ? 0 : 1);
        return '${formatted}K';
      }
      return count.toString();
    }

    // Function to launch Instagram
    void _launchInstagram() async {
      if (userProfile?['instagram_link'] != null &&
          userProfile!['instagram_link'].isNotEmpty) {
        final username = userProfile!['instagram_link'];
        // Assume instagram_link is the username, not the full URL.
        final appUrl = Uri.parse('instagram://user?username=$username');
        final webUrl = Uri.parse('https://instagram.com/$username');

        try {
          if (await canLaunchUrl(appUrl)) {
            await launchUrl(appUrl, mode: LaunchMode.externalApplication);
          } else if (await canLaunchUrl(webUrl)) {
            await launchUrl(webUrl, mode: LaunchMode.externalApplication);
          } else {
            throw 'Cannot launch';
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch Instagram profile')),
          );
        }
      }
    }

    // Function to handle the follow/unfollow action
    void _toggleFollow() async {
      if (userProfile != null) {
        final profileApi = ProfileApiService();
        final prefs = await SharedPreferences.getInstance();

        final followerId = prefs.getString('myUserId');
        if (followerId == null) {
          return;
        }
        try {
          if (userProfile!['isFollowedByMe'] == true) {
            await profileApi.unfollowUser(widget.userId);
            setState(() {
              userProfile!['isFollowedByMe'] = false;
            });
            await fetchFollowersCount();
          } else {
            await profileApi.followUser(
              widget.userId,
              followerId,
            );
            setState(() {
              userProfile!['isFollowedByMe'] = true;
            });
            await fetchFollowersCount();
          }
        } catch (e) {}
      }
    }

    // Determine the content for the image grid area
    Widget gridContent;
    if (isSelfiesLoading) {
      gridContent = _buildShimmerGrid();
    } else if (userSelfies.isNotEmpty) {
      gridContent = GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3.0,
          mainAxisSpacing: 3.0,
          childAspectRatio: 0.66,
        ),
        itemCount: userSelfies.length,
        itemBuilder: (context, index) {
          final selfie = userSelfies[index];
          String imageUrl = '';
          if (selfie is Map) {
            imageUrl = selfie['image'] ??
                selfie['url'] ??
                selfie['picture'] ??
                selfie['src'] ??
                selfie['imageUrl'] ??
                '';
            if (imageUrl.isEmpty) {
              selfie.forEach((key, value) {
                if (value is String &&
                    (value.endsWith('.jpg') ||
                        value.endsWith('.jpeg') ||
                        value.endsWith('.png') ||
                        value.contains('http'))) {
                  imageUrl = value;
                }
              });
            }
          } else if (selfie is String) {
            imageUrl = selfie;
          }

          String selfieId = '';
          if (selfie is Map) {
            selfieId = selfie['_id'] ??
                selfie['id'] ??
                selfie['sId'] ??
                selfie['selfieId'] ??
                selfie['userId'] ??
                '';
          }

          return GestureDetector(
            onTap: () => _onImageTap(context, selfieId),
            child: ClipRRect(
              // Use ClipRRect directly for the image
              borderRadius: BorderRadius.circular(0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    color: Colors.grey.shade300,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 0),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      gridContent = Center(
        child: Text('No images found.'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          userProfile?['users_type'] != 1 ? 'PROFIL' : 'BOUTIQUE CRÉATEUR',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Global loading for the whole screen
          : userProfile == null
              ? Center(child: Text('Failed to load user profile'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Picture
                          (userProfile!['picture'] != null &&
                                  userProfile!['picture'].toString().isNotEmpty)
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        userProfile!['picture'],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                          SizedBox(width: 16),
                          // User Info and Buttons
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      userProfile!['username'] ??
                                          userProfile!['first_name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    // Verified icon
                                    if (userProfile?['users_type'] == 1)
                                      Icon(
                                        Icons.verified,
                                        color: Colors.black,
                                        size: 22,
                                      ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${userSelfies.length} POSTS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${formatFollowers(followersCount)} FOLLOWERS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    // Follow / Unfollow Button (responsive)
                                    Expanded(
                                      child: SizedBox(
                                        height: 35,
                                        child: ElevatedButton(
                                          onPressed: _toggleFollow,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: userProfile?[
                                                        'isFollowedByMe'] ==
                                                    true
                                                ? Colors.grey
                                                : Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              userProfile?['isFollowedByMe'] ==
                                                      true
                                                  ? 'Unfollow'
                                                  : 'Suivre',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    if (userProfile?['instagram_link']
                                            ?.isNotEmpty ==
                                        true)
                                      _squareIconButton(
                                        icon: FontAwesomeIcons.instagram,
                                        onTap: _launchInstagram,
                                      ),

                                    const SizedBox(width: 8),

                                    _squareIconButton(
                                      icon: Icons.share,
                                      onTap: _shareContent,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (userProfile?['users_type'] == 1 &&
                        userProfile?['bio'] != null &&
                        userProfile!['bio'].toString().trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: SizedBox(
                          width: double.infinity, // 👈 forces left alignment
                          child: Text(
                            userProfile!['bio'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start, // 👈 left aligned
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    Divider(thickness: 1, height: 1), // Divider added
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 2.0),
                        child: RefreshIndicator(
                          onRefresh: refreshData,
                          child: gridContent, // Use the determined grid content
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  void _navigateToShopTheStyleScreen(dynamic selfie) {
    String selfieId = '';
    String categoryId = '';

    if (selfie is Map) {
      selfieId = selfie['_id'] ?? '';
      // Try to get categoryId from selfie or nested fields
      categoryId = selfie['category_id'] ?? selfie['categoryId'] ?? '';
      // If categoryId is nested in a product/item, try to extract it
      if (categoryId.isEmpty && selfie['product'] is Map) {
        categoryId = selfie['product']['category_id'] ?? '';
      } else if (categoryId.isEmpty && selfie['item'] is Map) {
        categoryId = selfie['item']['category_id'] ?? '';
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfieDetailsScreen(
          selfieId: selfieId,
        ),
      ),
    );
  }

  Widget _squareIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 35,
      height: 35,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
