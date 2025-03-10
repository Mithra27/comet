import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FlutterLocalNotificationsPlugin _localNotifications;
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal() {
    _initLocalNotifications();
  }
  
  Future<void> _initLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }
  
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap based on payload
    if (response.payload != null) {
      // Parse payload and navigate to appropriate screen
      // This would be implemented based on your app's navigation structure
    }
  }
  
  // Initialize notifications
  Future<void> initialize() async {
    // Request permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get token and store it
    final token = await _firebaseMessaging.getToken();
    await _saveToken(token);
    
    // Listen for token refreshes
    _firebaseMessaging.onTokenRefresh.listen(_saveToken);
    
    // Configure foreground notifications
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle when user taps on notification and app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }
  
  // Save FCM token to Firestore
  Future<void> _saveToken(String? token) async {
    if (token == null || _auth.currentUser == null) return;
    
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        })
        .catchError((_) {}); // Silently handle errors
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) async {
    // Extract notification details
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'comet_channel',
            'Comet Notifications',
            channelDescription: 'Notifications from Comet app',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'],
      );
    }
  }
  
  // Handle when user taps on notification and app was in background
  void _handleNotificationOpen(RemoteMessage message) {
    // This would navigate based on the message data
  }
  
  // Subscribe to topic (e.g., for community-wide notifications)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }
  
  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
  
  // Clear badge count
  Future<void> clearBadgeCount() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(badge: false);
    // For iOS:
    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
  
  // Send local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'comet_local_channel',
      'Comet Local Notifications',
      channelDescription: 'Local notifications from Comet app',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}