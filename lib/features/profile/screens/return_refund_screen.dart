// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ReturnRefundScreen extends StatelessWidget {
//   const ReturnRefundScreen({Key? key}) : super(key: key);

//   static const String supportEmail = 'contact@happer.fr';
//   static const String whatsappNumber = '33695764871'; // ✅ your admin WhatsApp number here (with country code)
//   static const String emailSubject = 'Return and Refund Request';
//   static const String emailBody = '';
//   static const String whatsappMessage =
//       'Hello, I would like to request a return/refund for my order.';

//   // --- MAIN EMAIL LAUNCH FUNCTION ---
//   Future<void> _sendEmail(BuildContext context) async {
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: supportEmail,
//       queryParameters: {
//         'subject': emailSubject,
//         'body': emailBody,
//       },
//     );

//     try {
//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(emailUri, mode: LaunchMode.externalApplication);
//       } else {
//         _showContactOptionsDialog(context);
//       }
//     } catch (e) {
//       _showContactOptionsDialog(context);
//     }
//   }

//   // --- LAUNCH WHATSAPP ---
//   Future<void> _openWhatsApp() async {
//     final Uri whatsappUri = Uri.parse(
//         'https://wa.me/${whatsappNumber.replaceAll('+', '')}?text=${Uri.encodeComponent(whatsappMessage)}');

//     if (await canLaunchUrl(whatsappUri)) {
//       await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
//     } else {
//       debugPrint('Could not launch WhatsApp');
//     }
//   }

//   // --- CUSTOM DIALOG WITH ICONS ---
//   void _showContactOptionsDialog(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Contactez-nous',
//                 style: TextStyle(
//                   fontFamily: 'Lato',
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // EMAIL ICON
//                   GestureDetector(
//                     onTap: () async {
//                       Navigator.pop(context);
//                       await _sendEmailDirect();
//                     },
//                     child: Column(
//                       children: const [
//                         CircleAvatar(
//                           radius: 28,
//                           backgroundColor: Colors.black,
//                           child: Icon(Icons.email, color: Colors.white, size: 28),
//                         ),
//                         SizedBox(height: 8),
//                         Text('Email', style: TextStyle(fontSize: 14)),
//                       ],
//                     ),
//                   ),

//                   // WHATSAPP ICON
//                   GestureDetector(
//                     onTap: () async {
//                       Navigator.pop(context);
//                       await _openWhatsApp();
//                     },
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 28,
//                           backgroundColor: Colors.green,
//                           child: Icon(Icons.chat, color: Colors.white, size: 28),
//                         ),
//                         SizedBox(height: 8),
//                         Text('WhatsApp', style: TextStyle(fontSize: 14)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // --- DIRECT EMAIL (for icon tap) ---
//   Future<void> _sendEmailDirect() async {
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: supportEmail,
//       queryParameters: {
//         'subject': emailSubject,
//         'body': emailBody,
//       },
//     );

//     if (await canLaunchUrl(emailUri)) {
//       await launchUrl(emailUri, mode: LaunchMode.externalApplication);
//     } else {
//       debugPrint('Could not launch email client');
//     }
//   }

//   // Future<void> _sendEmail(BuildContext context) async {
//   //   const String email = 'contact@happer.fr';
//   //   const String subject = 'Return and Refund Request';
//   //   const String body = 'Hello,\n\nI would like to request a return/refund for my order.\n\nThank you.';
    
//   //   final Uri emailLaunchUri = Uri(
//   //     scheme: 'mailto',
//   //     path: email,
//   //     queryParameters: {
//   //       'subject': subject,
//   //       'body': body,
//   //     },
//   //   );
    
//   //   try {
//   //     // First attempt to use the URI scheme
//   //     if (await canLaunchUrl(emailLaunchUri)) {
//   //       final bool launched = await launchUrl(
//   //         emailLaunchUri,
//   //         mode: LaunchMode.externalApplication,
//   //       );
        
//   //       if (!launched) {
//   //         // Try alternative launch method
//   //         await _tryAlternativeEmailLaunch(context, email, subject, body);
//   //       }
//   //     } else {
//   //       // Show dialog with options
//   //       _showEmailOptionsDialog(context, email, subject, body);
//   //     }
//   //   } catch (e) {
     
//   //     _showEmailOptionsDialog(context, email, subject, body);
//   //   }
//   // }
  
//   Future<void> _tryAlternativeEmailLaunch(BuildContext context, String email, String subject, String body) async {
//     // Try different URL format
//     final String mailtoUrl = 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
//     final Uri alternativeUri = Uri.parse(mailtoUrl);
    
