import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'speedometer_provider.dart'; // استيراد SpeedometerProvider
import 'home_screen.dart'; // استيراد HomeScreen
import 'home_screen2.dart'; // استيراد HomeScreen2
import 'permission_service.dart'; // استيراد PermissionService
import 'package:shared_preferences/shared_preferences.dart'; // استيراد SharedPreferences
import 'package:firebase_core/firebase_core.dart'; // استيراد Firebase Core
import 'firebase_options.dart'; // استيراد Firebase options
import 'package:permission_handler/permission_handler.dart'; // استيراد permission_handler
import 'package:firebase_messaging/firebase_messaging.dart'; // استيراد Firebase Messaging
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // استيراد Local Notifications

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// دالة لمعالجة الإشعارات في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}"); // طباعة معرف الرسالة عند التعامل معها

  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'my_app_notifications', // معرف القناة
    'Notifications', // اسم القناة
    channelDescription: 'This channel is used for app notifications', // وصف القناة
    importance: Importance.max, // أهمية الإشعار
    priority: Priority.high, // أولوية الإشعار
    showWhen: false, // إخفاء الوقت
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  // عرض الإشعار
  await flutterLocalNotificationsPlugin.show(
    0, // معرف الإشعار
    message.notification?.title, // عنوان الإشعار
    message.notification?.body, // محتوى الإشعار
    platformChannelSpecifics,
    payload: 'item x', // بيانات إضافية يمكن تمريرها
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // التأكد من أن التهيئة تمت قبل بدء التطبيق

  // تهيئة Firebase
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // تأكد من تهيئة Firebase مع الخيارات الصحيحة
    print("Firebase initialized successfully."); // تأكيد التهيئة
  } catch (e) {
    print("Error initializing Firebase: $e"); // طباعة الخطأ في حال فشل التهيئة
  }

  // تهيئة الإشعارات المحلية
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  // تهيئة مكتبة الإشعارات المحلية
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // ربط دالة معالجة الإشعارات في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  PermissionService permissionService = PermissionService();

  // طلب إذن الموقع
  await permissionService.requestLocationPermission();

  // طلب إذن الإشعارات
  await requestNotificationPermission(); // طلب إذن الإشعارات

  runApp(MyApp()); // بدء التطبيق
}

// دالة لطلب إذن الإشعارات
Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status; // الحصول على حالة الإذن
  if (!status.isGranted) {
    await Permission.notification.request(); // طلب الإذن إذا لم يكن ممنوحاً
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpeedometerProvider(), // توفير SpeedometerProvider
      child: MaterialApp(
        title: 'SpeedX2',
        home: FutureBuilder(
          future: _loadColorMode(), // تحميل وضع الألوان
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // عرض مؤشر تحميل أثناء الانتظار
            } else {
              bool isDarkMode = snapshot.data as bool; // الحصول على حالة الوضع
              return isDarkMode ? HomeScreen() : HomeScreen2(); // عرض الشاشة المناسبة بناءً على الوضع
            }
          },
        ),
      ),
    );
  }

  // دالة لتحميل حالة الوضع من SharedPreferences
  Future<bool> _loadColorMode() async {
    final prefs = await SharedPreferences.getInstance(); // الحصول على مثيل SharedPreferences
    return prefs.getBool('isDarkMode') ?? true; // افتراض أن الوضع داكن إذا لم يكن مخزناً
  }
}
