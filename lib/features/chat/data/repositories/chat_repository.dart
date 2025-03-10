import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import '../../../../core/services/encryption_service.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EncryptionService _encryptionService = EncryptionService();
  
  // Collection references
  CollectionReference get _chatsCollection => _firestore.collection('chats');
  CollectionReference get _messagesCollection => _firestore.collection('messages');
  
  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Create a new chat
  Future<String> createChat({
    required String itemId,
    required String itemName,
    required String ownerId,
    required String ownerName,
    required String requesterId,
    required String requesterName,
  }) async {
    // First check if a chat already exists for this item and these participants
    final existingChatQuery = await _chatsCollection
        .where('itemId', isEqualTo: itemId)
        .where('participant1Id', whereIn: [ownerId, requesterId])
        .get();
    
    for (final doc in existingChatQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['participant1Id'] == ownerId && data['participant2Id'] == requesterId) ||
          (data['participant1Id'] == requesterId && data['participant2Id'] == ownerId)) {
        // Chat already exists
        return doc.id;
      }
    }
    
    // Create new chat
    final chatDocRef = await _chatsCollection.add({
      'itemId': itemId,
      'itemName': itemName,
      'participant1Id': ownerId,
      'participant1Name': ownerName,
      'participant2Id': requesterId,
      'participant2Name': requesterName,
      'lastMessage': 'Chat started',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCountParticipant1': 0,
      'unreadCountParticipant2': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
    });
    
    return chatDocRef.id;
  }
  
  // Get all chats for current user
  Stream<List<ChatPreview>> getChatsForUser() {
    return _chatsCollection
        .where(Filter.or(
          Filter('participant1Id', isEqualTo: currentUserId),
          Filter('participant2Id', isEqualTo: currentUserId),
        ))
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatPreview.fromFirestore(doc, currentUserId))
            .toList());
  }
  
  // Send a message
  Future<void> sendMessage(String chatId, String text) async {
    // Get chat to determine recipient
    final chatDoc = await _chatsCollection.doc(chatId).get();
    if (!chatDoc.exists) {
      throw Exception('Chat not found');
    }
    
    final chatData = chatDoc.data() as Map<String, dynamic>;
    final bool isUserParticipant1 = chatData['participant1Id'] == currentUserId;
    final String recipientId = isUserParticipant1 
        ? chatData['participant2Id'] 
        : chatData['participant1Id'];
    
    // Encrypt the message
    final encryptedText = await _encryptionService.encrypt(text);
    
    // Create message document
    await _messagesCollection.add({
      'chatId': chatId,
      'senderId': currentUserId,
      'senderName': _auth.currentUser?.displayName ?? 'User',
      'text': encryptedText,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    
    // Update chat document with last message
    final String fieldToUpdate = isUserParticipant1 
        ? 'unreadCountParticipant2' 
        : 'unreadCountParticipant1';
    
    await _chatsCollection.doc(chatId).update({
      'lastMessage': text.length > 50 ? '${text.substring(0, 47)}...' : text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      fieldToUpdate: FieldValue.increment(1),
    });
  }
  
  // Get messages for a chat
  Stream<List<Message>> getMessages(String chatId) {
    return _messagesCollection
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots()
        .asyncMap((snapshot) async {
          List<Message> decryptedMessages = [];
          for (var doc in snapshot.docs) {
            final message = Message.fromFirestore(doc);
            // Decrypt the message text
            final decryptedText = await _encryptionService.decrypt(message.text);
            decryptedMessages.add(
              Message(
                id: message.id,
                chatId: message.chatId,
                senderId: message.senderId,
                senderName: message.senderName,
                text: decryptedText,
                timestamp: message.timestamp,
                isRead: message.isRead,
              )
            );
          }
          return decryptedMessages;
        });
  }
  
  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    final chatDoc = await _chatsCollection.doc(chatId).get();
    if (!chatDoc.exists) {
      return;
    }
    
    final chatData = chatDoc.data() as Map<String, dynamic>;
    final bool isUserParticipant1 = chatData['participant1Id'] == currentUserId;
    
    // Update unread count in chat document
    final String fieldToUpdate = isUserParticipant1 
        ? 'unreadCountParticipant1' 
        : 'unreadCountParticipant2';
    
    await _chatsCollection.doc(chatId).update({
      fieldToUpdate: 0,
    });
    
    // Get unread messages sent to current user
    final messagesQuery = await _messagesCollection
        .where('chatId', isEqualTo: chatId)
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();
    
    // Create a batch to update all messages at once
    final batch = _firestore.batch();
    for (final doc in messagesQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }
  
  // Delete chat
  Future<void> deleteChat(String chatId) async {
    // Delete all messages in the chat
    final messagesQuery = await _messagesCollection
        .where('chatId', isEqualTo: chatId)
        .get();
    
    final batch = _firestore.batch();
    for (final doc in messagesQuery.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the chat document
    batch.delete(_chatsCollection.doc(chatId));
    
    await batch.commit();
  }
}