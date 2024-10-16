import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'speedometer_provider.dart';

// تعريف الشاشة الخاصة بتكاليف الوقود
class OilCostScreen extends StatefulWidget {
  @override
  _OilCostScreenState createState() => _OilCostScreenState();
}

// الحالة الخاصة بالشاشة
class _OilCostScreenState extends State<OilCostScreen> {
  // متحكمات نصية لإدارة مدخلات المستخدم
  final TextEditingController _priceController = TextEditingController(); // لسعر اللتر
  final TextEditingController _distancePerLiterController = TextEditingController(); // للمسافة المقطوعة باللتر
  bool isDarkMode = true; // متغير للتحكم في وضع الألوان

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
        title: Text('Oil Cost', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
        // لون خلفية شريط التطبيق
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // إضافة حشوة حول المحتوى
        child: Column(
          children: [
            // حقل إدخال لسعر اللتر
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price per liter', // نص التسمية للحقل
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black), // لون النص
              keyboardType: TextInputType.number, // نوع الإدخال عدد
            ),
            // حقل إدخال للمسافة المقطوعة باللتر
            TextField(
              controller: _distancePerLiterController,
              decoration: InputDecoration(
                labelText: 'Distance per liter', // نص التسمية للحقل
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black), // لون النص
              keyboardType: TextInputType.number, // نوع الإدخال عدد
            ),
            SizedBox(height: 20), // مساحة فارغة بين العناصر
            // زر لحفظ القيم
            ElevatedButton(
              onPressed: () {
                // تحويل النص إلى قيم عددية
                double pricePerLiter = double.tryParse(_priceController.text) ?? 0;
                double distancePerLiter = double.tryParse(_distancePerLiterController.text) ?? 0;

                // تحديث تكلفة الوقود في مزود الحالة
                Provider.of<SpeedometerProvider>(context, listen: false)
                    .updateOilCost(pricePerLiter, distancePerLiter);

                Navigator.pop(context); // العودة إلى الصفحة السابقة
              },
              child: Text('Save', style: TextStyle(color: isDarkMode ? Colors.lightBlueAccent : Colors.black)),
              // تخصيص لون الزر
              style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
            ),
          ],
        ),
      ),
    );
  }
}
