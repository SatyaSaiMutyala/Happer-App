import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/profile/bindings/code_credit_binding.dart';
import 'package:happer_app/features/profile/controllers/code_credit_controller.dart';
import 'package:happer_app/features/profile/models/promo_code_model.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';

class CodeCreditScreen extends StatefulWidget {
  const CodeCreditScreen({Key? key}) : super(key: key);

  @override
  _CodeCreditScreenState createState() => _CodeCreditScreenState();
}

class _CodeCreditScreenState extends State<CodeCreditScreen> {
  final TextEditingController _codeController = TextEditingController();
  late final CodeCreditController _ctrl;

  @override
  void initState() {
    super.initState();
    CodeCreditBinding().dependencies();
    _ctrl = Get.find<CodeCreditController>();

    // Pre-fill text field when myPromoCode loads
    ever(_ctrl.myPromoCode, (String? code) {
      if (code != null && code.isNotEmpty && _codeController.text.isEmpty) {
        _codeController.text = code;
      }
    });

    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Widget _buildCoinImage() {
    return SizedBox(
      width: 110,
      height: 110,
      child: Image.asset('assets/images/coin_icon.png', fit: BoxFit.contain),
    );
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseEnterCode)),
      );
      return;
    }
    final success = await _ctrl.verifyCode(code);
    if (success) {
      _codeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HapperAppBar(title: AppLocalizations.of(context).codeCreditTitle),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              left: -20,
              right: -20,
              height: MediaQuery.of(context).size.height * 0.4,
              child: CustomPaint(painter: CurvedLinePainter()),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    // Credit count
                    Obx(() => Text(
                          _ctrl.credits.value.toString(),
                          style: const TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE5AB39),
                          ),
                          textAlign: TextAlign.center,
                        )),
                    const SizedBox(height: 20),
                    Container(
                      alignment: Alignment.center,
                      child: _buildCoinImage(),
                    ),

                    // User's own promo code
                    Obx(() {
                      final promoCode = _ctrl.myPromoCode.value;
                      if (promoCode == null || promoCode.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          children: [
                            const Text(
                              'YOUR PROMO CODE',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade100,
                              ),
                              child: Text(
                                promoCode,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.5),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    Obx(() {
                      final hasCode = (_ctrl.myPromoCode.value?.isNotEmpty ?? false);
                      return SizedBox(height: hasCode ? 40 : 100);
                    }),

                    // Credit code input
                    const Text(
                      'CREDIT CODE',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        hintText: 'XXXX-XXXX-XXXX',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, letterSpacing: 1.5),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
                        LengthLimitingTextInputFormatter(14),
                      ],
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 32),

                    // Verify button
                    Obx(() => SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _ctrl.isVerifying.value ||
                                    _codeController.text.trim().isEmpty
                                ? null
                                : _verifyCode,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return const Color(0xFFE6E6E6);
                                }
                                return _codeController.text.trim().isNotEmpty
                                    ? const Color(0xFF202020)
                                    : const Color(0xFFE6E6E6);
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.black38;
                                }
                                return _codeController.text.trim().isNotEmpty
                                    ? Colors.white
                                    : Colors.black87;
                              }),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              elevation: WidgetStateProperty.all(0),
                            ),
                            child: _ctrl.isVerifying.value
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _codeController.text.trim().isNotEmpty
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  )
                                : const Text('VERIFY',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        )),

                    const SizedBox(height: 40),

                    // Promo codes list header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'YOUR PROMO CODES',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Obx(() => IconButton(
                              icon: Icon(
                                Icons.refresh,
                                color: _ctrl.isLoading.value ? Colors.grey : Colors.black87,
                              ),
                              onPressed: _ctrl.isLoading.value ? null : _ctrl.refresh,
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Promo codes list
                    Obx(() {
                      final codes = _ctrl.promoCodes;
                      if (codes.isEmpty) {
                        return Container(
                          height: 100,
                          alignment: Alignment.center,
                          child: const Text(
                            'No promo codes available',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: codes.length,
                        itemBuilder: (context, index) {
                          final code = codes[index];
                          return _buildPromoCodeItem(code);
                        },
                      );
                    }),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPromoCodeItem(PromoCode code) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: code.used
          ? null
          : () => setState(() => _codeController.text = code.creditCode),
      child: MouseRegion(
        cursor: code.used ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: code.used ? Colors.grey.shade100 : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      code.creditCode,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                        color: code.used ? Colors.grey : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: code.used ? Colors.grey : const Color(0xFFE5AB39),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${code.nbCredits} Credits',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!code.used)
                const Text(
                  'Tap to apply',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.9);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.6,
      size.width,
      size.height * 0.9,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
