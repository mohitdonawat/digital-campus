import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ies_campus_channel', // id
    'IES Campus Notifications', // name
    description: 'Instant alerts for announcements, timetables, quizzes, and grievances with sound.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static bool _isInitialized = false;

  /// Initialize FCM, local sound notifications, and channels
  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Request notification permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Initialize flutter_local_notifications for foreground sound banners
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle tap on notification
        },
      );

      // Create Android channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Set foreground notification presentation options
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Foreground FCM Listener: show heads-up banner with audio sound
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null) {
          showLocalSoundNotification(
            id: notification.hashCode,
            title: notification.title ?? 'IES Campus Alert',
            body: notification.body ?? '',
          );
        }
      });

      // 5. Update user FCM token if logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final token = await _fcm.getToken();
        if (token != null) {
          await _firestore.collection('users').doc(currentUser.uid).update({
            'fcmToken': token,
            'fcmUpdatedAt': Timestamp.now(),
          }).catchError((_) {});
        }
      }

      // 6. Subscribe to default topic
      await _fcm.subscribeToTopic('all_campus').catchError((_) {});
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService initialization note: $e');
      }
    }
  }

  /// Trigger an instant local sound notification banner
  static Future<void> showLocalSoundNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
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

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      await _localNotifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      if (kDebugMode) {
        print('Error showing local notification: $e');
      }
    }
  }

  /// Dispatch a campus-wide or targeted notification
  /// Saves record in Firestore `notifications` and rings notification with sound
  static Future<void> sendCampusNotification({
    required String title,
    required String body,
    required String category, // 'Announcement', 'Timetable', 'Quiz', 'Grievance', 'Assignment'
    String targetBranch = 'ALL',
    String targetYear = 'ALL',
    String? targetUid,
    String? targetStudentName,
  }) async {
    try {
      final docRef = await _firestore.collection('notifications').add({
        'title': title,
        'body': body,
        'category': category,
        'targetBranch': targetBranch,
        'targetYear': targetYear,
        'targetUid': targetUid,
        'targetStudentName': targetStudentName,
        'createdAt': Timestamp.now(),
        'readBy': [],
      });

      // Ring local notification with sound for immediate active user feedback
      await showLocalSoundNotification(
        id: docRef.id.hashCode,
        title: '$category: $title',
        body: body,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send campus notification: $e');
      }
    }
  }

  /// Stream of notifications filtered for the student
  static Stream<List<Map<String, dynamic>>> streamStudentNotifications({
    required String studentUid,
    required String branch,
    required String year,
  }) {
    return _firestore
        .collection('notifications')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).where((data) {
        final tUid = data['targetUid'];
        if (tUid != null && tUid.toString().isNotEmpty) {
          return tUid == studentUid;
        }

        final tBranch = data['targetBranch'] ?? 'ALL';
        final tYear = data['targetYear'] ?? 'ALL';

        final matchBranch = tBranch == 'ALL' ||
            tBranch.toString().toLowerCase() == branch.toLowerCase() ||
            branch.toLowerCase().contains(tBranch.toString().toLowerCase());

        final matchYear = tYear == 'ALL' ||
            tYear.toString().toLowerCase() == year.toLowerCase();

        return matchBranch && matchYear;
      }).toList();

      list.sort((a, b) {
        final tA = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final tB = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return tB.compareTo(tA);
      });

      return list;
    });
  }
}
