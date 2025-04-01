// lib/features/community/data/repositories/community_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// Use the correct path and assume CommunityModel class is defined correctly in the model file
import '../models/community_model.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'communities'; // Your Firestore collection name

  // Matches controller expectation: Future<List<CommunityModel>> getAvailableCommunities()
  Future<List<CommunityModel>> getAvailableCommunities() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionPath).get();
      // Ensure CommunityModel.fromMap exists and model file is error-free
      return snapshot.docs
          .map((doc) => CommunityModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching available communities: $e');
      rethrow;
    }
  }

  // Matches controller expectation: Future<List<CommunityModel>> getUserCommunities(String userId)
  Future<List<CommunityModel>> getUserCommunities(String userId) async {
    if (userId.isEmpty) {
      print("Warning: getUserCommunities called with empty userId.");
      return [];
    }
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .where('memberIds', arrayContains: userId) // Assumes 'memberIds' array field
          .get();
      // Ensure CommunityModel.fromMap exists and model file is error-free
      return snapshot.docs
          .map((doc) => CommunityModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching user communities for $userId: $e');
      rethrow;
    }
  }

  // Matches controller expectation: Future<CommunityModel?> getCommunityById(String communityId)
  Future<CommunityModel?> getCommunityById(String communityId) async {
    if (communityId.isEmpty) return null;
    try {
      final DocumentSnapshot doc = await _firestore.collection(_collectionPath).doc(communityId).get();
      if (!doc.exists) {
        print("Community with ID $communityId not found.");
        return null;
      }
      // Ensure CommunityModel.fromMap exists and model file is error-free
      return CommunityModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error fetching community by ID $communityId: $e');
      rethrow;
    }
  }

  // Matches controller expectation: Future<void> joinCommunity({required String userId, ...})
  Future<void> joinCommunity({
    required String userId,
    required String communityId,
    required String apartmentNumber,
  }) async {
    if (userId.isEmpty) throw Exception("User ID is required.");
    if (communityId.isEmpty) throw Exception("Community ID is required.");

    try {
      final communityRef = _firestore.collection(_collectionPath).doc(communityId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(communityRef);
        if (!snapshot.exists) {
          throw Exception("Community '$communityId' does not exist!");
        }
        transaction.update(communityRef, {
          'memberIds': FieldValue.arrayUnion([userId]), // Ensure field exists
          'memberCount': FieldValue.increment(1),     // Ensure field exists
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print("Apartment number for joining user $userId: $apartmentNumber (Log/Store if needed)");
      });
      print('User $userId joined community $communityId successfully.');
    } catch (e) {
      print('Error joining community $communityId for user $userId: $e');
      rethrow;
    }
  }

  // Matches controller expectation: Future<void> leaveCommunity({required String userId, ...})
  Future<void> leaveCommunity({
    required String userId,
    required String communityId,
  }) async {
    if (userId.isEmpty) throw Exception("User ID is required.");
    if (communityId.isEmpty) throw Exception("Community ID is required.");

    try {
      final communityRef = _firestore.collection(_collectionPath).doc(communityId);
       await _firestore.runTransaction((transaction) async {
         final snapshot = await transaction.get(communityRef);
         if (!snapshot.exists) {
           print("Warning: Attempted to leave non-existent or already left community $communityId");
           return;
         }
         transaction.update(communityRef, {
           'memberIds': FieldValue.arrayRemove([userId]), // Ensure field exists
           'memberCount': FieldValue.increment(-1),     // Ensure field exists and is > 0?
           'updatedAt': FieldValue.serverTimestamp(),
         });
       });
       print('User $userId left community $communityId successfully.');
    } catch (e) {
       print('Error leaving community $communityId for user $userId: $e');
       rethrow;
    }
  }

  // Matches controller expectation: Future<CommunityModel> createCommunity(CommunityModel community)
  Future<CommunityModel> createCommunity(CommunityModel community) async {
    try {
      // Ensure CommunityModel.toMap() exists and model file is error-free
      final DocumentReference docRef = await _firestore.collection(_collectionPath).add(community.toMap());
      // Assumes CommunityModel has 'copyWith'
      return community.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating community: $e');
      rethrow;
    }
  }
}