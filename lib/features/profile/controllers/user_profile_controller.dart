import 'package:get/get.dart';
import 'package:happer_app/core/utils/snackbar.dart';
import 'package:happer_app/features/profile/data/repositories/user_profile_repository.dart';
import 'package:happer_app/features/profile/models/user_profile_model.dart';

class UserProfileController extends GetxController {
  final UserProfileRepository _repo;
  UserProfileController(this._repo);

  final isLoading = true.obs;
  final isUploading = false.obs;
  final user = Rxn<UserProfileModel>();
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      user.value = await _repo.fetchProfile();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadProfileImage(String filePath) async {
    isLoading.value = true;
    try {
      user.value = await _repo.uploadProfileImage(filePath);
    } finally {
      isLoading.value = false;
    }
  }

  final isSaving = false.obs;

  Future<bool> completeEsign() async {
    try {
      await _repo.completeEsign();
      // Refresh profile so isEsignCompleted updates and "Activer" button disappears
      await fetchProfile();
      return true;
    } catch (e) {
      showAppSnackBar(e.toString(), isSuccess: false);
      return false;
    }
  }

  Future<bool> editProfile({
    required String firstName,
    required String lastName,
    required String username,
    String? dob,
    int? gender,
    String? bio,
    String? instagramLink,
    String? mobileNumber,
    String? countryCode,
    String? streetAddress,
    String? postalCode,
    String? city,
  }) async {
    isSaving.value = true;
    try {
      final current = user.value;
      user.value = await _repo.editProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        picture: current?.picture,
        dob: dob,
        gender: gender,
        bio: bio,
        instagramLink: instagramLink,
        mobileNumber: mobileNumber,
        countryCode: countryCode,
        streetAddress: streetAddress,
        postalCode: postalCode,
        city: city,
      );
      showAppSnackBar('Profil mis à jour avec succès');
      return true;
    } catch (e) {
      showAppSnackBar(e.toString(), isSuccess: false);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
