import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:notification_permissions/notification_permissions.dart';

import '../../common/constants.dart';
import '../../models/entities/fstore_notification_item.dart';

abstract class NotificationService {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void setIsInitialized() {
    _isInitialized = true;
  }

  NotificationService() {
    // var initSetting = const InitializationSettings(
    //   android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    //   iOS: DarwinNotificationDetails(),
    // );
    //
    // flutterLocalNotificationsPlugin.initialize(initSetting,
    //     onSelectNotification: (String? payload) async {
    //   /// Handle payload here
    // });

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  late final NotificationDelegate delegate;

  void init({
    /// OneSignal only
    String? externalUserId,
    required NotificationDelegate notificationDelegate,
  });

  Future<bool> requestPermission() async {
    if (kIsWeb) {
      return false;
    }
    // final status = await NotificationPermissions.requestNotificationPermissions(
    //   iosSettings: const NotificationSettingsIos(
    //     sound: true,
    //     badge: true,
    //     alert: true,
    //   ),
    // );
    // if (status == PermissionStatus.granted) {
    //   return true;
    // } else {
    //   return false;
    // }
    return true;
  }

  Future<bool> isGranted() async {
    if (kIsWeb) return false;
    // final status =
    //     await NotificationPermissions.getNotificationPermissionStatus();
    // if (status == PermissionStatus.granted) {
    //   return true;
    // }
    // return false;
    return true;
  }

  void disableNotification();

  void enableNotification();

  void setExternalId(String? userId);
  void removeExternalId();
}

mixin NotificationDelegate {
  void onMessage(FStoreNotificationItem notification);

  void onMessageOpenedApp(FStoreNotificationItem notification);
}
