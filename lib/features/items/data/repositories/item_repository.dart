// lib/features/items/data/repositories/item_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

class ItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new item request
  Future<String?> createItemRequest(Item item) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;
      
      // Set the requester ID and timestamps
      item.requesterId = userId;
      item.createdAt = DateTime.now();
      item.updatedAt = DateTime.now();
      
      final DocumentReference docRef = await _firestore.collection('items').add(item.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating item request: $e');
      return null;
    }
  }
  
  // Get all item requests for a community
  Future<List<Item>> getCommunityItems(String communityId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('items')
          .where('communityId', isEqualTo: communityId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print('Error fetching community items: $e');
      return [];
    }
  }
  
  // Get items requested by current user
  Future<List<Item>> getUserRequestedItems() async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];
      
      final QuerySnapshot snapshot = await _firestore
          .collection('items')
          .where('requesterId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print('Error fetching user items: $e');
      return [];
    }
  }
  
  // Get items user is lending
  Future<List<Item>> getUserLendingItems() async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];
      
      final QuerySnapshot snapshot = await _firestore
          .collection('items')
          .where('lenderId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print('Error fetching lending items: $e');
      return [];
    }
  }
  
  // Get a specific item by ID
  Future<Item?> getItemById(String itemId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('items').doc(itemId).get();
      if (!doc.exists) return null;
      
      return Item.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error fetching item: $e');
      return null;
    }
  }
  
  // Update item status
  Future<bool> updateItemStatus(String itemId, ItemStatus status, {String? lenderId}) async {
    try {
      final updates = {
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now(),
      };
      
      if (lenderId != null) {
        updates['lenderId'] = lenderId;
      }
      
      await _firestore.collection('items').doc(itemId).update(updates);
      return true;
    } catch (e) {
      print('Error updating item status: $e');
      return false;
    }
  }
  
  // Delete an item request
  Future<bool> deleteItem(String itemId) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return false;
      
      // Verify the user is the requester
      final Item? item = await getItemById(itemId);
      if (item == null || item.requesterId != userId) return false;
      
      await _firestore.collection('items').doc(itemId).delete();
      return true;
    } catch (e) {
      print('Error deleting item: $e');
      return false;
    }
  }
  
  // Search items by name or description
  Future<List<Item>> searchItems(String query, String communityId) async {
    try {
      // Get all items in the community
      final QuerySnapshot snapshot = await _firestore
          .collection('items')
          .where('communityId', isEqualTo: communityId)
          .get();
      
      final List<Item> items = snapshot.docs
          .map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // Filter items client-side by name or description
      // Note: Firebase doesn't support text search natively, so we do it on the client
      final List<Item> filteredItems = items.where((item) =>
          item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      return filteredItems;
    } catch (e) {
      print('Error searching items: $e');
      return [];
    }
  }
}