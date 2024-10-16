import 'dart:convert'; // لاستيراد مكتبة JSON لتحليل البيانات
import 'package:http/http.dart' as http; // لاستيراد مكتبة HTTP للقيام بالاستدعاءات

class WeatherService {
  // مفتاح API الخاص بك للحصول على بيانات الطقس
  final String apiKey = 'b85d82b5526546b9be1fdccca46ba3f8';

  // عنوان قاعدة بيانات API للطقس
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // دالة لجلب بيانات الطقس بناءً على خطوط العرض والطول
  Future<Map<String, dynamic>?> fetchWeather(double latitude, double longitude) async {
    try {
      // استدعاء API للحصول على بيانات الطقس
      final response = await http.get(Uri.parse('$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric'));

      // تحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        // إذا كانت الاستجابة ناجحة، قم بتحليل البيانات وإرجاعها
        return json.decode(response.body);
      } else {
        print('Error: ${response.statusCode}'); // طباعة رسالة الخطأ
        return null; // إرجاع null في حالة وجود خطأ
      }
    } catch (e) {
      print('Failed to load weather data: $e'); // طباعة الخطأ في حالة حدوث استثناء
      return null; // إرجاع null في حالة حدوث استثناء
    }
  }
}
