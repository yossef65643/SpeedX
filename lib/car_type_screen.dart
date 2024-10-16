import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// تعريف الشاشة الخاصة بنوع السيارة
class CarTypeScreen extends StatefulWidget {
  @override
  _CarTypeScreenState createState() => _CarTypeScreenState();
}

// الحالة الخاصة بالشاشة
class _CarTypeScreenState extends State<CarTypeScreen> {
  // متحكم نصي لإدارة مدخلات المستخدم
  final TextEditingController _controller = TextEditingController();
  // متغير للتحكم في وضع الألوان (الداكن أو الفاتح)
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    // تحميل وضع الألوان عند بدء الشاشة
    _loadColorMode();
  }

  // دالة لتحميل وضع الألوان من التخزين المشترك
  Future<void> _loadColorMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // إذا لم يكن هناك قيمة مخزنة، استخدم الوضع الداكن كافتراضي
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // بناء واجهة الشاشة
    return Scaffold(
      // تعيين لون الخلفية بناءً على وضع الألوان
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        // عنوان التطبيق
        title: Text('Car Type', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
        // لون خلفية شريط التطبيق
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
      ),
      body: Center(
        // إضافة حشوة وتنسيق العناصر في الوسط
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // حقل إدخال نصي لإدخال نوع السيارة
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter car type', // نص تلميحي للحقل
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.black),
                  filled: true,
                  // لون خلفية الحقل بناءً على وضع الألوان
                  fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0), // شكل الحواف
                    borderSide: BorderSide.none, // بدون حدود مرئية
                  ),
                ),
                style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black), // لون النص
              ),
              SizedBox(height: 20), // مساحة فارغة بين العناصر
              // زر للإرسال
              ElevatedButton(
                onPressed: () {
                  // العودة إلى الشاشة السابقة مع قيمة المدخلات
                  Navigator.pop(context, _controller.text);
                },
                child: Text('Enter', style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
                // تخصيص لون الزر
                style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
