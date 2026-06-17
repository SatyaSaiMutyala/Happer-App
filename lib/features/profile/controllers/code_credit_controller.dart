import 'package:get/get.dart';
import 'package:happer_app/core/network/api_exceptions.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/data/repositories/code_credit_repository.dart';
import 'package:happer_app/features/profile/models/promo_code_model.dart';

class CodeCreditController extends GetxController {
  final CodeCreditRepository _repo;

  CodeCreditController(this._repo);

  final isLoading = true.obs;
  final isVerifying = false.obs;
  final credits = 0.obs;
  final myPromoCode = Rxn<String>();
  final promoCodes = <PromoCode>[].obs;
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repo.getCodeCredits();
      credits.value = result.credits;
      myPromoCode.value = result.code;
    } catch (e) {
      errorMessage.value = 'Failed to load credits.';
    } finally {
      isLoading.value = false;
    }
    _loadPromoCodes();
  }

  Future<void> _loadPromoCodes() async {
    try {
      final list = await _repo.fetchPromoCodes();
      // Sort: unused first, then newest
      list.sort((a, b) {
        if (a.used != b.used) return a.used ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });
      promoCodes.value = list;
    } catch (_) {
      // Non-blocking — promo codes section shows empty on error
    }
  }

  @override
  Future<void> refresh() => loadAll();

  Future<bool> verifyCode(String code) async {
    if (code.trim().isEmpty) {
      showAppSnackBar('Please enter a code.', isSuccess: false);
      return false;
    }
    isVerifying.value = true;
    try {
      await _repo.verifyCode(code.trim());
      showAppSnackBar('Code verified successfully!', isSuccess: true);
      await loadAll();
      return true;
    } on AppException catch (e) {
      showAppSnackBar(e.message, isSuccess: false);
      return false;
    } catch (_) {
      showAppSnackBar('Invalid code. Please try again.', isSuccess: false);
      return false;
    } finally {
      isVerifying.value = false;
    }
  }
}
