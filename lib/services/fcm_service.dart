import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service/api_endpoint.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late AndroidNotificationChannel _androidChannel;
  StreamSubscription? _onTokenRefreshSubscription;
  StreamSubscription? _onMessageSubscription;
  StreamSubscription? _onMessageOpenedAppSubscription;

  // Backend API endpoint for saving FCM token
  late String _saveTokenEndpoint;

  String get saveTokenEndpoint {
    if (!_saveTokenEndpointInitialized) {
      _saveTokenEndpoint = '${ApiEndPoints.baseUrl}/male-user/save-fcm-token';
      _saveTokenEndpointInitialized = true;
    }
    return _saveTokenEndpoint;
  }

  bool _saveTokenEndpointInitialized = false;

  /// Initialize FCM and local notifications
  Future<void> initialize() async {
    try {
      // Initialize local notifications plugin
      await _initializeLocalNotifications();

      // Request notification permission (Android 13+ compatible)
      await _requestNotificationPermission();

      // Get the FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      if (token != null) {
        // Save token to backend
        await _saveTokenToBackend(token);

        // Save token locally for future reference
        await _saveTokenLocally(token);
      }

      // Listen for token refresh
      _setupTokenRefreshListener();

      // Listen for foreground messages
      _setupForegroundMessageListener();

      // Listen for background messages
      _setupBackgroundMessageListener();

      // Listen for notification taps when app is closed
      _setupNotificationTapListener();

      debugPrint('FCM Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM Service: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Create notification channel for Android
    _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
      playSound: true,
    );

    // Initialize the plugin
    await _localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  /// Request notification permission (Android 13+ compatible)
  Future<void> _requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined notification permission');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Save FCM token to backend
  Future<void> _saveTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse(saveTokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fcm_token': token, 'platform': 'flutter'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('FCM token saved to backend successfully');
      } else {
        debugPrint('Failed to save FCM token to backend: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error saving FCM token to backend: $e');
    }
  }

  /// Save token locally for reference
  Future<void> _saveTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Get locally saved token
  Future<String?> getLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Set up token refresh listener
  void _setupTokenRefreshListener() {
    _onTokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(
      (String token) async {
        debugPrint('FCM Token refreshed: $token');

        // Save new token to backend
        await _saveTokenToBackend(token);

        // Update local storage
        await _saveTokenLocally(token);
      },
      onError: (error) {
        debugPrint('Error on token refresh: $error');
      },
    );
  }

  /// Set up foreground message listener
  void _setupForegroundMessageListener() {
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        debugPrint(
          'Received a foreground message: ${message.notification?.title}',
        );

        // Show local notification when app is in foreground
        _showLocalNotification(message);
      },
      onError: (error) {
        debugPrint('Error on foreground message: $error');
      },
    );
  }

  /// Set up background message listener
  void _setupBackgroundMessageListener() {
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  /// Set up notification tap listener (when app is closed)
  void _setupNotificationTapListener() {
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp
        .listen(
          (RemoteMessage message) {
            debugPrint(
              'Notification opened app: ${message.notification?.title}',
            );

            // Navigate to IncomingCallScreen when notification is tapped
            _navigateToIncomingCallScreen(message);
          },
          onError: (error) {
            debugPrint('Error on message opened app: $error');
          },
        );
  }

  /// Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Received a background message: ${message.data}');

    // Handle the notification data here
    // You can perform background processing or show a notification
    // For background messages, we need to show local notifications manually
    await _showLocalNotificationStatic(message);
  }

  /// Static method to show local notification for background messages
  static Future<void> _showLocalNotificationStatic(
    RemoteMessage message,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await notificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  /// Navigate to IncomingCallScreen when notification is tapped
  void _navigateToIncomingCallScreen(RemoteMessage message) {
    // Extract call data from the notification
    final callType =
        message.data['call_type'] ?? message.data['callType'] ?? 'audio';
    final callerName =
        message.data['caller_name'] ?? message.data['callerName'] ?? 'Unknown';
    final callerAvatar =
        message.data['caller_avatar'] ?? message.data['callerAvatar'] ?? '';
    final callId =
        message.data['call_id'] ??
        message.data['callId'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('Navigating to incoming call screen for: $callerName');

    // For navigation to work, you might need to use a navigator key
    // or a service to handle navigation outside of widgets
    // This is a simplified approach - you might need to adapt based on your navigation setup

    // Example: Using a global navigator key
    // You'll need to implement a global navigator key in your app to make this work
    // For now, we'll just print the navigation intent
    debugPrint('Would navigate to incoming call screen with:');
    debugPrint('  - Caller: $callerName');
    debugPrint('  - Type: $callType');
    debugPrint('  - Avatar: $callerAvatar');
    debugPrint('  - Call ID: $callId');

    // In a real implementation, you would use a global navigator key
    // For now, we'll use a callback approach to trigger navigation
    if (_onNotificationTappedCallback != null) {
      _onNotificationTappedCallback!(
        callId,
        callerName,
        callerAvatar,
        callType,
      );
    }
  }

  // Callback for handling notification taps
  void Function(
    String callId,
    String callerName,
    String callerAvatar,
    String callType,
  )?
  _onNotificationTappedCallback;

  void setOnNotificationTappedCallback(
    void Function(
      String callId,
      String callerName,
      String callerAvatar,
      String callType,
    )
    callback,
  ) {
    _onNotificationTappedCallback = callback;
  }

  /// Dispose of subscriptions
  void dispose() {
    _onTokenRefreshSubscription?.cancel();
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('FCM token deleted');

      // Remove from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}
