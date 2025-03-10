import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/message_model.dart';
import '../data/repositories/chat_repository.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  List<ChatPreview> _chatPreviews = [];
  List<Message> _messages = [];
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _messagesSubscription;
  
  // Getters
  bool get isLoading => _isLoading;
  List<ChatPreview> get chatPreviews => _chatPreviews;
  List<Message> get messages => _messages;
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Load all chats for current user
  void loadChats() {
    _isLoading = true;
    notifyListeners();
    
    _chatsSubscription?.cancel();
    _chatsSubscription = _chatRepository.getChatsForUser().listen(
      (chats) {
        _chatPreviews = chats;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
        debugPrint('Error loading chats: $error');
      }
    );
  }
  
  // Initialize a specific chat and load its messages
  void initChat(String chatId) {
    _isLoading = true;
    _messages = [];
    notifyListeners();
    
    // Mark messages as read
    _chatRepository.markMessagesAsRead(chatId);
    
    // Listen to messages
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepository.getMessages(chatId).listen(
      (messages) {
        _messages = messages;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
        debugPrint('Error loading messages: $error');
      }
    );
  }
  
  // Send a message
  Future<void> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty) return;
    
    try {
      await _chatRepository.sendMessage(chatId, text);
    } catch (error) {
      debugPrint('Error sending message: $error');
    }
  }
  
  // Create a new chat
  Future<String> createChat({
    required String itemId,
    required String itemName,
    required String ownerId,
    required String ownerName,
    required String requesterId,
    required String requesterName,
  }) async {
    try {
      return await _chatRepository.createChat(
        itemId: itemId,
        itemName: itemName,
        ownerId: ownerId,
        ownerName: ownerName,
        requesterId: requesterId,
        requesterName: requesterName,
      );
    } catch (error) {
      debugPrint('Error creating chat: $error');
      rethrow;
    }
  }
  
  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      await _chatRepository.deleteChat(chatId);
    } catch (error) {
      debugPrint('Error deleting chat: $error');
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}