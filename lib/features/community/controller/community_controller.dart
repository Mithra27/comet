import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comet/features/community/data/models/community_model.dart';
import 'package:comet/features/community/data/repositories/community_repository.dart';
import 'package:comet/core/services/notification_service.dart';

class CommunityController with ChangeNotifier {
  final CommunityRepository _communityRepository;
  final NotificationService _notificationService;
  
  List<CommunityModel> _availableCommunities = [];
  List<CommunityModel> _myCommunities = [];
  CommunityModel? _selectedCommunity;
  bool _isLoading = false;
  String? _errorMessage;

  CommunityController({
    required CommunityRepository communityRepository,
    required NotificationService notificationService,
  })  : _communityRepository = communityRepository,
        _notificationService = notificationService;

  List<CommunityModel> get availableCommunities => _availableCommunities;
  List<CommunityModel> get myCommunities => _myCommunities;
  CommunityModel? get selectedCommunity => _selectedCommunity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAvailableCommunities() async {
    try {
      _setLoading(true);
      
      final communities = await _communityRepository.getAvailableCommunities();
      _availableCommunities = communities;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load available communities: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyCommunities() async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final communities = await _communityRepository.getUserCommunities(userId);
      _myCommunities = communities;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load your communities: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getCommunityDetails(String communityId) async {
    try {
      _setLoading(true);
      
      final community = await _communityRepository.getCommunityById(communityId);
      _selectedCommunity = community;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load community details: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> joinCommunity({
    required String communityId,
    required String apartmentNumber,
  }) async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      await _communityRepository.joinCommunity(
        userId: userId, 
        communityId: communityId,
        apartmentNumber: apartmentNumber,
      );
      
      // Refresh my communities list
      await loadMyCommunities();
      
      // Notify community admins
      final community = await _communityRepository.getCommunityById(communityId);
      for (var adminId in community.adminIds) {
        await _notificationService.sendUserNotification(
          userId: adminId,
          title: 'New Community Member',
          body: 'A new resident has joined ${community.name}',
          data: {'communityId': communityId, 'type': 'new_member'},
        );
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to join community: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> leaveCommunity(String communityId) async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      await _communityRepository.leaveCommunity(
        userId: userId, 
        communityId: communityId,
      );
      
      // Remove from my communities list
      _myCommunities = _myCommunities.where(
        (community) => community.id != communityId
      ).toList();
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to leave community: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCommunity({
    required String name,
    required String description,
    required String address,
    required String postalCode,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      _setLoading(true);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final newCommunity = CommunityModel(
        id: '',  // Will be set by Firebase
        name: name,
        description: description,
        address: address,
        postalCode: postalCode,
        city: city,
        state: state,
        country: country,
        memberCount: 1,
        adminIds: [userId],
        memberIds: [userId],
        createdBy: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final createdCommunity = await _communityRepository.createCommunity(newCommunity);
      
      // Add to my communities list
      _myCommunities = [createdCommunity, ..._myCommunities];
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create community: ${e.toString()}';
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