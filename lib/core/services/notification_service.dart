import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// Service for handling notifications in the app
///
/// Handles:
/// - Local notifications (in-app / foreground)
/// - Firebase Cloud Messaging (push when app is in background or closed)
@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService();

  /// Initialize notification service
  /// Sets up notification channels and requests permissions
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('NotificationService already initialized');
      return;
    }

    try {
      debugPrint('Initializing NotificationService...');
      
      // Android initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized != true) {
        debugPrint('NotificationService initialization returned false or null');
        return;
      }

      debugPrint('NotificationService initialized successfully');

      // Create notification channels for Android
      await _createNotificationChannels();

      _initialized = true;
      debugPrint('NotificationService setup complete');

      // FCM: request permission, get token, save to Firestore, set up handlers
      await _initializeFcm();
    } catch (e, stackTrace) {
      debugPrint('Error initializing NotificationService: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't set _initialized to true if initialization failed
    }
  }

  /// Initialize Firebase Cloud Messaging for push when app is background/closed
  Future<void> _initializeFcm() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission: ${settings.authorizationStatus}');

      await _saveFcmTokenIfLoggedIn();

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _saveFcmTokenToFirestore(token);
      });

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing FCM: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _saveFcmTokenIfLoggedIn() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _saveFcmTokenToFirestore(token);
    }
  }

  Future<void> _saveFcmTokenToFirestore(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
      debugPrint('FCM token saved to Firestore');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null &&
        notification.title != null &&
        notification.body != null) {
      _showFcmAsLocalNotification(notification.title!, notification.body!);
      return;
    }
    final type = message.data['type'] as String?;
    if (type == 'haptic') {
      showHapticNotification();
    } else if (type == 'quick_message') {
      final body = message.data['message'] as String? ?? '';
      showQuickMessageNotification(body);
    }
  }

  Future<void> _showFcmAsLocalNotification(String title, String body) async {
    if (!_initialized) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'quick_messages',
        'Quick Messages',
        channelDescription: 'Notifications from your partner',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
    } catch (e) {
      debugPrint('Error showing FCM as local notification: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.notification?.title}');
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Haptic signal channel
    const hapticChannel = AndroidNotificationChannel(
      'haptic_signals',
      'Haptic Signals',
      description: 'Notifications for haptic touch signals from your partner',
      importance: Importance.high,
      playSound: false,
      enableVibration: true,
    );

    // Quick messages channel
    const messagesChannel = AndroidNotificationChannel(
      'quick_messages',
      'Quick Messages',
      description: 'Notifications for quick messages from your partner',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(hapticChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(messagesChannel);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    // Request permissions
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Show a local notification for haptic signal
  Future<void> showHapticNotification() async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, attempting initialization...');
      await initialize();
      if (!_initialized) {
        debugPrint('Failed to initialize NotificationService, cannot show notification');
        return;
      }
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'haptic_signals',
        'Haptic Signals',
        channelDescription: 'Notifications for haptic touch signals',
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1,
        '💓 Touch',
        'Your partner touched you',
        details,
        payload: 'haptic',
      );
      debugPrint('Haptic notification shown successfully');
    } catch (e, stackTrace) {
      debugPrint('Error showing haptic notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Show a local notification for quick message
  Future<void> showQuickMessageNotification(String message) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized, attempting initialization...');
      await initialize();
      if (!_initialized) {
        debugPrint('Failed to initialize NotificationService, cannot show notification');
        return;
      }
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'quick_messages',
        'Quick Messages',
        channelDescription: 'Notifications for quick messages',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        2,
        '💬 Quick Message',
        message,
        details,
        payload: 'message:$message',
      );
      debugPrint('Quick message notification shown successfully');
    } catch (e, stackTrace) {
      debugPrint('Error showing quick message notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }
}
