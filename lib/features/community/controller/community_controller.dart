import 'package:flutter/material.dart'; // Need this for ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Timestamp potentially used in model/repo, and general Firebase interaction
import 'package:comet/features/community/data/models/community_model.dart'; // Ensure this file is error-free
import 'package:comet/features/community/data/repositories/community_repository.dart'; // Assume methods here will match calls below
import 'package:comet/core/services/notification_service.dart'; // Assume sendUserNotification will be defined here

// Use ChangeNotifier for state management with Provider
class CommunityController with ChangeNotifier {
  final CommunityRepository _communityRepository;
  final NotificationService _notificationService;

  // --- State Variables ---
  // Renamed to match community_feed_screen expectations
  List<CommunityModel> _communities = []; // Was _availableCommunities
  List<CommunityModel> _userCommunities = []; // Was _myCommunities
  CommunityModel? _selectedCommunity;
  bool _isLoading = false;
  String? _errorMessage;

  // --- Constructor ---
  CommunityController({
    required CommunityRepository communityRepository,
    required NotificationService notificationService,
  })  : _communityRepository = communityRepository,
        _notificationService = notificationService;

  // --- Getters ---
  // Renamed to match community_feed_screen expectations
  List<CommunityModel> get communities => _communities; // Was availableCommunities
  List<CommunityModel> get userCommunities => _userCommunities; // Was myCommunities
  CommunityModel? get selectedCommunity => _selectedCommunity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Public Methods ---

  // Renamed to match community_feed_screen call
  Future<void> fetchAllCommunities() async { // Was loadAvailableCommunities
    await _tryAction(() async {
      // Assume repository method exists with this name and returns List<CommunityModel>
      final communities = await _communityRepository.getAvailableCommunities();
      _communities = communities;
    }, 'Failed to load available communities');
  }

  // Renamed to match community_feed_screen call
  Future<void> fetchUserCommunities() async { // Was loadMyCommunities
    await _tryAction(() async {
      final userId = _getCurrentUserId();
      // Assume repository method exists with this name/signature and returns List<CommunityModel>
      final communities = await _communityRepository.getUserCommunities(userId);
      _userCommunities = communities;
    }, 'Failed to load your communities');
  }

  Future<void> getCommunityDetails(String communityId) async {
    await _tryAction(() async {
      // Assume repository method exists and returns CommunityModel?
      final community = await _communityRepository.getCommunityById(communityId);
      _selectedCommunity = community;
    }, 'Failed to load community details');
  }

  // Added to match community_feed_screen call
  void selectCommunity(CommunityModel community) {
    _selectedCommunity = community;
    // Optionally notify listeners if UI should react instantly to selection
    // notifyListeners();
    // Consider fetching full details if the passed community is just a summary
    // getCommunityDetails(community.id);
  }


  // Signature matches community_feed_screen call
  Future<bool> joinCommunity({
    required String communityId,
    required String apartmentNumber, // Make sure this is provided correctly from UI
  }) async {
    return await _tryActionWithResult<bool>(() async {
      final userId = _getCurrentUserId();
      // Assume repository method matches this signature
      await _communityRepository.joinCommunity(
        userId: userId,
        communityId: communityId,
        apartmentNumber: apartmentNumber,
      );

      // Refresh user's communities after joining
      await fetchUserCommunities(); // Use the renamed method

      // Notify admins (with null check)
      // Assume repository method returns CommunityModel?
      final community = await _communityRepository.getCommunityById(communityId);
      if (community != null && community.adminIds.isNotEmpty) { // Null check and check if list not empty
        for (var adminId in community.adminIds) {
          // Assume service method matches this signature
          await _notificationService.sendUserNotification(
            userId: adminId,
            title: 'New Community Member',
            // Use null-checked community name
            body: 'A new resident has joined ${community.name}',
            data: {'communityId': communityId, 'type': 'new_member'},
          );
        }
      } else {
         print("Warning: Could not fetch community details or no admins found for notification.");
      }

      return true; // Indicate success
    }, 'Failed to join community', failureResult: false); // Return false on failure
  }

  Future<bool> leaveCommunity(String communityId) async {
    return await _tryActionWithResult<bool>(() async {
       final userId = _getCurrentUserId();
       // Assume repository method matches this signature
      await _communityRepository.leaveCommunity(
        userId: userId,
        communityId: communityId,
      );

      // Optimistically remove from local list
      _userCommunities = _userCommunities.where(
        (community) => community.id != communityId
      ).toList();
      notifyListeners(); // Update UI immediately

      return true; // Indicate success
    }, 'Failed to leave community', failureResult: false); // Return false on failure
  }

  Future<bool> createCommunity({
    required String name,
    required String description,
    required String address,
    // Added missing fields based on CommunityModel structure (assuming these are needed)
    String postalCode = '', // Provide defaults or make required
    String city = '',
    String state = '',
    String country = '',
    String? gateCode, // Optional?
  }) async {
     return await _tryActionWithResult<bool>(() async {
       final userId = _getCurrentUserId();

       // Ensure CommunityModel can be instantiated (requires its file to be error-free)
      final newCommunity = CommunityModel(
        id: '', // Firestore generates ID
        name: name,
        description: description,
        address: address,
        postalCode: postalCode,
        city: city,
        state: state,
        country: country,
        gateCode: gateCode, // Add if needed
        memberCount: 1,
        adminIds: [userId],
        memberIds: [userId],
        createdBy: userId,
        // Use FieldValue for server timestamp for reliability? Or keep DateTime.now()
        createdAt: DateTime.now(), // Or FieldValue.serverTimestamp() if using Firestore directly
        updatedAt: DateTime.now(), // Or FieldValue.serverTimestamp()
      );

      // Assume repository method takes CommunityModel and returns the created CommunityModel with ID
      final createdCommunity = await _communityRepository.createCommunity(newCommunity);

      // Add to the beginning of the local list
      _userCommunities.insert(0, createdCommunity);
      notifyListeners(); // Update UI

      return true; // Indicate success
    }, 'Failed to create community', failureResult: false); // Return false on failure
  }

  // --- Helper Methods ---

  String _getCurrentUserId() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // This case should ideally be handled by UI state (redirect to login)
      // But throwing here prevents proceeding without auth.
      throw Exception('User not authenticated. Cannot perform this action.');
    }
    return userId;
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Helper to reduce boilerplate try-catch-finally for actions without a return value
  Future<void> _tryAction(Future<void> Function() action, String errorMessagePrefix) async {
     try {
      _setLoading(true);
      _errorMessage = null; // Clear previous error
      await action();
    } catch (e) {
      print('$errorMessagePrefix: ${e.toString()}'); // Log detailed error
      _errorMessage = '$errorMessagePrefix. Please try again.'; // User-friendly message
    } finally {
      _setLoading(false);
    }
  }

   // Helper to reduce boilerplate try-catch-finally for actions *with* a return value
  Future<T> _tryActionWithResult<T>(Future<T> Function() action, String errorMessagePrefix, {required T failureResult}) async {
     try {
      _setLoading(true);
      _errorMessage = null; // Clear previous error
      return await action();
    } catch (e) {
      print('$errorMessagePrefix: ${e.toString()}'); // Log detailed error
      _errorMessage = '$errorMessagePrefix. Please try again.'; // User-friendly message
      notifyListeners(); // Notify error message change
      return failureResult; // Return default failure result
    } finally {
      _setLoading(false); // Also notifies listeners
    }
  }
}