//     try {
//       final bool launched = await launchUrl(
//         alternativeUri,
//         mode: LaunchMode.platformDefault,
//       );
      
//       if (!launched) {
//         _showEmailOptionsDialog(context, email, subject, body);
//       }
//     } catch (e) {
   
//       _showEmailOptionsDialog(context, email, subject, body);
//     }
//   }
  
//   void _showEmailOptionsDialog(BuildContext context, String email, String subject, String body) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Email Options'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Could not launch email client. Would you like to:'),
//             const SizedBox(height: 16),
//             Text('Email: $email', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Text('Subject: $subject'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Clipboard.setData(ClipboardData(text: email));
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Email address copied to clipboard')),
//               );
//             },
//             child: const Text('Copy Email'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           'RETURN AND REFUND',
//           style: TextStyle(
//             fontFamily: 'Lato',
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//             letterSpacing: 0.0,
//             color: Colors.black,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           const Divider(height: 1, thickness: 1),
//           const SizedBox(height: 30),
//           const Text(
//             'Procédure',
//             style: TextStyle(
//               fontFamily: 'Lato',
//               fontWeight: FontWeight.w600,
//               fontSize: 18,
//               color: Colors.black,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 30),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 30),
//             child: const Text(
//               'Pour toute question, besoin ou disfonctionnalité rencontré, merci de contacter le service client via contact@happer.fr.',
//               style: TextStyle(
//                 fontFamily: 'Lato',
//                 fontSize: 16,
//                 color: Colors.black87,
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: 30),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 30),
//             child: const Text(
//               'Les délais de réponses sont en moyenne de 72h.',
//               style: TextStyle(
//                 fontFamily: 'Lato',
//                 fontSize: 16,
//                 color: Colors.black87,
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const Spacer(),
//           // Container(
//           //   width: double.infinity,
//           //   margin: const EdgeInsets.only(bottom: 30),
//           //   padding: const EdgeInsets.symmetric(horizontal: 20),
//           //   child: ElevatedButton(
//           //     onPressed: () => _sendEmail(context),
//           //     style: ElevatedButton.styleFrom(
//           //       backgroundColor: Colors.black,
//           //       foregroundColor: Colors.white,
//           //       padding: const EdgeInsets.symmetric(vertical: 15),
//           //       shape: const RoundedRectangleBorder(
//           //         borderRadius: BorderRadius.zero,
//           //       ),
//           //     ),
//           //     child: const Text(
//           //       'CONTACTER PAR E-MAIL',
//           //       style: TextStyle(
//           //         fontFamily: 'Lato',
//           //         fontWeight: FontWeight.bold,
//           //         fontSize: 14,
//           //       ),
//           //     ),
//           //   ),
//           // ),
//           Container(
//             width: double.infinity,
//             margin: const EdgeInsets.only(bottom: 30),
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: ElevatedButton(
//               onPressed: () => _showContactOptionsDialog(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.zero,
//                 ),
//               ),
//               child: const Text(
//                 'CONTACTER PAR E-MAIL',
//                 style: TextStyle(
//                   fontFamily: 'Lato',
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:happer_app/l10n/app_localizations.dart';

class ReturnRefundScreen extends StatelessWidget {
  const ReturnRefundScreen({Key? key}) : super(key: key);

  static const String supportEmail = 'support@happer.fr';
  static const String whatsappNumber = '33695764871';
  static const String emailSubject = '';
  static const String emailBody ='';
  static const String whatsappMessage =
      '';

  // EMAIL
  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': emailSubject,
        'body': emailBody,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        _copyEmail(context);
      }
    } catch (_) {
      _copyEmail(context);
    }
  }

  // WHATSAPP
  Future<void> _openWhatsApp() async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(whatsappMessage)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  // COPY EMAIL FALLBACK
  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: supportEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).returnAndRefundTitle),
      body: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 30),

          const Text(
            'Procédure',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text(
              'Pour toute question, besoin ou disfonctionnalité rencontré, merci de contacter le service client via support@happer.fr.',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: const Text(
              'Les délais de réponses sont en moyenne de 72h.',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // const Spacer(),
          const SizedBox(height: 40,),

          /// 🔹 DIRECT ICONS (NO MODAL)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // EMAIL
              GestureDetector(
                onTap: () => _sendEmail(context),
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.email, color: Colors.white, size: 28),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email',
                      style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                    ),
                  ],
                ),
              ),

              // WHATSAPP
              GestureDetector(
                onTap: _openWhatsApp,
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.chat, color: Colors.white, size: 28),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'WhatsApp',
                      style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
