import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comet/core/services/storage_service.dart';
import 'package:comet/core/services/notification_service.dart';
import 'package:comet/features/items/data/models/item_model.dart';
import 'package:comet/features/items/data/repositories/item_repository.dart';

class ItemController with ChangeNotifier {
  final ItemRepository _itemRepository;
  final StorageService _storageService;
  final NotificationService _notificationService;
  
  List<ItemModel> _communityItems = [];
  List<ItemModel> _myRequestItems = [];
  List<ItemModel> _mySharedItems = [];
  ItemModel? _selectedItem;
  bool _isLoading = false;
  String? _errorMessage;

  ItemController({
    required ItemRepository itemRepository,
    required StorageService storageService,
    required NotificationService notificationService,
  })  : _itemRepository = itemRepository,
        _storageService = storageService,
        _notificationService = notificationService;

  List<ItemModel> get communityItems => _communityItems;
  List<ItemModel> get myRequestItems => _myRequestItems;
  List<ItemModel> get mySharedItems => _mySharedItems;
  ItemModel? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCommunityItems() async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final items = await _itemRepository.getCommunityItems(userId);
      _communityItems = items;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load community items: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyRequestItems() async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final items = await _itemRepository.getUserRequestItems(userId);
      _myRequestItems = items;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load your requested items: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMySharedItems() async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final items = await _itemRepository.getUserSharedItems(userId);
      _mySharedItems = items;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load your shared items: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getItemDetails(String itemId) async {
    try {
      _setLoading(true);
      
      final item = await _itemRepository.getItemById(itemId);
      _selectedItem = item;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load item details: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createItemRequest({
    required String title,
    required String description,
    required String category,
    required DateTime startDate,
    required DateTime endDate,
    List<File>? images,
  }) async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await Future.wait(
          images.map((image) => _storageService.uploadItemImage(userId, image)),
        );
      }
      
      final newItem = ItemModel(
        id: '',  // Will be set by Firebase
        title: title,
        description: description,
        category: category,
        ownerId: userId,
        ownerName: '',  // Will be set in repository
        status: ItemStatus.requested,
        imageUrls: imageUrls,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final createdItem = await _itemRepository.createItem(newItem);
      _myRequestItems = [createdItem, ..._myRequestItems];
      
      // Notify community about new item request
      await _notificationService.sendCommunityNotification(
        title: 'New Item Request',
        body: '$title is requested by someone in your community',
        data: {'itemId': createdItem.id, 'type': 'item_request'},
      );
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create item request: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> offerItem(String itemId) async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final item = await _itemRepository.getItemById(itemId);
      
      if (item.status != ItemStatus.requested) {
        throw Exception('This item is no longer available for offering');
      }
      
      await _itemRepository.updateItemStatus(
        itemId: itemId,
        status: ItemStatus.offered,
        responderId: userId,
      );
      
      // Notify the requester
      await _notificationService.sendUserNotification(
        userId: item.ownerId,
        title: 'Item Offered',
        body: 'Someone has offered to share "${item.title}" with you',
        data: {'itemId': itemId, 'type': 'item_offered'},
      );
      
      await loadCommunityItems(); // Refresh community items
      return true;
    } catch (e) {
      _errorMessage = 'Failed to offer item: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> acceptOffer(String itemId) async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final item = await _itemRepository.getItemById(itemId);
      
      if (item.ownerId != userId) {
        throw Exception('You are not authorized to accept this offer');
      }
      
      await _itemRepository.updateItemStatus(
        itemId: itemId,
        status: ItemStatus.accepted,
      );
      
      // Notify the offerer
      if (item.responderId != null) {
        await _notificationService.sendUserNotification(
          userId: item.responderId!,
          title: 'Offer Accepted',
          body: 'Your offer for "${item.title}" has been accepted',
          data: {'itemId': itemId, 'type': 'offer_accepted'},
        );
      }
      
      await loadMyRequestItems(); // Refresh user's items
      return true;
    } catch (e) {
      _errorMessage = 'Failed to accept offer: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markItemAsReturned(String itemId) async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final item = await _itemRepository.getItemById(itemId);
      
      if (item.responderId != userId && item.ownerId != userId) {
        throw Exception('You are not authorized to update this item');
      }
      
      await _itemRepository.updateItemStatus(
        itemId: itemId,
        status: ItemStatus.completed,
      );
      
      // Notify the other party
      final notifyUserId = (userId == item.ownerId) ? item.responderId : item.ownerId;
      if (notifyUserId != null) {
        await _notificationService.sendUserNotification(
          userId: notifyUserId,
          title: 'Item Returned',
          body: '"${item.title}" has been marked as returned',
          data: {'itemId': itemId, 'type': 'item_returned'},
        );
      }
      
      await loadMyRequestItems();
      await loadMySharedItems();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark item as returned: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteItem(String itemId) async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final item = await _itemRepository.getItemById(itemId);
      
      if (item.ownerId != userId) {
        throw Exception('You are not authorized to delete this item');
      }
      
      await _itemRepository.deleteItem(itemId);
      
      _myRequestItems = _myRequestItems.where((item) => item.id != itemId).toList();
      _mySharedItems = _mySharedItems.where((item) => item.id != itemId).toList();
      _communityItems = _communityItems.where((item) => item.id != itemId).toList();
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}