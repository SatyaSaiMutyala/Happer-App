import 'package:get/get.dart';
import 'package:happer_app/features/profile/data/repositories/address_repository.dart';
import 'package:happer_app/features/profile/models/address_model.dart';

class AddressController extends GetxController {
  final AddressRepository _repo;

  AddressController(this._repo);

  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repo.getAllAddresses();
      addresses.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAddress(Map<String, dynamic> body) async {
    isSaving.value = true;
    errorMessage.value = null;
    try {
      await _repo.addAddress(body);
      await fetchAddresses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> editAddress(String id, Map<String, dynamic> body) async {
    isSaving.value = true;
    errorMessage.value = null;
    try {
      await _repo.editAddress(id, body);
      await fetchAddresses();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    errorMessage.value = null;
    try {
      await _repo.deleteAddress(id);
      addresses.removeWhere((a) => a.id == id);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
