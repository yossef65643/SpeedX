import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBox {
  // إنشاء مجموعة لتخزين بيانات الطقس
  final CollectionReference weatherCollection =
  FirebaseFirestore.instance.collection('weatherData');

  // دالة لتخزين بيانات الطقس
  Future<void> storeWeatherData(String temperature, String humidity, String windSpeed) async {
    String timestamp = DateTime.now().toIso8601String(); // الحصول على توقيت الختم

    // إضافة البيانات إلى مجموعة Firestore
    await weatherCollection.add({
      'timestamp': timestamp, // توقيت الختم
      'temperature': temperature, // درجة الحرارة
      'humidity': humidity, // نسبة الرطوبة
      'windSpeed': windSpeed, // سرعة الرياح
    });
  }
}
