import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // استيراد مكتبة لإظهار الرسائل المنبثقة
import 'settings_screen.dart'; // استيراد شاشة الإعدادات
import 'package:provider/provider.dart'; // استيراد مكتبة provider لإدارة الحالة
import 'speedometer_provider.dart'; // استيراد مزود عداد السرعة
import 'weather_service.dart'; // استيراد خدمة الطقس
import 'package:geolocator/geolocator.dart'; // استيراد مكتبة geolocator للحصول على الموقع الحالي
import 'package:intl/intl.dart'; // استيراد مكتبة intl لتنسيق الوقت
import 'firebase_box.dart'; // استيراد Firebase Box
import 'package:firebase_messaging/firebase_messaging.dart'; // استيراد Firebase Messaging

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String carType = 'No car selected'; // لتخزين نوع السيارة
  String temperature = 'Loading...'; // لتخزين درجة الحرارة
  String humidity = 'Loading...'; // لتخزين نسبة الرطوبة
  String windSpeed = 'Loading...'; // لتخزين سرعة الرياح
  late FToast fToast; // لاستخدام FToast لإظهار الرسائل المنبثقة
  bool hasShownToast = false; // متغير للتحقق مما إذا كانت الرسالة قد عُرضت بالفعل
  bool isKmH = true; // لتحديد وحدة السرعة (كم/س)
  late Future<dynamic> weatherData; // لتخزين بيانات الطقس
  Timer? weatherTimer; // متغير للتوقيت
  String lastUpdated = 'Never'; // لتخزين آخر وقت تحديث للطقس

  String? fcmToken; // متغير لتخزين رمز الإشعارات
  List<String> notifications = []; // قائمة لتخزين الإشعارات

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context); // تهيئة FToast باستخدام السياق

    // الحصول على تحديثات السرعة عند تحميل الصفحة
    final speedometerProvider = Provider.of<SpeedometerProvider>(context, listen: false);
    speedometerProvider.getSpeedUpdates();

    _getLocationAndFetchWeather(); // استدعاء جلب بيانات الطقس عند تحميل الشاشة
    weatherTimer = Timer.periodic(Duration(minutes: 30), (timer) {
      _getLocationAndFetchWeather(); // تحديث بيانات الطقس كل نصف ساعة
    });

    // إعداد Firebase Messaging
    _initializeFirebaseMessaging();
  }

  @override
  void dispose() {
    weatherTimer?.cancel(); // إلغاء المؤقت عند التخلص من الشاشة
    super.dispose();
  }

  // دالة لتهيئة Firebase Messaging
  void _initializeFirebaseMessaging() async {
    await FirebaseMessaging.instance.requestPermission(); // طلب إذن الإشعارات

    fcmToken = await FirebaseMessaging.instance.getToken(); // الحصول على رمز الإشعارات
    print("FCM Token: $fcmToken"); // طباعة الرمز في الكونسول

    // الاستماع للإشعارات عند وصولها
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // التعامل مع الرسالة عندما تصل
      _showToast("New message: ${message.notification?.title}"); // عرض الرسالة المنبثقة
      _addNotification(message.notification?.title ?? "New Notification"); // إضافة الإشعار إلى القائمة
    });
  }

  // دالة للحصول على الموقع الحالي واستدعاء بيانات الطقس
  Future<void> _getLocationAndFetchWeather() async {
    try {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // دقة عالية للحصول على الموقع
        distanceFilter: 100, // الحد الأدنى للتغيير في الموقع
      );

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      // استدعاء خدمة الطقس مع الإحداثيات الجغرافية
      weatherData = WeatherService().fetchWeather(position.latitude, position.longitude);

      weatherData.then((data) {
        if (data != null) {
          // إذا كانت البيانات صحيحة، تحديث واجهة المستخدم
          setState(() {
            temperature = '${data['main']['temp']}°C'; // تحديث درجة الحرارة
            humidity = '${data['main']['humidity']}%'; // تحديث الرطوبة
            windSpeed = '${data['wind']['speed']} m/s'; // تحديث سرعة الرياح
            lastUpdated = DateFormat('HH:mm').format(DateTime.now()); // تحديث وقت آخر تحديث بدون ثواني
          });

          // تخزين البيانات في Firebase
          FirebaseBox firebaseBox = FirebaseBox();
          firebaseBox.storeWeatherData(
            temperature,
            humidity,
            windSpeed,
          );
        }
      });
    } catch (e) {
      _showToast("Failed to get location: $e"); // عرض رسالة خطأ عند فشل الحصول على الموقع
    }
  }

  // دالة لإضافة إشعار إلى القائمة
  void _addNotification(String notification) {
    setState(() {
      notifications.insert(0, notification); // إضافة الإشعار إلى أعلى القائمة
    });
  }

  // دالة لإظهار رسالة منبثقة
  void _showToast(String message) {
    if (hasShownToast) return; // تحقق مما إذا كانت الرسالة قد عُرضت بالفعل

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent, // لون الخلفية للرسالة المنبثقة
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check), // أيقونة تأكيد
          SizedBox(width: 12.0),
          Text(message), // النص المرسل في الرسالة
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM, // موقع الرسالة المنبثقة
      toastDuration: Duration(seconds: 5), // مدة عرض الرسالة
    );

    hasShownToast = true; // تحديث المتغير بعد عرض الرسالة

    Future.delayed(Duration(seconds: 10), () {
      hasShownToast = false; // إعادة تعيين المتغير بعد فترة
    });
  }

  // دالة لتحديث نوع السيارة
  void updateCarType(String newType) {
    setState(() {
      carType = newType; // تحديث نوع السيارة
    });
  }

  // دالة لتبديل وحدة السرعة بين كم/س و م/ث
  void toggleSpeedUnit() {
    setState(() {
      isKmH = !isKmH; // تغيير وحدة السرعة
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على مزود عداد السرعة
    final speedometerProvider = Provider.of<SpeedometerProvider>(context);
    double currentSpeed = speedometerProvider.speedometer.currentSpeed; // الحصول على السرعة الحالية
    double totalDistance = speedometerProvider.speedometer.totalDistance; // الحصول على المسافة الإجمالية

    Color speedColor; // متغير لتحديد لون السرعة
    String speedText; // متغير لتخزين نص السرعة

    // تحويل السرعة إلى الوحدة المطلوبة
    double displayedSpeed = isKmH ? currentSpeed : currentSpeed / 3.6; // كم/س أو م/ث

    // تحديد اللون والنص بناءً على السرعة
    if (displayedSpeed == 0) {
      speedColor = Colors.grey; // اللون الرمادي
      speedText = 'STOP'; // النص عند التوقف
    } else if (isKmH) { // إذا كانت الوحدة km/h
      if (displayedSpeed > 0 && displayedSpeed <= 60) {
        speedColor = Colors.green; // اللون الأخضر
        speedText = displayedSpeed.toStringAsFixed(1); // عرض السرعة مع علامة عشرية
      } else if (displayedSpeed > 60 && displayedSpeed <= 100) {
        speedColor = Colors.yellow; // اللون الأصفر
        speedText = displayedSpeed.toStringAsFixed(1); // عرض السرعة مع علامة عشرية
      } else {
        speedColor = Colors.red; // اللون الأحمر
        speedText = displayedSpeed.toStringAsFixed(1); // عرض السرعة مع علامة عشرية
      }
    } else { // إذا كانت الوحدة m/s
      if (displayedSpeed > 0 && displayedSpeed <= 60 / 3.6) {
        speedColor = Colors.green; // اللون الأخضر
        speedText = displayedSpeed.toStringAsFixed(1); // عرض السرعة مع علامة عشرية
      } else if (displayedSpeed > 60 / 3.6 && displayedSpeed <= 100 / 3.6) {
        speedColor = Colors.yellow; // اللون الأصفر
        speedText = displayedSpeed.toStringAsFixed(1); // عرض السرعة مع علامة عشرية
      } else {
        speedColor = Colors.red; // اللون الأحمر
        speedText = displayedSpeed.toStringAsFixed(1); // عرض السرعة مع علامة عشرية
      }
    }

    return Scaffold(
      backgroundColor: Colors.black, // لون خلفية الصفحة
      appBar: AppBar(
        title: Text('Speedometer', // عنوان التطبيق
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.lightBlueAccent), // زر الإعدادات
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()), // الانتقال إلى شاشة الإعدادات
              ).then((result) {
                if (result != null) {
                  updateCarType(result); // تحديث نوع السيارة عند العودة
                }
              });
            },
          ),
        ],
        centerTitle: false,
        backgroundColor: Colors.grey[800], // لون خلفية شريط العنوان
        automaticallyImplyLeading: false, // إخفاء زر الرجوع
      ),
      body: buildBody(speedometerProvider, speedColor, speedText, totalDistance), // بناء الجسم الرئيسي للصفحة
    );
  }

  // دالة لبناء الجسم الرئيسي للصفحة
  Widget buildBody(SpeedometerProvider speedometerProvider, Color speedColor, String speedText, double totalDistance) {
    // تحديد وحدة السرعة
    String speedUnit = isKmH ? 'km/h' : 'm/s'; // وحدة السرعة
    return SingleChildScrollView( // إضافة ScrollView لتمكين التمرير
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Speed', // عنوان السرعة الحالية
            style: TextStyle(fontSize: 24, color: Colors.lightBlueAccent),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: toggleSpeedUnit, // تغيير وحدة السرعة عند النقر
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle, // شكل دائري
                color: Colors.grey[900], // لون خلفية الدائرة
                border: Border.all(color: Colors.blueAccent, width: 5), // تحديد الحدود
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      speedText,
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: speedColor),
                    ),
                    Text(
                      speedUnit,
                      style: TextStyle(fontSize: 24, color: speedColor), // حجم خط أصغر للوحدة
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Car Type: $carType', // عرض نوع السيارة
            style: TextStyle(fontSize: 20, color: Colors.lightBlueAccent),
          ),
          SizedBox(height: 20),
          Text(
            'Oil Cost: \$${speedometerProvider.calculateTotalOilCost().toStringAsFixed(2)}', // عرض تكلفة الزيت
            style: TextStyle(fontSize: 20, color: Colors.lightBlueAccent),
          ),
          SizedBox(height: 20),
          Text(
            'Distance: ${totalDistance.toStringAsFixed(2)} km', // عرض المسافة الإجمالية بالكيلومترات
            style: TextStyle(fontSize: 20, color: Colors.lightBlueAccent),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              speedometerProvider.clearDistance(); // إعادة تعيين المسافة
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Distance cleared!"), // عرض رسالة عند إعادة تعيين المسافة
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFFF44336),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFFFFF), // لون الخلفية للزر
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // مساحة داخلية للزر
            ),
            child: Text(
              'Clear Distance', // نص الزر
              style: TextStyle(color: Color(0xFFF44336)),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.thermostat, color: Colors.lightBlueAccent), // أيقونة درجة الحرارة
              SizedBox(width: 8),
              Text('$temperature', style: TextStyle(fontSize: 18, color: Colors.lightBlueAccent)), // عرض درجة الحرارة
              SizedBox(width: 20),
              Icon(Icons.water, color: Colors.lightBlueAccent), // أيقونة الرطوبة
              SizedBox(width: 8),
              Text('$humidity', style: TextStyle(fontSize: 18, color: Colors.lightBlueAccent)), // عرض الرطوبة
              SizedBox(width: 20),
              Icon(Icons.air, color: Colors.lightBlueAccent), // أيقونة سرعة الرياح
              SizedBox(width: 8),
              Text('$windSpeed', style: TextStyle(fontSize: 18, color: Colors.lightBlueAccent)), // عرض سرعة الرياح
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Last Updated: $lastUpdated', // عرض آخر وقت تحديث الطقس
            style: TextStyle(fontSize: 18, color: Colors.lightBlueAccent),
          ),
          SizedBox(height: 20),
          Text(
            'Notifications', // عنوان الإشعارات
            style: TextStyle(fontSize: 24, color: Colors.lightBlueAccent),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // منع التمرير
            itemCount: notifications.length, // عدد الإشعارات
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(notifications[index]), // عرض الإشعار
              );
            },
          ),
        ],
      ),
    );
  }
}
