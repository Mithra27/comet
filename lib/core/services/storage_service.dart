import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  
  // Upload image from file
  Future<String> uploadImage(File file, String folder) async {
    try {
      // Create a unique filename
      String fileName = '${_uuid.v4()}${path.extension(file.path)}';
      
      // Create storage reference
      Reference ref = _storage.ref().child(folder).child(fileName);
      
      // Upload file
      await ref.putFile(file);
      
      // Get download URL
      String downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
  
  // Upload image from XFile (ImagePicker result)
  Future<String> uploadImageFromPicker(XFile image, String folder) async {
    return uploadImage(File(image.path), folder);
  }
  
  // Delete image by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Get reference from URL
      Reference ref = _storage.refFromURL(imageUrl);
      
      // Delete the file
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }
  
  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      return await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      return await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
    } catch (e) {
      rethrow;
    }
  }
}