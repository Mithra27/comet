import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}

class ChatPreview {
  final String id;
  final String itemId;
  final String itemName;
  final String recipientId;
  final String recipientName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatPreview({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.recipientId,
    required this.recipientName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatPreview.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Determine the recipient name based on the current user
    final bool isUserParticipant1 = data['participant1Id'] == currentUserId;
    final String recipientId = isUserParticipant1 
        ? data['participant2Id'] 
        : data['participant1Id'];
    final String recipientName = isUserParticipant1 
        ? data['participant2Name'] 
        : data['participant1Name'];

    return ChatPreview(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      itemName: data['itemName'] ?? '',
      recipientId: recipientId,
      recipientName: recipientName,
      lastMessage: data['lastMessage'] ?? 'No messages yet',
      lastMessageTime: (data['lastMessageTime'] as Timestamp? ?? Timestamp.now()).toDate(),
      unreadCount: isUserParticipant1 
          ? (data['unreadCountParticipant1'] ?? 0) 
          : (data['unreadCountParticipant2'] ?? 0),
    );
  }
}