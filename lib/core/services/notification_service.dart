import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// Service for handling notifications in the app
/// 
/// This service handles local notifications that appear in the system notification tray.
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
      print('NotificationService already initialized');
      return;
    }

    try {
      print('Initializing NotificationService...');
      
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
        print('NotificationService initialization returned false or null');
        return;
      }

      print('NotificationService initialized successfully');

      // Create notification channels for Android
      await _createNotificationChannels();

      _initialized = true;
      print('NotificationService setup complete');
    } catch (e, stackTrace) {
      print('Error initializing NotificationService: $e');
      print('Stack trace: $stackTrace');
      // Don't set _initialized to true if initialization failed
    }
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
      print('NotificationService not initialized, attempting initialization...');
      await initialize();
      if (!_initialized) {
        print('Failed to initialize NotificationService, cannot show notification');
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
      print('Haptic notification shown successfully');
    } catch (e, stackTrace) {
      print('Error showing haptic notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Show a local notification for quick message
  Future<void> showQuickMessageNotification(String message) async {
    if (!_initialized) {
      print('NotificationService not initialized, attempting initialization...');
      await initialize();
      if (!_initialized) {
        print('Failed to initialize NotificationService, cannot show notification');
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
      print('Quick message notification shown successfully');
    } catch (e, stackTrace) {
      print('Error showing quick message notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }
}
