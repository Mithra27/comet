// lib/features/profile/controller/profile_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;
  final RxList<String> interests = <String>[].obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  
  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }
  
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      profile.value = await _profileRepository.getProfile();
      interests.value = profile.value?.interests ?? [];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? apartment,
  }) async {
    try {
      if (profile.value == null) return;
      
      isLoading.value = true;
      
      final updatedProfile = profile.value!.copyWith(
        name: name ?? profile.value!.name,
        phone: phone ?? profile.value!.phone,
        apartment: apartment ?? profile.value!.apartment,
        updatedAt: Timestamp.now(),
      );
      
      await _profileRepository.updateProfile(updatedProfile);
      profile.value = updatedProfile;
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      isEditing.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> uploadProfileImage() async {
    try {
      if (selectedImage.value == null) return;
      
      isLoading.value = true;
      
      final imageUrl = await _profileRepository.uploadProfileImage(selectedImage.value!);
      
      if (profile.value == null) return;
      
      final updatedProfile = profile.value!.copyWith(
        imageUrl: imageUrl,
        updatedAt: Timestamp.now(),
      );
      
      await _profileRepository.updateProfile(updatedProfile);
      profile.value = updatedProfile;
      selectedImage.value = null;
      
      Get.snackbar(
        'Success',
        'Profile image updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload profile image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateInterests(List<String> newInterests) async {
    try {
      isLoading.value = true;
      
      await _profileRepository.updateInterests(newInterests);
      
      if (profile.value != null) {
        profile.value = profile.value!.copyWith(interests: newInterests);
      }
      
      interests.value = newInterests;
      
      Get.snackbar(
        'Success',
        'Interests updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update interests: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteAccount() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      isLoading.value = true;
      
      await _profileRepository.deleteAccount();
      
      Get.offAllNamed('/login');
      
      Get.snackbar(
        'Success',
        'Account deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
  }
}