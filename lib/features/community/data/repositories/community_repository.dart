import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_model.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all available communities
  Future<List<Community>> getAllCommunities() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('communities').get();
      return snapshot.docs.map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print('Error fetching communities: $e');
      return [];
    }
  }

  // Get communities that the current user is a member of
  Future<List<Community>> getUserCommunities() async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      final QuerySnapshot snapshot = await _firestore
          .collection('communities')
          .where('members', arrayContains: userId)
          .get();
      
      return snapshot.docs.map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print('Error fetching user communities: $e');
      return [];
    }
  }

  // Join a community
  Future<bool> joinCommunity(String communityId) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return false;

      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
      
      return true;
    } catch (e) {
      print('Error joining community: $e');
      return false;
    }
  }

  // Leave a community
  Future<bool> leaveCommunity(String communityId) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return false;

      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayRemove([userId]),
      });
      
      return true;
    } catch (e) {
      print('Error leaving community: $e');
      return false;
    }
  }

  // Create a new community
  Future<String?> createCommunity(Community community) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      // Add the creator as admin and member
      community.adminId = userId;
      community.members = [userId];
      
      final DocumentReference docRef = await _firestore.collection('communities').add(community.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating community: $e');
      return null;
    }
  }

  // Get a specific community by ID
  Future<Community?> getCommunityById(String communityId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('communities').doc(communityId).get();
      if (!doc.exists) return null;
      
      return Community.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error fetching community: $e');
      return null;
    }
  }
}