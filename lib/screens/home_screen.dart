import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../widgets/token_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _token;
  bool _permissionGranted = false;
  final List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    // 1. Request permission
    final granted = await NotificationService.requestPermission();
    setState(() => _permissionGranted = granted);

    if (!granted) {
      debugPrint('Notification permission denied');
      return;
    }

    // 2. Get the device token
    final token = await NotificationService.getToken();
    setState(() => _token = token);

    // 3. Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('Token refreshed: $newToken');
      setState(() => _token = newToken);
    });

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('--- Foreground message received ---');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');

      // Show local notification popup
      NotificationService.showForegroundNotification(message);

      // Add to the in-app list
      final notif = NotificationModel(
        title: message.notification?.title ?? 'No Title',
        body: message.notification?.body ?? 'No Body',
        receivedAt: DateTime.now(),
        data: message.data,
        source: 'foreground',
      );
      setState(() => _notifications.insert(0, notif));

      // Show an in-app popup dialog
      _showNotificationDialog(notif);
    });

    // 5. Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('--- Notification opened (background) ---');
      final notif = NotificationModel(
        title: message.notification?.title ?? 'No Title',
        body: message.notification?.body ?? 'No Body',
        receivedAt: DateTime.now(),
        data: message.data,
        source: 'background',
      );
      setState(() => _notifications.insert(0, notif));
      _showNotificationDialog(notif);
    });

    // 6. Check if app was opened from a terminated state via notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final notif = NotificationModel(
        title: initialMessage.notification?.title ?? 'No Title',
        body: initialMessage.notification?.body ?? 'No Body',
        receivedAt: DateTime.now(),
        data: initialMessage.data,
        source: 'terminated',
      );
      setState(() => _notifications.insert(0, notif));
      // Small delay to make sure context is ready for dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showNotificationDialog(notif);
      });
    }
  }

  void _showNotificationDialog(NotificationModel notif) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                notif.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notif.body, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Received: ${_formatTime(notif.receivedAt)} (${notif.source})',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
            if (notif.data.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Data: ${notif.data}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Push Notifications'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Permission status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _permissionGranted
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            _permissionGranted ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _permissionGranted
                            ? 'Notifications: Enabled'
                            : 'Notifications: Disabled',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Token display
              TokenDisplay(token: _token),
              const SizedBox(height: 16),

              // Notification list header
              Row(
                children: [
                  const Icon(Icons.inbox, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Received Notifications (${_notifications.length})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_notifications.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() => _notifications.clear()),
                      child: const Text('Clear All'),
                    ),
                ],
              ),
              const Divider(),

              // Notification list
              Expanded(
                child: _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_none,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Hey Lorraine, No notifications yet.\nSend one from Firebase Console!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (ctx, i) =>
                            NotificationCard(notification: _notifications[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
