// lib/features/profile/data/repositories/profile_repository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  
  Future<ProfileModel> getProfile() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('Profile not found');
      }
      
      return ProfileModel.fromJson({...doc.data()!, 'id': userId});
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
  
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      await _firestore.collection('users').doc(userId).update({
        ...profile.toJson(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  Future<String> uploadProfileImage(File image) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
  
  Future<void> updateTrustScore(int score) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      await _firestore.collection('users').doc(userId).update({
        'trustScore': FieldValue.increment(score),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update trust score: $e');
    }
  }
  
  Future<void> updateInterests(List<String> interests) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      await _firestore.collection('users').doc(userId).update({
        'interests': interests,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update interests: $e');
    }
  }
  
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Delete user data
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete profile image if exists
      try {
        await _storage.ref().child('profile_images').child('$userId.jpg').delete();
      } catch (_) {
        // Ignore if no profile image exists
      }
      
      // Delete auth user
      await currentUser?.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}